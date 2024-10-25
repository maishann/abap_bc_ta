FUNCTION zbc_file_download_bin.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_FILE_FRONT_END) TYPE  RLGRAP-FILENAME
*"     REFERENCE(I_FILE_APPL) TYPE  AUTHB-FILENAME
*"     REFERENCE(I_FILE_OVERWRITE) TYPE  BOOLE_D OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_FLG_OPEN_ERROR) TYPE  BOOLE_D
*"     REFERENCE(E_OS_MESSAGE) TYPE  C
*"  EXCEPTIONS
*"      FE_FILE_OPEN_ERROR
*"      FE_FILE_EXISTS
*"      FE_FILE_WRITE_ERROR
*"      AP_NO_AUTHORITY
*"      AP_FILE_OPEN_ERROR
*"      AP_FILE_EMPTY
*"----------------------------------------------------------------------
  " Local data ----------------------------------------------------------

  " Global data declarations

  " Function module documentation

  DATA lv_filelength    TYPE i.
  DATA lv_orln          TYPE i.
  DATA lt_data_tab      LIKE zbc_filestruc OCCURS 10 WITH HEADER LINE.
  DATA lv_filename      TYPE string.
  DATA lv_auth_filename LIKE authb-filename.
  DATA lv_return        TYPE c LENGTH 1.
  " TODO: variable is assigned but never used (ABAP cleaner)
  DATA lv_lines         TYPE i.

  " Function body -------------------------------------------------------

  " init
  e_flg_open_error = abap_false.
  CLEAR e_os_message.

  " check the authority to read the file from the application server
  lv_auth_filename = i_file_appl.
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
*               PROGRAM          =
               activity         = sabc_act_read
               filename         = lv_auth_filename
    EXCEPTIONS no_authority     = 1
               activity_unknown = 2
               OTHERS           = 3.
  IF sy-subrc IS NOT INITIAL.
    CASE sy-subrc.
      WHEN 1.
        " no auhtority
        RAISE ap_no_authority.
      WHEN OTHERS.
        RAISE ap_file_open_error.
    ENDCASE.
  ENDIF.
  lv_filename = i_file_front_end.

  " check if the file on the front-end exists
  cl_gui_frontend_services=>file_exist( EXPORTING  file                 = lv_filename
                                        RECEIVING  result               = lv_return
                                        EXCEPTIONS cntl_error           = 1
                                                   error_no_gui         = 2
                                                   wrong_parameter      = 3
                                                   not_supported_by_gui = 4
                                                   OTHERS               = 5 ).
  " if file exists continue only if parameter is specified
  IF sy-subrc = 0 AND lv_return = 'X'.
    IF i_file_overwrite = false.
      RAISE fe_file_exists.
    ENDIF.
  ELSEIF sy-subrc <> 0.
    RAISE fe_file_open_error.
  ENDIF.                          " not sy-subrc is initial.

  " open the file on the application server
  OPEN DATASET i_file_appl FOR INPUT MESSAGE e_os_message
       IN BINARY MODE.
  IF sy-subrc IS NOT INITIAL.
    e_flg_open_error = true.
    EXIT.
  ENDIF.
  CLOSE DATASET i_file_appl.

  " read data from application server
  CALL FUNCTION 'ZBC_FILE_RAWDATAREAD'
    EXPORTING  i_file           = i_file_appl
    IMPORTING  e_file_size      = lv_orln
               e_lines          = lv_lines
    TABLES     e_rcgrepfile_tab = lt_data_tab
    EXCEPTIONS no_permission    = 1
               open_failed      = 2
               OTHERS           = 3.
  IF sy-subrc IS NOT INITIAL.
    CASE sy-subrc.
      WHEN 1.
        " no auhtority
        RAISE ap_no_authority.
      WHEN OTHERS.
        RAISE ap_file_open_error.
    ENDCASE.
  ENDIF.

  " check if data table is empty
  READ TABLE lt_data_tab INDEX 1.
  IF sy-subrc IS INITIAL.
    lv_filename   = i_file_front_end.
    lv_filelength = lv_orln.

    CALL FUNCTION 'ZBC_FILESCMS_DOWNLOAD'
      EXPORTING  filename = i_file_front_end
                 filesize = lv_filelength
                 binary   = 'X'
*                 MIMETYPE =
*                 P_TRANSFER_PHIO =
      TABLES     data     = lt_data_tab
      EXCEPTIONS error    = 1
                 OTHERS   = 2.

    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
* WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.

    " file on application server has no contents
    RAISE ap_file_empty.

  ENDIF.
ENDFUNCTION.
