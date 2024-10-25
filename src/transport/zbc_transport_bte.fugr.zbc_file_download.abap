FUNCTION zbc_file_download.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(BIN_FILESIZE) DEFAULT SPACE
*"     VALUE(CODEPAGE) DEFAULT SPACE
*"     VALUE(FILENAME) DEFAULT SPACE
*"     VALUE(FILETYPE) DEFAULT 'ASC'
*"     VALUE(MODE) DEFAULT SPACE
*"     VALUE(WK1_N_FORMAT) DEFAULT SPACE
*"     VALUE(WK1_N_SIZE) DEFAULT SPACE
*"     VALUE(WK1_T_FORMAT) DEFAULT SPACE
*"     VALUE(WK1_T_SIZE) DEFAULT SPACE
*"     VALUE(COL_SELECT) DEFAULT SPACE
*"     VALUE(COL_SELECTMASK) DEFAULT SPACE
*"     VALUE(NO_AUTH_CHECK) DEFAULT SPACE
*"     VALUE(TRUNC_BLANKS) TYPE  CHAR01 DEFAULT SPACE
*"  EXPORTING
*"     VALUE(FILELENGTH)
*"  TABLES
*"      DATA_TAB
*"  EXCEPTIONS
*"      FILE_OPEN_ERROR
*"      FILE_WRITE_ERROR
*"      INVALID_FILESIZE
*"      INVALID_TYPE
*"      NO_BATCH
*"      UNKNOWN_ERROR
*"      INVALID_TABLE_WIDTH
*"      GUI_REFUSE_FILETRANSFER
*"      CUSTOMER_ERROR
*"      NO_AUTHORITY
*"      HEADER_NOT_ALLOWED
*"      SEPARATOR_NOT_ALLOWED
*"      HEADER_TOO_LONG
*"      DP_ERROR_CREATE
*"      DP_ERROR_SEND
*"      DP_ERROR_WRITE
*"      UNKNOWN_DP_ERROR
*"      ACCESS_DENIED
*"      DP_OUT_OF_MEMORY
*"      DISK_FULL
*"      DP_TIMEOUT
*"      FILE_NOT_FOUND
*"      DATAPROVIDER_EXCEPTION
*"      CONTROL_FLUSH_ERROR
*"      NOT_SUPPORTED_BY_GUI
*"      ERROR_NO_GUI
*"----------------------------------------------------------------------
  " Local data ----------------------------------------------------------

  " Global data declarations

  " Function module documentation

  CLASS cl_gui_frontend_services DEFINITION LOAD.

  DATA l_bin_filesize  TYPE i.
  DATA filename_string TYPE string.
  DATA filetype_char10 TYPE char10.
  DATA filelength_int  TYPE i.
  DATA append          TYPE char01.

  DATA l_seperator     TYPE char01.

  " Begin correction 615864 15.05.2003 -----------------------------------
  DATA l_subrc         LIKE sy-subrc.
  DATA l_gui_download  TYPE tfdir-funcname.
  DATA l_codepage      TYPE abap_encod.
  DATA l_params_tab    LIKE rfc_funint OCCURS 1 WITH HEADER LINE.

  " End correction 615864 15.05.2003 -------------------------------------

  " Function body -------------------------------------------------------

  filename_string = filename. " type-casting
  filetype_char10 = filetype. " type-casting
  IF mode = 'A'.
    append = 'X'.
  ENDIF.
  l_bin_filesize = bin_filesize. " type-casting

  " filetype DAT is not supported any more
  IF filetype_char10 = 'DAT'.
    l_seperator = 'X'.
    filetype_char10 = 'ASC'.
  ELSE.
    CLEAR l_seperator.
  ENDIF.

  " Begin correction 615864 15.05.2003 -----------------------------------
  " check if codepage format is correct
  CASE codepage.
    WHEN 'UTF-16-BE'.
      codepage = '4102'.
    WHEN 'UTF-16-LE'.
      codepage = '4103'.
    WHEN 'UTF-16'.
      codepage = '4102'.
    WHEN 'UTF-8'.
      codepage = '4110'.

  ENDCASE.

  IF codepage CO '0123456789 '.
    l_codepage = codepage.
    " check if GUI-DOWNLOAD has got CODEPGAE parameter
    l_subrc = 0.
    l_gui_download = 'GUI_DOWNLOAD'.                        "#EC *

    CALL FUNCTION 'RFC_GET_FUNCTION_INTERFACE'
      EXPORTING  funcname      = l_gui_download
