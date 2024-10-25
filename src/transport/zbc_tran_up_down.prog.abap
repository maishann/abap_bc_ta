*&---------------------------------------------------------------------*
*& Report ZBC_TRAN_UP_DOWN                                             *
*&---------------------------------------------------------------------*
*& Date:   24.10.2024                                                  *
*& Author: Hannes Maisch (HANNESM)                                     *
*& Company: ponturo consulting AG                                      *
*& Requested from:                                                     *
*& Description: Ermöglich den Up- & Download von Transportaufträge     *
*&              vom Applikationsserver auf den PC und umgekehrt.       *
*&---------------------------------------------------------------------*
*& Change History                                                      *
*& Date        | Author   | CR &  Description                          *
*&---------------------------------------------------------------------*
REPORT zbc_tran_up_down.

INCLUDE zbc_tran_up_down_scr.
INCLUDE zbc_tran_up_down_lcl.

INITIALIZATION.
  PERFORM init.

START-OF-SELECTION.
  CASE 'X'.
    WHEN p_r01. " UPLOAD
      lcl_transport=>upload_request( ).
    WHEN p_r02. " DOWNLOAD
      lcl_transport=>download_request( ).
  ENDCASE.

*#######################################################################
*           FORM-ROUTINES                                              #
*#######################################################################
*&---------------------------------------------------------------------*
*& Form init
*&---------------------------------------------------------------------*
FORM init.
  DATA lv_variant TYPE rsvar-variant.

  " --- DETERMINE SAPTRANS
  CALL 'C_SAPGPARAM' ID 'NAME' FIELD 'DIR_TRANS'
       ID 'VALUE' FIELD p_appl.

  vt_ta    = 'Auftrag/Aufgabe'(011).
  vt_b01   = 'Datei kopieren'(001).
  vt_b02   = 'Richtung'(002).
  vt_b03   = 'Import Optionen'(007).
  vt_frnt  = 'Pfad vom Desktop'(003).
  vt_appl  = 'Pfad auf SAP-System'(004).
  vt_r01   = 'Desktop --> SAP-System'(005).
  vt_r02   = 'SAP-System --> Desktop'(006).
  vt_appen = 'Transportauftrag an Queue anhängen'(010).
  vt_impo  = 'Import Transport'(009).

  " --- set Default variant
  CLEAR lv_variant.
  GET PARAMETER ID 'ZBC_TRANSPORT_VAR' FIELD lv_variant.

  IF lv_variant IS NOT INITIAL.
    CALL FUNCTION 'RS_SUPPORT_SELECTIONS'
      EXPORTING  report               = sy-repid
                 variant              = lv_variant
      EXCEPTIONS variant_not_existent = 1
                 variant_obsolete     = 1
                 OTHERS               = 1.
    IF sy-subrc = 0.
      " ---> Default-Variante & wurde übernommen.
      MESSAGE s013(zbc_transport) WITH lv_variant.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form at_selection_screen_for_frnt
*&---------------------------------------------------------------------*
FORM at_selection_screen_for_frnt.
  " ---Suchhilfe nach Datei auf Frontend
  CALL FUNCTION 'TMP_GUI_BROWSE_FOR_FOLDER'
    EXPORTING  window_title    = 'Auswahl' ##NO_TEXT " Überschrift des Fensters
               initial_folder  = 'c:\temp\'  " Default Pfad
    IMPORTING  selected_folder = p_frnt     " Rückgabefeld: gewählter Pfad
    EXCEPTIONS cntl_error      = 1
               OTHERS          = 2.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form at_screen_output
*&---------------------------------------------------------------------*
FORM at_screen_output.
  LOOP AT SCREEN.
    IF screen-group1 = 'Z01'.
      p_ta = condense( val  = p_ta
                       from = ` `
                       to   = `` ).
      MODIFY SCREEN.
    ENDIF.
    IF p_r01 <> 'X'.
      IF screen-group1 = 'Z03'.
        screen-input     = 0.
        screen-output    = 0.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form adjust_table
*&---------------------------------------------------------------------*
FORM adjust_table
  TABLES a_tab
  USING  VALUE(a_length)     TYPE i
         VALUE(a_first_line) TYPE i
         VALUE(a_last_line)  TYPE i.

  DATA lv_length  TYPE i.
  DATA lv_index   TYPE i.
  DATA lv_offset  TYPE i.
  DATA lv_rest    TYPE i.
  DATA lv_type    TYPE c LENGTH 1.
  DATA temp_index TYPE f.

  IF a_first_line < 1.
    a_first_line = 1.
  ENDIF.
  IF a_last_line < 1.
    a_last_line = lines( a_tab ).
  ENDIF.

  FIELD-SYMBOLS <line>.

  ASSIGN COMPONENT 1 OF STRUCTURE a_tab TO <line>.
  DESCRIBE FIELD <line> TYPE lv_type.

  IF lv_type = 'C'.
    DESCRIBE FIELD <line> LENGTH lv_length IN CHARACTER MODE.
  ELSE.
    DESCRIBE FIELD <line> LENGTH lv_length IN BYTE MODE.
  ENDIF.
  lv_offset = a_length MOD lv_length.
  temp_index = ( ( a_length + lv_length - 1 ) DIV lv_length )
               + a_first_line - 1.
  lv_index = temp_index.
  IF lv_offset > 0.
    lv_rest = lv_length - lv_offset.
    READ TABLE a_tab INDEX lv_index.
    IF sy-subrc = 0.
      ASSIGN <line>+lv_offset(lv_rest) TO <line>.
      CLEAR <line>.
      MODIFY a_tab INDEX lv_index.
    ENDIF.
  ENDIF.
  lv_index += 1.
  LOOP AT a_tab FROM lv_index TO a_last_line.
    DELETE a_tab.
  ENDLOOP.
ENDFORM.
