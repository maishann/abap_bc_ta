*&---------------------------------------------------------------------*
*& Include          ZBC_TRANSPORT_UP_DOWN_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INIT
*&---------------------------------------------------------------------*
FORM init.
  DATA lv_variant TYPE rsvar-variant.

  " --- determine saptrans
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_TRANS'
       ID 'VALUE' FIELD p_appl.

  vt_ta    = 'Auftrag/Aufgabe'(011).
  vt_b01   = 'Datei kopieren'(001).
  vt_b02   = 'Richtung'(002).
  vt_b03   = 'Import Optionen'(007).
  vt_frnt  = 'Pfad auf Frontend'(003).
  vt_appl  = 'Pfad auf Applikation'(004).
  vt_r01   = 'Frontend --> Application'(005).
  vt_r02   = 'Application --> Frontend'(006).
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
*&      Form  AT_SELECTION_SCREEN_FOR_FRNT
*&---------------------------------------------------------------------*
FORM at_selection_screen_for_frnt.
  " ---Suchhilfe nach Datei auf Frontend
  CALL FUNCTION 'TMP_GUI_BROWSE_FOR_FOLDER'
    EXPORTING  window_title    = 'Auswahl'   " Überschrift des Fensters
               initial_folder  = 'c:\temp\'  " Default Pfad
    IMPORTING  selected_folder = p_frnt     " Rückgabefeld: gewählter Pfad
    EXCEPTIONS cntl_error      = 1
               OTHERS          = 2.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_REQUEST
