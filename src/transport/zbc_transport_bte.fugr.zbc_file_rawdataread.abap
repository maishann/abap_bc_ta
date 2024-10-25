FUNCTION zbc_file_rawdataread.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_FILE) TYPE  AUTHB-FILENAME
*"  EXPORTING
*"     REFERENCE(E_FILE_SIZE) TYPE  I
*"     REFERENCE(E_LINES) TYPE  I
*"  TABLES
*"      E_RCGREPFILE_TAB STRUCTURE  ZBC_FILESTRUC
*"  EXCEPTIONS
*"      NO_PERMISSION
*"      OPEN_FAILED
*"----------------------------------------------------------------------
  " lokal data -----------------------------------------------------------
  " Global data declarations

  " Function module documentation

  DATA l_len      LIKE sy-tabix.
  DATA l_filename LIKE authb-filename.
  " function body --------------------------------------------------------

  l_filename = i_file.

  " check the authority for file
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
*               PROGRAM          =
               activity         = sabc_act_read
               filename         = l_filename(60)
    EXCEPTIONS no_authority     = 1
               activity_unknown = 2
               OTHERS           = 3.
  IF sy-subrc <> 0.
    RAISE no_permission.
  ENDIF.

  " read the raw-file from the appl.server
  OPEN DATASET i_file FOR INPUT IN BINARY MODE.
  IF sy-subrc <> 0.
    RAISE open_failed.
  ENDIF.
  DO.
    CLEAR l_len.
    CLEAR e_rcgrepfile_tab.
    READ DATASET i_file INTO e_rcgrepfile_tab-orblk LENGTH l_len.
    IF sy-subrc <> 0.
      e_file_size += l_len.
      APPEND e_rcgrepfile_tab.
      EXIT.
    ENDIF.
    e_file_size += l_len.
    APPEND e_rcgrepfile_tab.
  ENDDO.

  e_lines = LINES( e_rcgrepfile_tab ).

  CLOSE DATASET i_file.
ENDFUNCTION.
