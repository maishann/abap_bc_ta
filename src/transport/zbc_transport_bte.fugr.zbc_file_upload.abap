FUNCTION zbc_file_upload.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CODEPAGE) DEFAULT SPACE
*"     VALUE(FILENAME) TYPE  RLGRAP-FILENAME DEFAULT SPACE
*"     VALUE(FILETYPE) TYPE  RLGRAP-FILETYPE DEFAULT 'ASC'
*"     VALUE(HEADLEN) DEFAULT SPACE
*"     VALUE(LINE_EXIT) DEFAULT SPACE
*"     VALUE(TRUNCLEN) DEFAULT SPACE
*"     VALUE(USER_FORM) DEFAULT SPACE
*"     VALUE(USER_PROG) DEFAULT SPACE
*"     VALUE(DAT_D_FORMAT) TYPE  DATEFORMAT DEFAULT SPACE
*"  EXPORTING
*"     VALUE(FILELENGTH)
*"  TABLES
*"      DATA_TAB
*"  EXCEPTIONS
*"      CONVERSION_ERROR
*"      FILE_OPEN_ERROR
*"      FILE_READ_ERROR
*"      INVALID_TYPE
*"      NO_BATCH
*"      UNKNOWN_ERROR
*"      INVALID_TABLE_WIDTH
*"      GUI_REFUSE_FILETRANSFER
*"      CUSTOMER_ERROR
*"      NO_AUTHORITY
*"      BAD_DATA_FORMAT
*"      HEADER_NOT_ALLOWED
*"      SEPARATOR_NOT_ALLOWED
*"      HEADER_TOO_LONG
*"      UNKNOWN_DP_ERROR
*"      ACCESS_DENIED
*"      DISK_FULL
*"      DP_TIMEOUT
*"      NOT_SUPPORTED_BY_GUI
*"      ERROR_NO_GUI
*"      DP_OUT_OF_MEMORY
*"----------------------------------------------------------------------
  " Local data -------------------------------------------------------
  " Global data declarations

  " Function module documentation

  DATA lv_filename      TYPE string.
  DATA lv_filetype      TYPE char10.
  DATA lv_header_length TYPE i.
  DATA lv_filelength    TYPE i.
  DATA lv_subrc         LIKE sy-subrc.

  " Function body ----------------------------------------------------

  CLEAR filelength.

  lv_filename = filename. " type-casting
  lv_filetype = filetype. " type-casting
  IF     headlen IS SUPPLIED
     AND headlen <> space.
    lv_header_length = headlen. " type-casting
  ENDIF.

  CASE lv_filetype.
    WHEN 'BIN'.
      CALL FUNCTION 'ZBC_FILE_SCMS_UPLOAD'
        EXPORTING  filename = filename
                   binary   = 'X'
                   frontend = 'X'
        IMPORTING  filesize = lv_filelength
        TABLES     data     = data_tab
        EXCEPTIONS error    = 1
                   OTHERS   = 2.

      filelength = lv_filelength. " type-casting
      EXIT.

    WHEN 'ASC'.
      cl_gui_frontend_services=>gui_upload( EXPORTING  filename                = lv_filename
                                                       filetype                = lv_filetype
                                                       header_length           = lv_header_length
                                            IMPORTING  filelength              = lv_filelength
                                            CHANGING   data_tab                = data_tab[]
                                            EXCEPTIONS file_open_error         = 1
                                                       file_read_error         = 2
                                                       no_batch                = 3
                                                       gui_refuse_filetransfer = 4
                                                       invalid_type            = 5
                                                       no_authority            = 6
                                                       unknown_error           = 7
                                                       bad_data_format         = 8
                                                       header_not_allowed      = 9
                                                       separator_not_allowed   = 10
                                                       header_too_long         = 11
                                                       unknown_dp_error        = 12
                                                       access_denied           = 13
                                                       dp_out_of_memory        = 14
                                                       disk_full               = 15
                                                       dp_timeout              = 16
                                                       not_supported_by_gui    = 17
                                                       error_no_gui            = 18
                                                       OTHERS                  = 19 ).
      lv_subrc = sy-subrc.

      IF lv_subrc <> 0.
        CASE lv_subrc.
          WHEN 1.      " FILE_OPEN_ERROR
            RAISE file_open_error.
          WHEN 2.      " FILE_READ_ERROR
            RAISE file_read_error.
          WHEN 3.      " NO_BATCH
            RAISE no_batch.
          WHEN 4.      " GUI_REFUSE_FILETRANSFER
            RAISE gui_refuse_filetransfer.
          WHEN 5.      " INVALID_TYPE
            RAISE invalid_type.
          WHEN 6.      " NO_AUTHORITY
            RAISE no_authority.
          WHEN 7.      " UNKNOWN_ERROR
            RAISE unknown_error.
          WHEN 8.      " BAD_DATA_FORMAT
            RAISE bad_data_format.
          WHEN 9.      " HEADER_NOT_ALLOWED
            RAISE header_not_allowed.
          WHEN 10.     " SEPARATOR_NOT_ALLOWED
            RAISE separator_not_allowed.
          WHEN 11.     " HEADER_TOO_LONG
            RAISE header_too_long.
          WHEN 12.     " UNKNOWN_DP_ERROR
            RAISE unknown_dp_error.
          WHEN 13.     " ACCESS_DENIED
            RAISE access_denied.
          WHEN 14.     " DP_OUT_OF_MEMORY
            RAISE dp_out_of_memory.
          WHEN 15.     " DISK_FULL
            RAISE disk_full.
          WHEN 16.     " DP_TIMEOUT
            RAISE dp_timeout.
          WHEN 17.     " NOT_SUPPORTED_BY_GUI
            RAISE not_supported_by_gui.
          WHEN 18.     " ERROR_NO_GUI
            RAISE error_no_gui.
          WHEN OTHERS. " OTHERS
            RAISE unknown_error.
        ENDCASE.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDFUNCTION.