*                 LANGUAGE      = SY-LANGU
*                 NONE_UNICODE_LENGTH = ' '
      TABLES     params        = l_params_tab
      EXCEPTIONS fu_not_found  = 1
                 nametab_fault = 2
                 OTHERS        = 3.
    IF sy-subrc <> 0.
      CLEAR l_codepage.
    ELSE.
      READ TABLE l_params_tab WITH KEY parameter = 'CODEPAGE'. "#EC*
      IF sy-subrc <> 0.
        CLEAR l_codepage.
      ENDIF.
    ENDIF.
  ENDIF.
  IF l_codepage IS INITIAL OR l_codepage = space.
    " End correction 615864 15.05.2003 -------------------------------------

    cl_gui_frontend_services=>gui_download( EXPORTING  bin_filesize            = l_bin_filesize
                                                       filename                = filename_string
                                                       filetype                = filetype_char10
                                                       append                  = append
                                                       write_field_separator   = l_seperator
*                                                       HEADER                  = '00'
                                                       trunc_trailing_blanks   = trunc_blanks
*                                                       WRITE_LF                = 'X'
                                                       col_select              = col_select
                                                       col_select_mask         = col_selectmask
                                                       codepage                = l_codepage
                                            IMPORTING  filelength              = filelength_int
                                            CHANGING   data_tab                = data_tab[]
                                            EXCEPTIONS file_write_error        = 1
                                                       no_batch                = 2
                                                       gui_refuse_filetransfer = 3
                                                       invalid_type            = 4
                                                       no_authority            = 5
                                                       unknown_error           = 6
                                                       header_not_allowed      = 7
                                                       separator_not_allowed   = 8
                                                       filesize_not_allowed    = 9
                                                       header_too_long         = 10
                                                       dp_error_create         = 11
                                                       dp_error_send           = 12
                                                       dp_error_write          = 13
                                                       unknown_dp_error        = 14
                                                       access_denied           = 15
                                                       dp_out_of_memory        = 16
                                                       disk_full               = 17
                                                       dp_timeout              = 18
                                                       file_not_found          = 19
                                                       dataprovider_exception  = 20
                                                       control_flush_error     = 21
                                                       not_supported_by_gui    = 22
                                                       error_no_gui            = 23
                                                       OTHERS                  = 24 ).
    " Begin correction 615864 15.05.2003 -----------------------------------
    IF sy-subrc <> 0.
      l_subrc = sy-subrc.
    ENDIF.
  ELSE.
    CALL FUNCTION l_gui_download
      EXPORTING  bin_filesize            = l_bin_filesize
                 filename                = filename_string
                 filetype                = filetype_char10
                 append                  = append
                 write_field_separator   = l_seperator
*                 HEADER                  = '00'
                 trunc_trailing_blanks   = trunc_blanks
                 col_select              = col_select
                 col_select_mask         = col_selectmask
                 codepage                = l_codepage
      IMPORTING  filelength              = filelength_int
      TABLES     data_tab                = data_tab[]
      EXCEPTIONS file_write_error        = 1
                 no_batch                = 2
                 gui_refuse_filetransfer = 3
                 invalid_type            = 4
                 no_authority            = 5
                 unknown_error           = 6
                 header_not_allowed      = 7
                 separator_not_allowed   = 8
                 filesize_not_allowed    = 9
                 header_too_long         = 10
                 dp_error_create         = 11
                 dp_error_send           = 12
                 dp_error_write          = 13
                 unknown_dp_error        = 14
                 access_denied           = 15
                 dp_out_of_memory        = 16
                 disk_full               = 17
                 dp_timeout              = 18
                 file_not_found          = 19
                 dataprovider_exception  = 20
                 control_flush_error     = 21
                 OTHERS                  = 22.
    IF sy-subrc <> 0.
      l_subrc = sy-subrc.
    ENDIF.
  ENDIF.
  IF l_subrc = 0.
    " End correction 615864 15.05.2003 -------------------------------------
    filelength = filelength_int. " type-casting
  ELSE.
    CASE sy-subrc.
      WHEN 1.
        RAISE file_write_error.
      WHEN 2.
        RAISE no_batch.
      WHEN 3.
        RAISE gui_refuse_filetransfer.
      WHEN 4.
        RAISE invalid_type.
      WHEN 5.
        RAISE no_authority.
      WHEN 6.
        RAISE unknown_error.
      WHEN 7.
        RAISE header_not_allowed.
      WHEN 8.
        RAISE separator_not_allowed.
      WHEN 9.
        RAISE invalid_filesize.
      WHEN 10.
        RAISE header_too_long.
      WHEN 11.
        RAISE dp_error_create.
      WHEN 12.
        RAISE dp_error_send.
      WHEN 13.
        RAISE dp_error_write.
      WHEN 14.
        RAISE unknown_dp_error.
      WHEN 15.
        RAISE file_write_error.
      WHEN 16.
        RAISE dp_out_of_memory.
      WHEN 17.
        RAISE disk_full.
      WHEN 18.
        RAISE dp_timeout.
      WHEN 19.
        RAISE file_not_found.
      WHEN 20.
        RAISE dataprovider_exception.
      WHEN 21.
        RAISE control_flush_error.
      WHEN 22.
        RAISE not_supported_by_gui.
      WHEN 23.
        RAISE error_no_gui.
      WHEN OTHERS.
        RAISE unknown_error.
    ENDCASE.
  ENDIF.  " sy-subrc = 0
ENDFUNCTION.
