FUNCTION zbc_file_rawdatawrite.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FILE) TYPE  AUTHB-FILENAME
*"     REFERENCE(I_FILE_SIZE) TYPE  I OPTIONAL
*"     REFERENCE(I_LINES) TYPE  I DEFAULT 0
*"     REFERENCE(I_FILE_OVERWRITE) TYPE  BOOLE_D OPTIONAL
*"  TABLES
*"      I_RCGREPFILE_TAB STRUCTURE  ZBC_FILESTRUC
*"  EXCEPTIONS
*"      NO_PERMISSION
*"      OPEN_FAILED
*"      AP_FILE_EXISTS
*"----------------------------------------------------------------------
  " lokal data -----------------------------------------------------------
  " Global data declarations

  " Function module documentation

  DATA lv_file         TYPE authb-filename.
  DATA l_len           TYPE i.
  DATA l_all_lines_len TYPE i.
  DATA l_diff_len      TYPE i.

  " function body --------------------------------------------------------
  lv_file = i_file.
  " check the authority for file
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
*               PROGRAM          =
               activity         = sabc_act_write
               filename         = lv_file
    EXCEPTIONS no_authority     = 1
               activity_unknown = 2
               OTHERS           = 3.
  IF sy-subrc <> 0.
    RAISE no_permission.
  ENDIF.

  " Begin Correction 0202B0300F01 05.10.1998 BS --------------------------
  " check if file exists if we arn't allowed to overwrite file
  IF i_file_overwrite = false.
    OPEN DATASET i_file FOR INPUT IN BINARY MODE.
    IF sy-subrc <> 0.
      " nothing
    ELSE.
      CLOSE DATASET i_file.
      RAISE ap_file_exists.
    ENDIF.
    CLOSE DATASET i_file.
  ENDIF.
  " End Correction 0202B0300F01 05.10.1998 MS ----------------------------

  " open dataset for writing
  OPEN DATASET i_file FOR OUTPUT IN BINARY MODE.
  IF sy-subrc IS NOT INITIAL.
    RAISE open_failed.
  ELSE.

    l_len = lg_max_len.
    LOOP AT i_rcgrepfile_tab.
      " last line is shorter perhaps
      IF sy-tabix = i_lines.
        l_all_lines_len = lg_max_len * ( i_lines - 1 ).
        l_diff_len = i_file_size - l_all_lines_len.
        l_len = l_diff_len.
      ENDIF.
      " write data in file
      TRANSFER i_rcgrepfile_tab TO i_file LENGTH l_len.
    ENDLOOP.
  ENDIF.

  " close the dataset
  CLOSE DATASET i_file.
ENDFUNCTION.
