FUNCTION zbc_file_dl_ascii.
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
  TYPES: BEGIN OF lty_tab,
           line TYPE c LENGTH 65000,
         END OF lty_tab.

  " Local data ----------------------------------------------------------
  DATA lt_data_tab     TYPE TABLE OF lty_tab.
  DATA ls_data_line    LIKE LINE OF lt_data_tab.

  " TODO: variable is assigned but never used (ABAP cleaner)
  DATA l_filelength    TYPE i.

  DATA l_filename      LIKE rlgrap-filename.
  DATA l_auth_filename LIKE authb-filename.
  DATA l_return        TYPE c LENGTH 1.
  DATA l_file_empty    TYPE boolean.
  DATA l_mode          TYPE c LENGTH 1.
  DATA l_lines         TYPE i.

  " Function body -------------------------------------------------------

  " init
  e_flg_open_error = abap_false.
  CLEAR e_os_message.

  " check the authority to read the file from the application server
  l_auth_filename = i_file_appl.
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
*               PROGRAM          =
               activity         = sabc_act_read
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

  " check if the file on the front-end exists
  CALL FUNCTION 'WS_QUERY'
    EXPORTING
*               ENVIRONMENT    = ' '
               filename       = i_file_front_end
               query          = 'FE'
*               WINID          = ' '
    IMPORTING  return         = l_return
    EXCEPTIONS inv_query      = 1
               no_batch       = 2
               frontend_error = 3
               OTHERS         = 4.
  IF sy-subrc IS NOT INITIAL.
    RAISE fe_file_open_error.
  ELSE.
    " if file exists continue only if parameter is specified
    IF     l_return         = '1'
       AND i_file_overwrite = false.
      RAISE fe_file_exists.
    ENDIF.                        " l_return is initial and ...
  ENDIF.

  " open the file on the application server
  OPEN DATASET i_file_appl FOR INPUT MESSAGE e_os_message
       IN TEXT MODE ENCODING NON-UNICODE.
  IF sy-subrc IS NOT INITIAL.
    e_flg_open_error = true.
    EXIT.
  ENDIF.

  " write packages to the front-end
  l_file_empty = false.
  l_mode       = space.             " at first we write into the file
  WHILE l_file_empty = false.

    " read all lines from application server file
    CLEAR lt_data_tab. REFRESH lt_data_tab.
    l_lines = 0.
    WHILE     l_file_empty = false
          AND l_lines      < lc_max_transfer_lines.
      READ DATASET i_file_appl INTO ls_data_line.
      IF sy-subrc IS NOT INITIAL.
        l_file_empty = true.
      ELSE.
        l_lines += 1.
        APPEND ls_data_line TO lt_data_tab.
      ENDIF.
    ENDWHILE.

    " check if data table is empty
    READ TABLE lt_data_tab INDEX 1 INTO ls_data_line.
    IF sy-subrc IS INITIAL.

      l_filename = i_file_front_end.
      CALL FUNCTION 'ZBC_FILE_DOWNLOAD'
        EXPORTING
*                   BIN_FILESIZE        = ' '
*                   CODEPAGE            = ' '
                   filename            = l_filename
                   filetype            = lc_fileformat_ascii
                   mode                = l_mode
*                   WK1_N_FORMAT        = ' '
*                   WK1_N_SIZE          = ' '
*                   WK1_T_FORMAT        = ' '
*                   WK1_T_SIZE          = ' '
*                   COL_SELECT          = ' '
*                   COL_SELECTMASK      = ' '
        IMPORTING  filelength          = l_filelength
        TABLES     data_tab            = lt_data_tab
*                   FIELDNAMES          =
        EXCEPTIONS file_open_error     = 1
                   file_write_error    = 2
                   invalid_filesize    = 3
                   invalid_table_width = 4
                   invalid_type        = 5
                   no_batch            = 6
                   unknown_error       = 7
                   OTHERS              = 8.
      IF sy-subrc IS NOT INITIAL.
        CASE sy-subrc.
          WHEN 2.
            CLOSE DATASET i_file_appl.
            RAISE fe_file_open_error.
          WHEN OTHERS.
            CLOSE DATASET i_file_appl.
            RAISE fe_file_write_error.
        ENDCASE.
      ENDIF.

      l_mode = 'A'.                " next lines we append

    ELSE.

      IF l_mode IS INITIAL.           " the first loop
        " file on application server has no contents
        CLOSE DATASET i_file_appl.
        RAISE ap_file_empty.
      ENDIF.

    ENDIF.                            " sy-subrc is initial
  ENDWHILE.                           " l_file_empty = false.

  " close the dataset
  CLOSE DATASET i_file_appl.
ENDFUNCTION.
