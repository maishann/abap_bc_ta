class ZCL_DDIC_DOWN definition
  public
  final
  create public .

public section.

  class-methods DDIC_OBJECT_DESCRIPTION
    importing
      value(IV_DDIC_OBJECT) type ANY
    returning
      value(RT_FCAT) type LVC_T_FCAT .
  class-methods FILE_SAVE_DIALOG
    importing
      value(IV_XSTRING) type XSTRING
      value(IV_EXTENSION) type STRING optional
      value(IV_FILENAME) type STRING
      value(IV_PATH) type STRING
      value(IV_FULLPATH) type STRING
      value(IV_DEFAULT_FILE_NAME) type STRING optional .
  class-methods TRANSFORM_FCAT_TO_XLSX_XSTRING
    importing
      value(IT_FCAT) type LVC_T_FCAT
      !IV_FILE_TYPE type SALV_BS_CONSTANT default IF_SALV_BS_XML=>C_TYPE_XLSX
    returning
      value(RV_TXSTRING) type XSTRING .
protected section.
private section.
ENDCLASS.



CLASS ZCL_DDIC_DOWN IMPLEMENTATION.
  METHOD ddic_object_description.
    DATA lo_struct   TYPE REF TO cl_abap_structdescr.
    DATA lo_elem_ref TYPE REF TO cl_abap_elemdescr.
    DATA ls_fcat     TYPE lvc_s_fcat.
    DATA lv_dnam     TYPE dd04l-rollname.
    DATA ls_dd04l    TYPE dd04l.
    DATA lt_dd04t    TYPE TABLE OF dd04t.

    " --- get type infos of internal table
    lo_struct ?= cl_abap_typedescr=>describe_by_data( iv_ddic_object  ).
    LOOP AT lo_struct->components ASSIGNING FIELD-SYMBOL(<wa_comp>).
      ASSIGN COMPONENT <wa_comp>-name OF STRUCTURE iv_ddic_object TO FIELD-SYMBOL(<field>).
      IF <field> IS NOT ASSIGNED.            " must be the case !!
        CONTINUE.
      ENDIF.
      CATCH SYSTEM-EXCEPTIONS move_cast_error = 1.
        lo_elem_ref ?= cl_abap_typedescr=>describe_by_data( <field> ).
      ENDCATCH.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      CLEAR ls_fcat.
      ls_fcat-fieldname = <wa_comp>-name.
      lv_dnam = lo_elem_ref->help_id.
      " --- get texts and type descriptions of table component
      CALL FUNCTION 'DD_DTEL_GET'
        EXPORTING  langu         = sy-langu
                   withtext      = 'X'
                   roll_name     = lv_dnam
        IMPORTING  dd04l_wa_a    = ls_dd04l
        TABLES     dd04t_tab_a   = lt_dd04t
        EXCEPTIONS illegal_value = 1
                   OTHERS        = 2.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING ls_dd04l TO ls_fcat.
        " --- some conversions (add entitytab for conversions)
        ls_fcat-ref_table = ls_dd04l-entitytab.
        IF ls_dd04l-valexi = 'X'.
          ls_fcat-ref_table = ls_dd04l-domname.
        ENDIF.
        IF ls_fcat-ref_table IS NOT INITIAL.
          ls_fcat-ref_field = ls_dd04l-domname.
        ENDIF.
        ASSIGN lt_dd04t[ 1 ] TO FIELD-SYMBOL(<wa_dd04t>).
        IF sy-subrc = 0 AND <wa_dd04t> IS ASSIGNED.
          MOVE-CORRESPONDING <wa_dd04t> TO ls_fcat.
          ls_fcat-reptext = <wa_dd04t>-ddtext.
        ENDIF.
      ENDIF.
      APPEND ls_fcat TO rt_fcat.
    ENDLOOP.
  ENDMETHOD.

  METHOD file_save_dialog.
    DATA lv_size           TYPE i.
    DATA lt_bintab         TYPE solix_tab.
    DATA default_file_name TYPE string.

    default_file_name = COND #( WHEN iv_default_file_name IS INITIAL THEN '*' ELSE iv_default_file_name ).

    cl_gui_frontend_services=>file_save_dialog( EXPORTING  default_extension    = iv_extension
                                                           default_file_name    = default_file_name
                                                CHANGING   filename             = iv_filename
                                                           path                 = iv_path
                                                           fullpath             = iv_fullpath
                                                EXCEPTIONS cntl_error           = 1
                                                           error_no_gui         = 2
                                                           not_supported_by_gui = 3
                                                           OTHERS               = 4 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING buffer        = iv_xstring
*                APPEND_TO_TABLE = ' '
      IMPORTING output_length = lv_size
      TABLES    binary_tab    = lt_bintab.

    cl_gui_frontend_services=>gui_download( EXPORTING  bin_filesize            = lv_size
                                                       filename                = iv_fullpath
                                                       filetype                = 'BIN'
                                            CHANGING   data_tab                = lt_bintab
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
    IF sy-subrc <> 0.
      " Implement suitable error handling here
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.


  METHOD TRANSFORM_FCAT_TO_XLSX_XSTRING.
    " --- Check for latest excel version
    CHECK    cl_salv_bs_a_xml_base=>get_version( ) = if_salv_bs_xml=>version_25
          OR cl_salv_bs_a_xml_base=>get_version( ) = if_salv_bs_xml=>version_26.

    CHECK iv_file_type = if_salv_bs_xml=>c_type_xlsx.

    DATA(lv_version) = COND #( WHEN cl_salv_bs_a_xml_base=>get_version( ) = if_salv_bs_xml=>version_25
                               THEN if_salv_bs_xml=>version_25
                               ELSE if_salv_bs_xml=>version_26  ).

    GET REFERENCE OF it_fcat INTO DATA(lt_data).

    DATA(lr_result_data) = cl_salv_ex_util=>factory_result_data_table( r_data         = lt_data
                                                                       t_fieldcatalog = it_fcat ).

    cl_salv_bs_tt_util=>if_salv_bs_tt_util~transform( EXPORTING xml_type      = iv_file_type
                                                                xml_version   = lv_version        " latest available, older ones are not supported
                                                                r_result_data = lr_result_data
                                                                xml_flavour   = if_salv_bs_c_tt=>c_tt_xml_flavour_export
                                                                gui_type      = if_salv_bs_xml=>c_gui_type_wd
                                                      IMPORTING xml           = rv_txstring ).
  ENDMETHOD.
ENDCLASS.
