FUNCTION zbc_filescms_download.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(FILENAME) TYPE  C
*"     VALUE(FILESIZE) TYPE  I DEFAULT 0
*"     VALUE(BINARY) TYPE  C DEFAULT 'X'
*"     VALUE(MIMETYPE) TYPE  C OPTIONAL
*"     REFERENCE(P_TRANSFER_PHIO) TYPE  SDOK_CHTST OPTIONAL
*"  TABLES
*"      DATA
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
  " Global data declarations

  DATA: BEGIN OF data_bin OCCURS 1,
          line TYPE x LENGTH 1024,
        END OF data_bin.
  DATA destination LIKE rfcdes-rfcdest.
  DATA msg         TYPE c LENGTH 200 ##NEEDED.

  sy_msg_def.

  " start rfc server
  CALL FUNCTION 'SCMS_FE_START_REG_SERVER'
    EXPORTING  destname    = 'SAPFTP'
    IMPORTING  destination = destination
    EXCEPTIONS OTHERS      = 1.
  IF sy-subrc <> 0.
    sys_message_raising error.
  ENDIF.

  IF binary = space.
    " convert text to binary
    CALL FUNCTION 'SCMS_TEXT_TO_BINARY'
      EXPORTING
*                 FIRST_LINE    = 0
*                 LAST_LINE     = 0
*                 APPEND_TO_TABLE = ' '
                 mimetype      = mimetype
      IMPORTING  output_length = filesize
      TABLES     text_tab      = data
                 binary_tab    = data_bin
      EXCEPTIONS OTHERS        = 1.
    IF sy-subrc = 0.
      " transfer data

      " ------ T ------------

      CALL FUNCTION 'SCMS_R3_TO_CLIENT'
        EXPORTING  fname           = filename
                   rfc_destination = destination
                   blob_length     = filesize
                   p_transfer_phio = p_transfer_phio
        TABLES     blob            = data_bin
        EXCEPTIONS command_error   = 1
                   data_error      = 2
                   OTHERS          = 3.

    ENDIF.
  ELSEIF binary = 'X'.
    "  transfer data
    " ------ T ------------

    CALL FUNCTION 'SCMS_R3_TO_CLIENT'
      EXPORTING  fname           = filename
                 rfc_destination = destination
                 blob_length     = filesize
                 p_transfer_phio = p_transfer_phio
      TABLES     blob            = data
      EXCEPTIONS command_error   = 1
                 data_error      = 2
                 OTHERS          = 3.

  ELSEIF binary = 'A'.
    " convert ftext to binary
    CALL FUNCTION 'SCMS_FTEXT_TO_BINARY'
      EXPORTING  input_length  = filesize
*                 FIRST_LINE    = 0
*                 LAST_LINE     = 0
*                 APPEND_TO_TABLE = ' '
                 mimetype      = mimetype
      IMPORTING  output_length = filesize
      TABLES     ftext_tab     = data
                 binary_tab    = data_bin
      EXCEPTIONS OTHERS        = 1.
    IF sy-subrc = 0.
      "  transfer data
      " ------ TIME STAMP PASSING ------------
      " --- OPTIONAL PARAMETER ADDEDED FOR PHIO PROP TRANSFER----------

      CALL FUNCTION 'SCMS_R3_TO_CLIENT'
        EXPORTING  fname           = filename
                   rfc_destination = destination
                   blob_length     = filesize
                   p_transfer_phio = p_transfer_phio
        TABLES     blob            = data_bin
        EXCEPTIONS command_error   = 1
                   data_error      = 2
                   OTHERS          = 3.

    ENDIF.
  ELSE.
    MESSAGE e068(cms) WITH 'BINARY' binary space space INTO msg.
    " Parameterfehler &1 &2 &3 &4
    sy-subrc = 1.
  ENDIF.

  " save error information
  sy_msg_save.

  CALL FUNCTION 'SCMS_FE_STOP_REG_SERVER'
    CHANGING destination = destination.

  " restore error information
  sy_msg_restore.

  " check return code
  IF sy-subrc <> 0.
    sys_message_raising error.
  ENDIF.
ENDFUNCTION.
