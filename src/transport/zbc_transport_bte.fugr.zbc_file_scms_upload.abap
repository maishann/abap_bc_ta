FUNCTION zbc_file_scms_upload.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(FILENAME) TYPE  C
*"     VALUE(BINARY) TYPE  C DEFAULT 'X'
*"     VALUE(FRONTEND) TYPE  C DEFAULT 'X'
*"     REFERENCE(MIMETYPE) TYPE  C OPTIONAL
*"     VALUE(VSCAN_PROFILE) TYPE  VSCAN_PROFILE DEFAULT
*"       '/SCMS/KPRO_CREATE'
*"  EXPORTING
*"     VALUE(FILESIZE) TYPE  I
*"  TABLES
*"      DATA
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
  " Global data declarations

  FIELD-SYMBOLS <text> TYPE c.
  FIELD-SYMBOLS <bin>  TYPE x.

  DATA: BEGIN OF data_bin OCCURS 1,
          line TYPE x LENGTH 1024,
        END OF data_bin.
  DATA destination LIKE rfcdes-rfcdest.
  DATA line_size   TYPE i.
  DATA rest        TYPE i.
  DATA msg         TYPE c LENGTH 200 ##NEEDED.

  sy_msg_def.

  IF frontend = 'X'.
    " start rfc server
    CALL FUNCTION 'SCMS_FE_START_REG_SERVER'
      EXPORTING
        destname    = 'SAPFTP'
      IMPORTING
        destination = destination
      EXCEPTIONS
        OTHERS      = 1.
    IF sy-subrc <> 0.
      sys_message_raising error.
    ENDIF.
  ELSE.
    destination = 'SAPFTPA'.
  ENDIF.

  CLEAR data[].
  IF binary = space.
    " transfer data
    CALL FUNCTION 'SCMS_CLIENT_TO_R3'
      EXPORTING
        fname           = filename
        rfc_destination = destination
        vscan_profile   = vscan_profile
      IMPORTING
        blob_length     = filesize
      TABLES
        blob            = data_bin
      EXCEPTIONS
        command_error   = 1
        data_error      = 2
        OTHERS          = 3.
    IF sy-subrc = 0.
      " convert binary to text
      CALL FUNCTION 'SCMS_BINARY_TO_TEXT'
        EXPORTING
          input_length  = filesize
*         FIRST_LINE    = 0
*         LAST_LINE     = 0
*         APPEND_TO_TABLE = ' '
          mimetype      = mimetype
*         WRAP_LINES    = ' '
        IMPORTING
          output_length = filesize
        TABLES
          binary_tab    = data_bin
          text_tab      = data
        EXCEPTIONS
          OTHERS        = 1.
      IF sy-subrc <> 0.
        sys_message_raising error.
      ENDIF.
    ENDIF.
  ELSEIF binary = 'A'.
    " transfer data
    CALL FUNCTION 'SCMS_CLIENT_TO_R3'
      EXPORTING
        fname           = filename
        rfc_destination = destination
        vscan_profile   = vscan_profile
      IMPORTING
        blob_length     = filesize
      TABLES
        blob            = data_bin
      EXCEPTIONS
        command_error   = 1
        data_error      = 2
        OTHERS          = 3.
    IF sy-subrc = 0.
      " convert binary to text
      CALL FUNCTION 'SCMS_BINARY_TO_FTEXT'
        EXPORTING
          input_length  = filesize
*         FIRST_LINE    = 0
*         LAST_LINE     = 0
*         APPEND_TO_TABLE = ' '
          mimetype      = mimetype
*         WRAP_LINES    = ' '
        IMPORTING
          output_length = filesize
        TABLES
          binary_tab    = data_bin
          ftext_tab     = data
        EXCEPTIONS
          OTHERS        = 1.
      IF sy-subrc <> 0.
        sys_message_raising error.
      ENDIF.
    ENDIF.
  ELSEIF binary = 'X'.

    CALL FUNCTION 'ZBC_FILE_NEW'
      EXPORTING
        fname                   = filename
        rfc_destination         = destination
      IMPORTING
        blob_length             = filesize
      TABLES
        blob                    = data
      EXCEPTIONS
        command_error           = 1
        data_error              = 2
        file_open_error         = 3
        file_read_error         = 4
        no_batch                = 5
        gui_refuse_filetransfer = 6
        invalid_type            = 7
        no_authority            = 8
        unknown_error           = 9
        OTHERS                  = 10.
    IF sy-subrc = 0.
      ASSIGN COMPONENT 1 OF STRUCTURE data TO <text> TYPE 'C'.
      ASSIGN COMPONENT 1 OF STRUCTURE data TO <bin> TYPE 'X'.
      DESCRIBE FIELD <text> LENGTH line_size IN CHARACTER MODE.
      rest = filesize.
      LOOP AT data.
        IF rest = 0.
          DELETE data.
          CONTINUE.
        ENDIF.
        IF rest < line_size.
          CLEAR <text>+rest.
          MODIFY data.
          rest = 0.
          CONTINUE.
        ENDIF.
        IF binary = 'A'.
          MODIFY data.
        ENDIF.
        rest -= line_size.
      ENDLOOP.
      sy-subrc = 0.
    ENDIF.

  ELSE.
    MESSAGE e068(cms) WITH 'BINARY' binary space space INTO msg.
    " Parameterfehler &1 &2 &3 &4
    sy-subrc = 1.
  ENDIF.

  " save error information
  sy_msg_save.

  CALL FUNCTION 'SCMS_FE_STOP_REG_SERVER'
    CHANGING
      destination = destination.

  " restore error information
  sy_msg_restore.

  " check return code
  IF sy-subrc <> 0.
    sys_message_raising error.
  ENDIF.

  IF binary <> space.
    PERFORM adjust_table
      TABLES data
      USING  filesize
             0
             0.
  ENDIF.
ENDFUNCTION.
