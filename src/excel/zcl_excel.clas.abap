class ZCL_EXCEL definition
  public
  final
  create public .

public section.

  class-methods TRANSFORM_EXCEL_TO_ITAB
    importing
      value(IV_FILENAME) type RLGRAP-FILENAME
      value(IV_BEGIN_COL) type I
      value(IV_BEGIN_ROW) type I
      value(IV_END_COL) type I
      value(IV_END_ROW) type I
    returning
      value(RT_TAB) type ISSR_ALSMEX_TABLINE
    raising
      ZCX_EXCEL .
protected section.
ENDCLASS.



CLASS ZCL_EXCEL IMPLEMENTATION.


  METHOD transform_excel_to_itab.
    " --- Check file name
    IF iv_filename NS 'XLS'.
      RAISE EXCEPTION NEW zcx_excel( textid = zcx_excel=>wrong_format
                                     file   = iv_filename ).
    ENDIF.

    " --- Check length file path
    IF strlen( iv_filename ) > 128.
      RAISE EXCEPTION NEW zcx_excel( textid = zcx_excel=>path_too_long ).
    ENDIF.

    " --- Transform Excel to itab
    CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING  filename                = iv_filename
                 i_begin_col             = iv_begin_col
                 i_begin_row             = iv_begin_row
                 i_end_col               = iv_end_col
                 i_end_row               = iv_end_row
      TABLES     intern                  = rt_tab[]
      EXCEPTIONS inconsistent_parameters = 1
                 upload_ole              = 2
                 OTHERS                  = 3.
    IF sy-subrc <> 0.
      " Implement suitable error handling here
      RAISE EXCEPTION NEW zcx_excel( textid = zcx_excel=>transfrom_error ).
    ENDIF.
  ENDMETHOD. "#EC CI_VALPAR
ENDCLASS.
