*&---------------------------------------------------------------------*
*& Include          ZBC_TRAN_UP_DOWN_LCL
*&---------------------------------------------------------------------*
TYPE-POOLS sabc.
" #######################################################################
" #                  EXCEPTION-CLASS                                    #
" #######################################################################
" -----------------------------------------------------------------------
"        CLASS lcx_error DEFINITION
" -----------------------------------------------------------------------
CLASS lcx_error DEFINITION INHERITING FROM cx_no_check.
  PUBLIC SECTION.
    CLASS-DATA gc_error   TYPE icon_d VALUE '@5C@'.
    CLASS-DATA gc_warning TYPE icon_d VALUE '@5D@'.
    CLASS-DATA gc_info    TYPE icon_d VALUE '@5B@'.

    METHODS constructor IMPORTING iv_text TYPE csequence.

    METHODS handler
      IMPORTING ip_errortyp TYPE icon_d.

  PRIVATE SECTION.
    DATA text TYPE string.
ENDCLASS.


" -----------------------------------------------------------------------
" CLASS lcx_error IMPLEMENTATION
" -----------------------------------------------------------------------
CLASS lcx_error IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    text = iv_text.
  ENDMETHOD.

  METHOD handler.
    WRITE:/ ip_errortyp AS ICON, text.
    CLEAR text.
  ENDMETHOD.
ENDCLASS.
DATA gc_error TYPE REF TO lcx_error.
" #######################################################################
" #                  CLASS                                              #
" #######################################################################
CLASS lcl_transport DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS append_request.
    CLASS-METHODS import_request.
    CLASS-METHODS download_request.
    CLASS-METHODS upload_request.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF lty_data,
        line TYPE c LENGTH 65000,
      END OF lty_data.
    TYPES tty_data TYPE STANDARD TABLE OF lty_data.
    TYPES:
      BEGIN OF lty_lraw,
        orblk TYPE zbc_lraw,
      END OF lty_lraw.
    TYPES tty_lraw TYPE STANDARD TABLE OF lty_lraw.

    CLASS-DATA mv_fileapp    TYPE authb-filename.
    CLASS-DATA mv_file_front TYPE rlgrap-filename.

    CLASS-METHODS prepare_file_path IMPORTING iv_option TYPE i.
    CLASS-METHODS download_file_ascii.
    CLASS-METHODS upload_file_ascii.
    CLASS-METHODS download_file_bin.
    CLASS-METHODS upload_file_bin.

    CLASS-METHODS download_file_cms IMPORTING VALUE(iv_file_size) TYPE i
                                              VALUE(iv_binary)    TYPE boole_d
                                    CHANGING  VALUE(ct_data)      TYPE tty_lraw.

    CLASS-METHODS upload_file_cms CHANGING VALUE(ct_data)      TYPE tty_lraw
                                           VALUE(cv_file_size) TYPE i.

    CLASS-METHODS check_dataset_exists RETURNING VALUE(rv_return)   TYPE boole_d.
    CLASS-METHODS authority_check      IMPORTING VALUE(iv_activity) TYPE c.
    CLASS-METHODS gui_download         CHANGING  VALUE(data_tab)    TYPE ANY TABLE.
    CLASS-METHODS gui_upload           CHANGING  VALUE(ct_data)     TYPE STANDARD TABLE.

    CLASS-METHODS read_raw_data CHANGING VALUE(ct_data)      TYPE tty_lraw
                                         VALUE(cv_file_size) TYPE i.

    CLASS-METHODS write_raw_data IMPORTING VALUE(iv_lines)     TYPE i
                                           VALUE(iv_file_size) TYPE i
                                 CHANGING  VALUE(ct_data)      TYPE tty_lraw.

ENDCLASS.


