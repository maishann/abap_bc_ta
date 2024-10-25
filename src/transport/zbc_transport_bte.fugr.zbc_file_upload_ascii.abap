FUNCTION zbc_file_upload_ascii.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_FILE_FRONT_END) TYPE  RLGRAP-FILENAME
*"     VALUE(I_FILE_APPL) TYPE  AUTHB-FILENAME
*"     REFERENCE(I_FILE_OVERWRITE) TYPE  BOOLE_D OPTIONAL
*"  EXPORTING
*"     VALUE(E_FLG_OPEN_ERROR) TYPE  BOOLE_D
*"     VALUE(E_OS_MESSAGE) TYPE  C
*"  EXCEPTIONS
*"      FE_FILE_NOT_EXISTS
*"      FE_FILE_READ_ERROR
*"      AP_NO_AUTHORITY
*"      AP_FILE_OPEN_ERROR
*"      AP_FILE_EXISTS
*"----------------------------------------------------------------------
  " Local data ----------------------------------------------------------

  " Global data declarations

  " Function module documentation

  " TODO: variable is assigned but never used (ABAP cleaner)
  DATA l_filelength    TYPE i.
  DATA l_data_tab(256) TYPE c OCCURS 100000 WITH HEADER LINE.
  DATA l_filename      LIKE rlgrap-filename.
  DATA l_auth_filename LIKE authb-filename.

  " Function body -------------------------------------------------------
  " init
  e_flg_open_error = false.
  CLEAR e_os_message.

  " check the authority to write the file to the application server
  l_auth_filename = i_file_appl.
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
*               PROGRAM          =
               activity         = sabc_act_write
               filename         = l_auth_filename
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

  TRY.

      " open the file on the application server for reading to check if the
      " file exists on the application server
      OPEN DATASET i_file_appl FOR INPUT MESSAGE e_os_message
           IN TEXT MODE ENCODING NON-UNICODE.
      IF sy-subrc IS INITIAL.
        IF i_file_overwrite = false.
          CLOSE DATASET i_file_appl.
          RAISE ap_file_exists.
        ENDIF.
      ENDIF.
      CLOSE DATASET i_file_appl.

    " catch exceptions
    CATCH cx_root.

  ENDTRY.

  " open dataset for writing
  OPEN DATASET i_file_appl FOR OUTPUT MESSAGE e_os_message
       IN TEXT MODE ENCODING NON-UNICODE.
  IF sy-subrc IS NOT INITIAL.

    e_flg_open_error = true.

  ELSE.

    " upload the file
    l_filename = i_file_front_end.
    CALL FUNCTION 'ZBC_FILE_UPLOAD'
      EXPORTING
*                 CODEPAGE                = ' '
                 filename                = l_filename
                 filetype                = lc_fileformat_ascii
*                 HEADLEN                 = ' '
*                 LINE_EXIT               = ' '
*                 TRUNCLEN                = ' '
*                 USER_FORM               = ' '
*                 USER_PROG               = ' '
*                 DAT_D_FORMAT            = ' '
      IMPORTING  filelength              = l_filelength
      TABLES     data_tab                = l_data_tab
      EXCEPTIONS conversion_error        = 1
                 file_open_error         = 2
                 file_read_error         = 3
                 invalid_type            = 4
                 no_batch                = 5
                 unknown_error           = 6
                 invalid_table_width     = 7
                 gui_refuse_filetransfer = 8
                 customer_error          = 9
                 no_authority            = 10
                 bad_data_format         = 11
                 header_not_allowed      = 12
                 separator_not_allowed   = 13
                 header_too_long         = 14
                 unknown_dp_error        = 15
                 access_denied           = 16
                 dp_out_of_memory        = 17
                 disk_full               = 18
                 dp_timeout              = 19
                 not_supported_by_gui    = 20
                 error_no_gui            = 21
                 OTHERS                  = 22.
    IF sy-subrc IS NOT INITIAL.
      CASE sy-subrc.
        WHEN 2.
          RAISE fe_file_not_exists.
        WHEN OTHERS.
          RAISE fe_file_read_error.
      ENDCASE.
    ENDIF.

    " write the file to the application server
    LOOP AT l_data_tab.
      TRANSFER l_data_tab TO i_file_appl.
      " transfer has no exceptions
      " if not sy-subrc is initial.
      " raise ap_file_write_error.
      " endif.
    ENDLOOP.

    " close the dataset
    CLOSE DATASET l_data_tab.

  ENDIF.
ENDFUNCTION.
