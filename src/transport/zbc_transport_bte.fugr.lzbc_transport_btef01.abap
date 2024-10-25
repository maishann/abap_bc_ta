*----------------------------------------------------------------------*
***INCLUDE LZBC_TRANSPORT_BTEF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form adjust_table
*&---------------------------------------------------------------------*
FORM adjust_table
  TABLES
    a_tab
  USING
    VALUE(a_length)      TYPE i
    VALUE(a_first_line)  TYPE i
    VALUE(a_last_line)   TYPE i.

  DATA:
    l_length   TYPE i,
    l_index    TYPE i,
    l_offset   TYPE i,
    l_rest     TYPE i,
    l_type(1),
    temp_index TYPE f.

  IF a_first_line < 1.
    a_first_line = 1.
  ENDIF.
  IF a_last_line < 1.
    DESCRIBE TABLE a_tab LINES a_last_line.
  ENDIF.


  FIELD-SYMBOLS: <line>.

  ASSIGN COMPONENT 1 OF STRUCTURE a_tab TO <line>.
  DESCRIBE FIELD <line> TYPE l_type.

  IF l_type = 'C'.
    DESCRIBE FIELD <line> LENGTH l_length IN CHARACTER MODE.
  ELSE.
    DESCRIBE FIELD <line> LENGTH l_length IN BYTE MODE.
  ENDIF.
  l_offset = a_length MOD l_length.
  temp_index =  ( ( a_length + l_length - 1 ) DIV l_length )
                + a_first_line - 1.
  l_index = temp_index.
  IF l_offset > 0.
    l_rest = l_length - l_offset.
    READ TABLE a_tab INDEX l_index.
    IF sy-subrc = 0.
      ASSIGN <line>+l_offset(l_rest) TO <line>.
      CLEAR <line>.
      MODIFY a_tab INDEX l_index.
    ENDIF.
  ENDIF.
  ADD 1 TO l_index.
  LOOP AT a_tab FROM l_index TO a_last_line.
    DELETE a_tab.
  ENDLOOP.

ENDFORM.