*&---------------------------------------------------------------------*
FORM download_request.
  " --- Aufbau COFILE
  SEARCH p_appl FOR '/'.
  IF sy-subrc = 0.
    CONCATENATE p_appl '/cofiles/' p_ta+3 '.' p_ta(3) INTO gv_fileapp.
  ELSE.
    CONCATENATE p_appl '\cofiles\' p_ta+3 '.' p_ta(3) INTO gv_fileapp.
  ENDIF.
  CONCATENATE p_frnt '\' p_ta+3 '.' p_ta(3) INTO gv_filefro.
  " --- Download ASCII-Datei vom Applikationsserver auf den Front-End
  CALL FUNCTION 'ZBC_FILE_DL_ASCII'
    EXPORTING  i_file_front_end    = gv_filefro
               i_file_appl         = gv_fileapp
               i_file_overwrite    = space
    EXCEPTIONS fe_file_open_error  = 1
               fe_file_exists      = 2
               fe_file_write_error = 3
               ap_no_authority     = 4
               ap_file_open_error  = 5
               ap_file_empty       = 6
               OTHERS              = 7.
  IF sy-subrc <> 0 AND sy-subrc <> 2.
    MESSAGE e014(cq99).
  ENDIF.
  " --- Aufbau DATA
  SEARCH p_appl FOR '/'.
  IF sy-subrc = 0.
    CONCATENATE p_appl '/data/R' p_ta+4 '.' p_ta(3) INTO gv_fileapp.
  ELSE.
    CONCATENATE p_appl '\data\R' p_ta+4 '.' p_ta(3) INTO gv_fileapp.
  ENDIF.
  CONCATENATE p_frnt '\R' p_ta+4 '.' p_ta(3) INTO gv_filefro.
  " --- Download Binär-Datei vom Applikationsserver auf den Front-End
  CALL FUNCTION 'ZBC_FILE_DOWNLOAD_BIN'
    EXPORTING  i_file_front_end    = gv_filefro
               i_file_appl         = gv_fileapp
               i_file_overwrite    = space
    EXCEPTIONS fe_file_open_error  = 1
               fe_file_exists      = 2
               fe_file_write_error = 3
               ap_no_authority     = 4
               ap_file_open_error  = 5
               ap_file_empty       = 6
               OTHERS              = 7.
  IF sy-subrc <> 0 AND sy-subrc <> 2.
    MESSAGE e014(cq99).
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_REQUEST
*&---------------------------------------------------------------------*
FORM upload_request.
  " --- Aufbau COFILE
  SEARCH p_appl FOR '/'.
  IF sy-subrc = 0.
    CONCATENATE p_appl '/cofiles/' p_ta+3 '.' p_ta(3) INTO gv_fileapp.
  ELSE.
    CONCATENATE p_appl '\cofiles\' p_ta+3 '.' p_ta(3) INTO gv_fileapp.
  ENDIF.
  CONCATENATE p_frnt '\' p_ta+3 '.' p_ta(3) INTO gv_filefro.
  " --- Upload einer ASCII-Datei vom PC zum Applikationsserver
  CALL FUNCTION 'ZBC_FILE_UPLOAD_ASCII'
    EXPORTING  i_file_front_end   = gv_filefro
               i_file_appl        = gv_fileapp
               i_file_overwrite   = space
    EXCEPTIONS fe_file_not_exists = 1
               fe_file_read_error = 2
               ap_no_authority    = 3
               ap_file_open_error = 4
               ap_file_exists     = 5
               OTHERS             = 6.
  IF sy-subrc <> 0 AND sy-subrc <> 5.
    MESSAGE e010(zbc_transport).
  ENDIF.
  " --- Aufbau DATA
  SEARCH p_appl FOR '/'.
  IF sy-subrc = 0.
    CONCATENATE p_appl '/data/R' p_ta+4 '.' p_ta(3) INTO gv_fileapp.
  ELSE.
    CONCATENATE p_appl '\data\R' p_ta+4 '.' p_ta(3) INTO gv_fileapp.
  ENDIF.
  CONCATENATE p_frnt '\R' p_ta+4 '.' p_ta(3) INTO gv_filefro.

  " --- Upload einer Binär-Datei vom PC zum Applikationsserver
  CALL FUNCTION 'ZBC_FILE_UPLOAD_BIN'
    EXPORTING  i_file_front_end   = gv_filefro
               i_file_appl        = gv_fileapp
               i_file_overwrite   = space
    EXCEPTIONS fe_file_not_exists = 1
               fe_file_read_error = 2
               ap_no_authority    = 3
               ap_file_open_error = 4
               ap_file_exists     = 5
               OTHERS             = 6.
  CASE sy-subrc.
    WHEN 1.
      " --- Datei existiert nicht
      MESSAGE e106(zbc_transport).
    WHEN 2.
      " ---> Datei kann nicht gelesen werden.
      MESSAGE e107(zbc_transport).
    WHEN 3.
      MESSAGE e108(zbc_transport).
    WHEN 4.
      " ---> Datei kann nicht gelesen werden.
      MESSAGE e107(zbc_transport).
    WHEN 6.
      " ---> Datei kann nicht gelesen werden.
      MESSAGE e107(zbc_transport).
    WHEN OTHERS.
  ENDCASE.
  IF sy-subrc <> 0 AND sy-subrc <> 5.
    MESSAGE e010(zbc_transport).
  ELSEIF p_append <> space AND p_import = space.
    TRY.
        lcl_main=>append_request( ).
      CATCH lcx_error INTO gc_error.
        gc_error->handler( lcx_error=>gc_error ).
    ENDTRY.
  ELSEIF p_append <> space AND p_import <> space.
    " Append
    TRY.
        lcl_main=>append_request( ).
      CATCH lcx_error INTO gc_error.
        gc_error->handler( lcx_error=>gc_error ).
    ENDTRY.
    " Import
    TRY.
        lcl_main=>import_request( ).
      CATCH lcx_error INTO gc_error.
        gc_error->handler( lcx_error=>gc_error ).
    ENDTRY.
  ELSEIF p_append = space AND p_import <> space.
    TRY.
        lcl_main=>import_request( ).
      CATCH lcx_error INTO gc_error.
        gc_error->handler( lcx_error=>gc_error ).
    ENDTRY.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  AT_SCREEN_OUTPUT
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
