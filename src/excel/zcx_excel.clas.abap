class ZCX_EXCEL definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

  PUBLIC SECTION.
    INTERFACES if_t100_dyn_msg.
    INTERFACES if_t100_message.

    CONSTANTS:
      BEGIN OF wrong_format,
        msgid TYPE symsgid      VALUE 'ZBC_EXCEL',
        msgno TYPE symsgno      VALUE '001',
        attr1 TYPE scx_attrname VALUE 'FILE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF wrong_format.
    CONSTANTS:
      BEGIN OF path_too_long,
        msgid TYPE symsgid      VALUE 'ZBC_EXCEL',
        msgno TYPE symsgno      VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF path_too_long.
    CONSTANTS:
      BEGIN OF transfrom_error,
        msgid TYPE symsgid      VALUE 'ZBC_EXCEL',
        msgno TYPE symsgno      VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF transfrom_error.

    DATA file TYPE rlgrap-filename.

    METHODS constructor
      IMPORTING textid    LIKE if_t100_message=>t100key OPTIONAL
                !previous LIKE previous                 OPTIONAL
                !file     TYPE rlgrap-filename          OPTIONAL.

protected section.
private section.
ENDCLASS.



CLASS ZCX_EXCEL IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).
    me->file = file.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
