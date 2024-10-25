FUNCTION zbc_file_new.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(FNAME) TYPE  C
*"     VALUE(RFC_DESTINATION) TYPE  RFCDES-RFCDEST
*"  EXPORTING
*"     VALUE(BLOB_LENGTH) TYPE  I
*"  TABLES
*"      BLOB
*"  EXCEPTIONS
*"      COMMAND_ERROR
*"      DATA_ERROR
*"      FILE_OPEN_ERROR
*"      FILE_READ_ERROR
*"      NO_BATCH
*"      GUI_REFUSE_FILETRANSFER
*"      INVALID_TYPE
*"      NO_AUTHORITY
*"      UNKNOWN_ERROR
*"----------------------------------------------------------------------
* Global data declarations

  FIELD-SYMBOLS:
    <binary> TYPE x.

  DATA:
    mess       LIKE sy-msgv1,
    len        TYPE i,
    a_filename LIKE  authb-filename,
    a_program  TYPE  authb-program,
    l_filename TYPE string.


  PERFORM ftp_set_logical_path IN PROGRAM saplsdcl.
  CALL FUNCTION 'FTP_CLIENT_TO_R3'
    EXPORTING
      fname           = fname
      rfc_destination = rfc_destination
    IMPORTING
      blob_length     = blob_length
    TABLES
      blob            = blob
    EXCEPTIONS
      command_error   = 1
      data_error      = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    CASE sy-subrc.
* WHEN 1. sys_message_raising command_error.
 WHEN OTHERS. "sys_message_raising data_error.
    ENDCASE.
  ENDIF.

ENDFUNCTION.
