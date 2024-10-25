*&---------------------------------------------------------------------*
*& Include          ZBC_TRANSPORT_UP_DOWN_LCL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS lcx_error DEFINITION
*----------------------------------------------------------------------*
CLASS lcx_error DEFINITION INHERITING FROM cx_no_check.
  PUBLIC SECTION.
    "
    CLASS-DATA gc_error   TYPE icon_d VALUE '@5C@'.
    CLASS-DATA gc_warning TYPE icon_d VALUE '@5D@'.
    CLASS-DATA gc_info    TYPE icon_d VALUE '@5B@'.

    "
    METHODS constructor IMPORTING i_text TYPE csequence.

    "
    METHODS handler
      IMPORTING ip_errortyp TYPE icon_d.

    "

  PRIVATE SECTION.
    DATA text TYPE string.
ENDCLASS.


" ----------------------------------------------------------------------
CLASS lcx_error IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    text = i_text.
  ENDMETHOD.

  " ----------------------------------------------------------------------
  METHOD handler.
    WRITE:/ ip_errortyp AS ICON, text.
    CLEAR text.
  ENDMETHOD.
  " ----------------------------------------------------------------------
ENDCLASS.
DATA gc_error TYPE REF TO lcx_error.
*&---------------------------------------------------------------------*
*&  Include           ZBC_TRANSPORT_UP_DOWN_LCL
*&---------------------------------------------------------------------*
CLASS lcl_main DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS append_request.
    CLASS-METHODS import_request.
ENDCLASS.


" -----------------------------------------------------------------------
" CLASS lcl_main IMPLEMENTATION
" -----------------------------------------------------------------------
CLASS lcl_main IMPLEMENTATION.
  METHOD import_request.
    DATA lv_system  TYPE tmssysnam.
    DATA lv_request TYPE trkorr.
    DATA lv_error   TYPE string.

    " Check Authority STMS
    CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
      EXPORTING  tcode  = 'STMS'
      EXCEPTIONS ok     = 1
                 not_ok = 2
                 OTHERS = 3.
    IF sy-subrc > 1.
      MESSAGE e109(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( i_text = lv_error ).
    ENDIF.

    lv_system  = sy-sysid.
    lv_request = p_ta.

    CALL FUNCTION 'TMS_UI_IMPORT_TR_REQUEST'
      EXPORTING  iv_system             = lv_system
                 iv_request            = lv_request
                 iv_verbose            = 'X'
      EXCEPTIONS cancelled_by_user     = 1
                 import_request_denied = 2
                 import_request_failed = 3
                 OTHERS                = 4.
    IF sy-subrc = 1.
      " Abbruch durch User.
      MESSAGE e006(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( i_text = lv_error ).
    ELSEIF sy-subrc = 3.
      " Beim Import trat ein Fehler auf.
      MESSAGE e007(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( i_text = lv_error ).
    ELSEIF sy-subrc <> 0.
      " Unbekannter Fehler.
      MESSAGE e008(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( i_text = lv_error ).
    ENDIF.

    CALL FUNCTION 'TMS_UIQ_IMPORT_QUEUE_DISPLAY'
      EXPORTING  iv_system                   = lv_system
      EXCEPTIONS import_queue_display_failed = 1
                 OTHERS                      = 2.

    IF sy-subrc <> 0.
      MESSAGE e110(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( i_text = lv_error ).
    ENDIF.
  ENDMETHOD.

  METHOD append_request.
    DATA lv_system  TYPE tmssysnam.
    DATA lv_request TYPE trkorr.
    DATA lv_error   TYPE string.

    lv_system  = sy-sysid.
    lv_request = p_ta.

    CALL FUNCTION 'TMS_UI_APPEND_TR_REQUEST'
      EXPORTING  iv_system             = lv_system
                 iv_request            = lv_request
      EXCEPTIONS cancelled_by_user     = 1
                 append_request_failed = 2
                 OTHERS                = 3.
    IF sy-subrc = 1.
      " Abbruch durch User.
      MESSAGE e006(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( i_text = lv_error ).
    ELSEIF sy-subrc = 2.
      " Beim Anhängen trat ein Fehler auf.
      MESSAGE e009(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( i_text = lv_error ).
    ELSEIF sy-subrc <> 0.
      " Unbekannter Fehler.
      MESSAGE e008(zbc_transport) INTO lv_error.
      RAISE EXCEPTION NEW lcx_error( i_text = lv_error ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
DATA gc_main TYPE REF TO lcl_main.
