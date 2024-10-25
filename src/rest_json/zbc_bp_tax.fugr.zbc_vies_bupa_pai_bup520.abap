FUNCTION zbc_vies_bupa_pai_bup520.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"----------------------------------------------------------------------

  TYPE-POOLS abap.
  DATA lt_tax     TYPE STANDARD TABLE OF dfkkbptaxnum.
  DATA lv_country TYPE land1.
  DATA change TYPE bus000flds-xchng.

  CALL FUNCTION 'BUTX_BUPA_EVENT_XCHNG'
    IMPORTING
      e_xchng = change.

  CHECK change = abap_true.

  CALL FUNCTION 'BUP_BUPA_TAX_GET'
    TABLES
      et_tax              = lt_tax
    EXCEPTIONS
      no_taxnumbers_found = 1
      OTHERS              = 2.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  LOOP AT lt_tax ASSIGNING FIELD-SYMBOL(<ls_tax>).
    lv_country = <ls_tax>-taxtype(2).

    IF <ls_tax>-taxtype+2(1) <> '0'.
      CONTINUE.
    ENDIF.
    IF <ls_tax>-taxnum IS INITIAL.
      CONTINUE.
    ENDIF.
    IF zcl_rest_resource=>is_country_eu( lv_country ) = abap_false.
      CONTINUE.
    ENDIF.

    IF zcl_rest_resource=>get_method( lv_country ) = abap_false. " WebService im Land verfügbar?
      CONTINUE.
    ENDIF.

    DATA(valid) = zcl_rest_resource=>post_method( iv_countrycode = CONV string( lv_country )
                                    iv_vatnumber   = CONV string( <ls_tax>-taxnum+2 )      ).

    IF valid = abap_true.
      MESSAGE i001(zbc_rest_json) WITH <ls_tax>-taxnum.
    ELSE.
      MESSAGE i002(zbc_rest_json) WITH <ls_tax>-taxnum.
    ENDIF.
  ENDLOOP.
ENDFUNCTION.
