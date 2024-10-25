*&---------------------------------------------------------------------*
*& Report ZBC_TRANSPORT_UP_DOWN                                        *
*&---------------------------------------------------------------------*
*& Date:   22.10.2024                                                  *
*& Author: Hannes Maisch (HANNESM)                                     *
*& Company: ponturo consulting AG                                      *
*& Requested from:                                                     *
*& Description: Up- & Downloadfunktion für Transportaufträge auf den   *
*&              Applikationsserver.                                    *
*&---------------------------------------------------------------------*
*& Change History                                                      *
*& Date        | Author   | CR &  Description                          *
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc_transport_up_down.

INCLUDE zbc_transport_up_down_top.
INCLUDE zbc_transport_up_down_scr.
INCLUDE zbc_transport_up_down_lcl.
INCLUDE zbc_transport_up_down_f01.

INITIALIZATION.
  PERFORM init.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_frnt.
  PERFORM at_selection_screen_for_frnt.

AT SELECTION-SCREEN OUTPUT.
  PERFORM at_screen_output.

START-OF-SELECTION.
  CASE 'X'.
    WHEN p_r01. " UPLOAD
      PERFORM upload_request.
    WHEN p_r02. " DOWNLOAD
      PERFORM download_request.
  ENDCASE.

  IF     gc_error IS INITIAL
     AND p_import IS INITIAL.
    MESSAGE i718(tg).
  ENDIF.