" ------------------------------------------------------------------------
" CLASS lcl_transport IMPLEMENTATION
" ------------------------------------------------------------------------
CLASS lcl_transport IMPLEMENTATION.
  METHOD append_request.
    DATA lv_system  TYPE tmssysnam.
    DATA lv_request TYPE trkorr.
    DATA lv_error   TYPE string.

    lv_system  = sy-sysid.
    lv_request = p_ta.

    CALL FUNCTION 'TMS_UI_APPEND_TR_REQUEST'
      EXPORTING  iv_system             = lv_system
                 iv_request            = lv_request
      EXCEPTIONS cancelled_by_user     = 1
                 append_request_failed = 2
                 OTHERS                = 3.
    IF sy-subrc = 1.
      " Abbruch durch User.
      MESSAGE e006(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ELSEIF sy-subrc = 2.
      " Beim Anhängen trat ein Fehler auf.
      MESSAGE e009(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ELSEIF sy-subrc <> 0.
      " Unbekannter Fehler.
      MESSAGE e008(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.
  ENDMETHOD.

  METHOD import_request.
    DATA lv_system  TYPE tmssysnam.
    DATA lv_request TYPE trkorr.
    DATA lv_error   TYPE string.

    " Check Authority STMS
    CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
      EXPORTING  tcode  = 'STMS'
      EXCEPTIONS ok     = 1
                 not_ok = 2
                 OTHERS = 3.
    IF sy-subrc > 1.
      MESSAGE e109(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.

    lv_system  = sy-sysid.
    lv_request = p_ta.

    CALL FUNCTION 'TMS_UI_IMPORT_TR_REQUEST'
      EXPORTING  iv_system             = lv_system
                 iv_request            = lv_request
                 iv_verbose            = 'X'
      EXCEPTIONS cancelled_by_user     = 1
                 import_request_denied = 2
                 import_request_failed = 3
                 OTHERS                = 4.
    IF sy-subrc = 1.
      " Abbruch durch User.
      MESSAGE e006(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ELSEIF sy-subrc = 3.
      " Beim Import trat ein Fehler auf.
      MESSAGE e007(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ELSEIF sy-subrc <> 0.
      " Unbekannter Fehler.
      MESSAGE e008(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.

    CALL FUNCTION 'TMS_UIQ_IMPORT_QUEUE_DISPLAY'
      EXPORTING  iv_system                   = lv_system
      EXCEPTIONS import_queue_display_failed = 1
                 OTHERS                      = 2.
    IF sy-subrc <> 0.
      MESSAGE e110(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.
  ENDMETHOD.

  METHOD download_request.
    prepare_file_path( iv_option = 1 ). " COFILES
    TRY.
        download_file_ascii( ).
      CATCH lcx_error INTO gc_error.
        gc_error->handler( lcx_error=>gc_error ).
    ENDTRY.
    prepare_file_path( iv_option = 2 ). " DATA FILE
    TRY.
        download_file_bin( ).
      CATCH lcx_error INTO gc_error.
        gc_error->handler( lcx_error=>gc_error ).
    ENDTRY.
  ENDMETHOD.

  METHOD prepare_file_path.
    CLEAR: mv_fileapp,
           mv_file_front.
    CASE iv_option.
      WHEN 1. " COFILES
        SEARCH p_appl FOR '/'.
        IF sy-subrc = 0.
          mv_fileapp = |{ p_appl && '/cofiles/' && p_ta+3 && '.' && p_ta(3) }|.
        ELSE.
          mv_fileapp = |{ p_appl && '\cofiles\' && p_ta+3 && '.' && p_ta(3) }|.
        ENDIF.
        mv_file_front = |{ p_frnt && '\' && p_ta+3 && '.' && p_ta(3) }|.
      WHEN 2. " DATA File
        SEARCH p_appl FOR '/'.
        IF sy-subrc = 0.
          mv_fileapp = |{ p_appl && '/data/R' && p_ta+4 && '.' && p_ta(3) }|.
        ELSE.
          mv_fileapp = |{ p_appl && '\data\R' && p_ta+4 && '.' && p_ta(3) }|.
        ENDIF.
        mv_file_front = |{ p_frnt && '\R' && p_ta+4 && '.' && p_ta(3) }|.
      WHEN OTHERS.
        " do nothing
    ENDCASE.
  ENDMETHOD.

  METHOD authority_check.
    DATA lv_error TYPE string.

    " check the authority to read the file from the application server
    CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
      EXPORTING  activity     = iv_activity
                 filename     = mv_fileapp
      EXCEPTIONS no_authority = 1
                 OTHERS       = 3.
    IF sy-subrc <> 0.
      " Keine Berechtigung zum Lesen/Schreiben der Datei.
      MESSAGE e108(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.
  ENDMETHOD.

  METHOD check_dataset_exists.
    DATA lv_file_string TYPE string.
    DATA lv_error       TYPE string.

    lv_file_string = mv_file_front.
    " check if the file on the front-end exists
    cl_gui_frontend_services=>file_exist( EXPORTING  file                 = lv_file_string
                                          RECEIVING  result               = rv_return
                                          EXCEPTIONS cntl_error           = 1
                                                     error_no_gui         = 2
                                                     wrong_parameter      = 3
                                                     not_supported_by_gui = 4
                                                     OTHERS               = 5 ).
    IF sy-subrc <> 0.
      " Datei kann nicht gelesen werden..
      MESSAGE e107(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.
  ENDMETHOD.

  METHOD download_file_ascii.
    DATA lv_error      TYPE string.
    DATA lv_file_empty TYPE boolean.
    DATA lv_mode       TYPE c LENGTH 1.
    DATA lt_data_tab   TYPE lcl_transport=>tty_data.
    DATA ls_data_line  LIKE LINE OF lt_data_tab.
    DATA lv_lines      TYPE i.

    " Authority Check
    authority_check( iv_activity = sabc_act_read ).
    " Dataset exists?
    IF check_dataset_exists( ) = abap_true.
      " Datei ist bereits vorhanden.
      MESSAGE e011(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.

    OPEN DATASET mv_fileapp FOR INPUT
         IN TEXT MODE ENCODING NON-UNICODE.
    IF sy-subrc <> 0.
      " Fehler beim Öffnen der Quelldatei
      MESSAGE e102(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.

    lv_file_empty = abap_false.
    lv_mode       = space.

    WHILE lv_file_empty = abap_false.
      CLEAR lt_data_tab.
      lv_lines = 0.
      WHILE     lv_file_empty = abap_false
            AND lv_lines      < 10000.
        READ DATASET mv_fileapp INTO ls_data_line.
        IF sy-subrc IS NOT INITIAL.
          lv_file_empty = abap_true.
        ELSE.
          lv_lines += 1.
          APPEND ls_data_line TO lt_data_tab.
        ENDIF.
      ENDWHILE.

      READ TABLE lt_data_tab INDEX 1 INTO ls_data_line.
      IF sy-subrc = 0.
        gui_download( CHANGING data_tab = lt_data_tab ).
        lv_mode = 'A'.
      ELSE.
        IF lv_mode IS INITIAL.
          " file on application server has no content
          CLOSE DATASET mv_fileapp.
          " Datei existiert nicht
          MESSAGE e106(zbc_transport) INTO lv_error.
          RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
        ENDIF.

      ENDIF.
    ENDWHILE.
    " Close dataset
    CLOSE DATASET mv_fileapp.
  ENDMETHOD.

  METHOD gui_download.
    DATA lv_filesize     TYPE i VALUE 0.
    DATA filename_string TYPE string.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA filelength_int  TYPE i.
    DATA lv_error        TYPE string.

    filename_string = mv_file_front.

    cl_gui_frontend_services=>gui_download( EXPORTING  bin_filesize            = lv_filesize
                                                       filename                = filename_string
                                                       filetype                = 'ASC'
                                                       append                  = space
                                                       write_field_separator   = space
                                                       trunc_trailing_blanks   = space
                                                       col_select              = space
                                                       col_select_mask         = space
                                                       codepage                = space
                                            IMPORTING  filelength              = filelength_int
                                            CHANGING   data_tab                = data_tab
                                            EXCEPTIONS file_write_error        = 1                    " Datei kann nicht geschrieben werden
                                                       no_batch                = 2                    " Frontend-Funktion im Batch nicht ausführbar.
                                                       gui_refuse_filetransfer = 3                    " falsches Frontend
                                                       invalid_type            = 4                    " Ungültiger Wert für Parameter FILETYPE
                                                       no_authority            = 5                    " Keine Berechtigung für Download
                                                       unknown_error           = 6                    " Unbekannter Fehler
                                                       header_not_allowed      = 7                    " Header ist nicht zulässig.
                                                       separator_not_allowed   = 8                    " Separator ist nicht zulässig.
                                                       filesize_not_allowed    = 9                    " Angabe der Dateigröße nicht zulässig.
                                                       header_too_long         = 10                   " Die Headerinformation ist zur Zeit auf maximal 1023 Bytes be
                                                       dp_error_create         = 11                   " DataProvider kann nicht erzeugt werden
                                                       dp_error_send           = 12                   " Fehler beim Senden der Daten durch DP
                                                       dp_error_write          = 13                   " Fehler beim Schreiben der Daten durch DP
                                                       unknown_dp_error        = 14                   " Fehler beim Aufruf des Dataprovider
                                                       access_denied           = 15                   " Zugriff auf Datei nicht erlaubt.
                                                       dp_out_of_memory        = 16                   " Nicht genug Speicher im Dataprovider
                                                       disk_full               = 17                   " Speichermedium ist voll.
                                                       dp_timeout              = 18                   " Timeout des Dataproviders
                                                       file_not_found          = 19                   " Datei konnte nicht gefunden werden.
                                                       dataprovider_exception  = 20                   " Allgemeiner Ausnahmefehler im Dataprovider
                                                       control_flush_error     = 21                   " Fehler im Controlframework.
                                                       not_supported_by_gui    = 22                   " Nicht unterstützt von GUI
                                                       error_no_gui            = 23                   " GUI nicht verfügbar
                                                       OTHERS                  = 24 ).
    IF sy-subrc <> 0.
      CLOSE DATASET mv_fileapp.
      " Fehler beim Datei-Transfer
      MESSAGE e010(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.
  ENDMETHOD.

  METHOD download_file_bin.
    DATA lv_error     TYPE string.
    DATA lt_data      TYPE lcl_transport=>tty_lraw.
    DATA lv_file_size TYPE i.

    " Authority Check
    authority_check( iv_activity = sabc_act_read ).
    " Dataset exists?
    IF check_dataset_exists( ) = abap_true.
      " Datei ist bereits vorhanden.
      MESSAGE e011(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.

    OPEN DATASET mv_fileapp FOR INPUT IN BINARY MODE.
    IF sy-subrc <> 0.
      " Fehler beim Öffnen der Quelldatei
      MESSAGE e102(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.
    CLOSE DATASET mv_fileapp.

    " RAWDATA
    read_raw_data( CHANGING ct_data      = lt_data[]
                            cv_file_size = lv_file_size ).
    " FILESCMS_DOWNLOAD
    IF line_exists( lt_data[ 1 ] ).
      download_file_cms( EXPORTING iv_file_size = lv_file_size
                                   iv_binary    = 'X'
                         CHANGING  ct_data      = lt_data[] ).
    ELSE.
      " Datei kann nicht gelesen werden.
      MESSAGE e107(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.
  ENDMETHOD.

  METHOD read_raw_data.
    DATA lv_len   TYPE sy-tabix.
    DATA lv_error TYPE string.
    DATA ls_data  LIKE LINE OF ct_data.

    OPEN DATASET mv_fileapp FOR INPUT IN BINARY MODE.
    IF sy-subrc <> 0.
      " Fehler beim Öffnen der Quelldatei
      MESSAGE e102(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.

    DO.
      CLEAR lv_len.
      CLEAR ls_data.
      READ DATASET mv_fileapp INTO ls_data-orblk LENGTH lv_len.
      IF sy-subrc <> 0.
        cv_file_size += lv_len.
        APPEND ls_data TO ct_data.
        EXIT.
      ENDIF.
      cv_file_size += lv_len.
      APPEND ls_data TO ct_data.
    ENDDO.

    CLOSE DATASET mv_fileapp.
  ENDMETHOD.

  METHOD download_file_cms.
    TYPES: BEGIN OF lty_data_bin,
             line TYPE x LENGTH 1024,
           END OF lty_data_bin.
    DATA data_bin          TYPE STANDARD TABLE OF lty_data_bin.
    DATA destination       TYPE rfcdes-rfcdest.
    DATA msg               TYPE c LENGTH 200 ##NEEDED.
    DATA lv_transfer_phiop TYPE sdok_chtst.
    DATA lv_error          TYPE string.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_file_size      TYPE i.

    " start rfc server
    CALL FUNCTION 'SCMS_FE_START_REG_SERVER'
      EXPORTING  destname    = 'SAPFTP'
      IMPORTING  destination = destination
      EXCEPTIONS OTHERS      = 1.
    IF sy-subrc <> 0.
      " sys_message_raising error.
    ENDIF.

    IF iv_binary = space.
      " convert text to binary
      CALL FUNCTION 'SCMS_TEXT_TO_BINARY'
        EXPORTING  mimetype      = space
        IMPORTING  output_length = iv_file_size
        TABLES     text_tab      = ct_data[]
                   binary_tab    = data_bin
        EXCEPTIONS OTHERS        = 1.
      IF sy-subrc = 0.
        " transfer data
        CALL FUNCTION 'SCMS_R3_TO_CLIENT'
          EXPORTING  fname           = mv_file_front
                     rfc_destination = destination
                     blob_length     = iv_file_size
                     p_transfer_phio = lv_transfer_phiop
          TABLES     blob            = data_bin
          EXCEPTIONS command_error   = 1
                     data_error      = 2
                     OTHERS          = 3.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.
      ENDIF.
    ELSEIF iv_binary = 'X'.
      "  transfer data
      CALL FUNCTION 'SCMS_R3_TO_CLIENT'
        EXPORTING  fname           = mv_file_front
                   rfc_destination = destination
                   blob_length     = iv_file_size
                   p_transfer_phio = lv_transfer_phiop
        TABLES     blob            = ct_data[]
        EXCEPTIONS command_error   = 1
                   data_error      = 2
                   OTHERS          = 3.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ELSEIF iv_binary = 'A'.
      " convert ftext to binary
      CALL FUNCTION 'SCMS_FTEXT_TO_BINARY'
        EXPORTING  input_length  = iv_file_size
                   mimetype      = space
        IMPORTING  output_length = lv_file_size
        TABLES     ftext_tab     = ct_data
                   binary_tab    = data_bin
        EXCEPTIONS OTHERS        = 1.
      IF sy-subrc = 0.
        "  transfer data
        CALL FUNCTION 'SCMS_R3_TO_CLIENT'
          EXPORTING  fname           = mv_file_front
                     rfc_destination = destination
                     blob_length     = iv_file_size
                     p_transfer_phio = lv_transfer_phiop
          TABLES     blob            = data_bin
          EXCEPTIONS command_error   = 1
                     data_error      = 2
                     OTHERS          = 3.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.
      ENDIF.
    ELSE.
      MESSAGE e068(cms) WITH 'BINARY' iv_binary space space INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.

    CALL FUNCTION 'SCMS_FE_STOP_REG_SERVER'
      CHANGING destination = destination.
  ENDMETHOD.

  METHOD upload_request.
    prepare_file_path( iv_option = 1 ). " COFILES
    TRY.
        upload_file_ascii( ).
      CATCH lcx_error INTO gc_error.
        gc_error->handler( lcx_error=>gc_error ).
    ENDTRY.
    prepare_file_path( iv_option = 2 ). " DATA FILE
    TRY.
        upload_file_bin( ).
      CATCH lcx_error INTO gc_error.
        gc_error->handler( lcx_error=>gc_error ).
    ENDTRY.

    IF p_append <> space.
      TRY.
          append_request( ).
        CATCH lcx_error INTO gc_error.
      ENDTRY.
    ENDIF.

    IF p_import <> space.
      TRY.
          import_request( ).
        CATCH lcx_error INTO gc_error.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD upload_file_ascii.
    DATA lv_error    TYPE string.
    DATA lt_data_tab TYPE STANDARD TABLE OF c.

    authority_check( iv_activity = sabc_act_write ).

    TRY.
        " open the file on the application server for reading to check if the
        " file exists on the application server
        OPEN DATASET mv_fileapp FOR INPUT IN TEXT MODE ENCODING NON-UNICODE.
        IF sy-subrc IS INITIAL.
          CLOSE DATASET mv_fileapp.
        ENDIF.
        CLOSE DATASET mv_fileapp.
        " catch exceptions
      CATCH cx_root.
    ENDTRY.

    " open dataset for writing
    OPEN DATASET mv_fileapp FOR OUTPUT IN TEXT MODE ENCODING NON-UNICODE.
    IF sy-subrc <> 0.
      " Fehler beim Datei-Transfer
      MESSAGE e010(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ELSE.
      gui_upload( CHANGING ct_data = lt_data_tab[] ).
    ENDIF.

    " write the file to the application server
    LOOP AT lt_data_tab INTO DATA(ls_data_tab).
      TRANSFER ls_data_tab TO mv_fileapp.
      " transfer has no exceptions
      " if not sy-subrc is initial.
      " raise ap_file_write_error.
      " endif.
    ENDLOOP.

    " close the dataset
    " CLOSE DATASET lt_data_tab.
  ENDMETHOD.

  METHOD gui_upload.
    DATA lv_filename TYPE string.
    DATA lv_error    TYPE string.

    lv_filename = mv_file_front.

    cl_gui_frontend_services=>gui_upload( EXPORTING  filename                = lv_filename      " Name der Datei
                                                     filetype                = 'ASC'            " Dateityp (Ascii, Binär)
                                          CHANGING   data_tab                = ct_data          " Übergabetabelle für Datei-Inhalt
                                          EXCEPTIONS file_open_error         = 1                " Datei nicht vorhanden, kann nicht geöffnet werde
                                                     file_read_error         = 2                " Fehler beim Lesen der Datei
                                                     no_batch                = 3                " Frontend-Funktion im Batch nicht ausführbar.
                                                     gui_refuse_filetransfer = 4                " Falsches Frontend oder Fehler im Frontend
                                                     invalid_type            = 5                " Falscher Parameter FILETYPE
                                                     no_authority            = 6                " Keine Berechtigung für Upload
                                                     unknown_error           = 7                " Unbekannter Fehler
                                                     bad_data_format         = 8                " Daten in der Datei können nicht interpretiert werden.
                                                     header_not_allowed      = 9                " Header ist nicht zulässig.
                                                     separator_not_allowed   = 10               " Separator ist nicht zulässig.
                                                     header_too_long         = 11               " Die Headerinformation ist zur Zeit auf maximal 1023 Bytes be
                                                     unknown_dp_error        = 12               " Fehler beim Aufruf des Dataprovider
                                                     access_denied           = 13               " Zugriff auf Datei nicht erlaubt.
                                                     dp_out_of_memory        = 14               " Nicht genug Speicher im Dataprovider
                                                     disk_full               = 15               " Speichermedium ist voll.
                                                     dp_timeout              = 16               " Timeout des Dataproviders
                                                     not_supported_by_gui    = 17               " Nicht unterstützt von GUI
                                                     error_no_gui            = 18               " GUI nicht verfügbar
                                                     OTHERS                  = 19 ).
    IF sy-subrc <> 0.
      " Fehler beim Anlegen der Datei
      MESSAGE e101(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.
  ENDMETHOD.

  METHOD upload_file_bin.
    DATA lt_data      TYPE tty_lraw.
    DATA lv_file_size TYPE i.

    authority_check( iv_activity = sabc_act_write ).

    " open the file on the application server for reading to check if the
    " file exists on the application server
    OPEN DATASET mv_fileapp FOR INPUT IN BINARY MODE.
    IF sy-subrc <> 0.
      CLOSE DATASET mv_fileapp.
    ENDIF.
    CLOSE DATASET mv_fileapp.

    upload_file_cms( CHANGING ct_data      = lt_data[]
                              cv_file_size = lv_file_size ).

    DATA(lv_lines) = lines( lt_data[] ).

    write_raw_data( EXPORTING iv_lines     = lv_lines
                              iv_file_size = lv_file_size
                    CHANGING  ct_data      = lt_data[] ).
  ENDMETHOD.

  METHOD upload_file_cms.
    FIELD-SYMBOLS <text> TYPE c.
    " TODO: variable is assigned but never used (ABAP cleaner)
    FIELD-SYMBOLS <bin>  TYPE x.

    DATA destination TYPE rfcdes-rfcdest.
    DATA line_size   TYPE i.
    DATA rest        TYPE i.

    " start rfc server
    CALL FUNCTION 'SCMS_FE_START_REG_SERVER'
      EXPORTING  destname    = 'SAPFTP'
      IMPORTING  destination = destination
      EXCEPTIONS OTHERS      = 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CLEAR ct_data[].

    PERFORM ftp_set_logical_path IN PROGRAM saplsdcl.
    CALL FUNCTION 'FTP_CLIENT_TO_R3'
      EXPORTING  fname           = mv_file_front
                 rfc_destination = destination
      IMPORTING  blob_length     = cv_file_size
      TABLES     blob            = ct_data
      EXCEPTIONS command_error   = 1
                 data_error      = 2
                 OTHERS          = 3.
    IF sy-subrc = 0.
      ASSIGN COMPONENT 1 OF STRUCTURE ct_data TO <text> CASTING.
      ASSIGN COMPONENT 1 OF STRUCTURE ct_data TO <bin> CASTING.
      DESCRIBE FIELD <text> LENGTH line_size IN CHARACTER MODE.
      rest = cv_file_size.
      LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<ls_data>).
        IF rest = 0.
          CLEAR <ls_data>.
          CONTINUE.
        ENDIF.
        IF rest < line_size.
          CLEAR <text>+rest.
          " <ls_data> = <text>.
          rest = 0.
          CONTINUE.
        ENDIF.
        rest -= line_size.
      ENDLOOP.
      sy-subrc = 0.
    ENDIF.

    CALL FUNCTION 'SCMS_FE_STOP_REG_SERVER'
      CHANGING destination = destination.
    " check return code
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    PERFORM adjust_table
      TABLES ct_data
      USING  cv_file_size
             0
             0.
  ENDMETHOD.

  METHOD write_raw_data.
    DATA lv_error         TYPE string.
    DATA lv_len           TYPE i.
    DATA lv_all_lines_len TYPE i.
    DATA lv_diff_len      TYPE i.

    authority_check( iv_activity = sabc_act_write ).

    OPEN DATASET mv_fileapp FOR INPUT IN BINARY MODE.
    IF sy-subrc <> 0.
      " nothing
    ELSE.
      CLOSE DATASET mv_fileapp.
      " Datei ist bereits vorhanden.
      MESSAGE e011(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ENDIF.
    CLOSE DATASET mv_fileapp.

    " open dataset for writing
    OPEN DATASET mv_fileapp FOR OUTPUT IN BINARY MODE.
    IF sy-subrc IS NOT INITIAL.
      " Fehler beim Öffnen der Quelldatei
      MESSAGE e102(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( iv_text = lv_error ).
    ELSE.

      lv_len = 2550.
      LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<ls_data>).
        " last line is shorter perhaps
        IF sy-tabix = iv_lines.
          lv_all_lines_len = 2550 * ( iv_lines - 1 ).
          lv_diff_len = iv_file_size - lv_all_lines_len.
          lv_len = lv_diff_len.
        ENDIF.
        " write data in file
        TRANSFER <ls_data> TO mv_fileapp LENGTH lv_len.
      ENDLOOP.
    ENDIF.

    CLOSE DATASET mv_fileapp.
  ENDMETHOD.
ENDCLASS.
