*&---------------------------------------------------------------------*
*&  Include           MYSAMP001_PBO01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S0100'.
  SET TITLEBAR 'T0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_ALV_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_alv_data OUTPUT.

  PERFORM create_display_multi_alv_data USING p_col p_row.

*  PERFORM create_display_single_alv USING 'GT_DATA1' '1'.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'S0200'.
  SET TITLEBAR 'T0200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_ALV_DATA_200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_alv_data_200 OUTPUT.

  PERFORM create_display_custom_alv USING 'CONT5' 'GT_ALV5' '5'.
  PERFORM create_display_custom_alv USING 'CONT6' 'GT_ALV6' '6'.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS 'S0300'.
*  SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_ALV_DATA_300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_alv_data_300 OUTPUT.

    PERFORM create_display_single_alv USING 'GT_SDATA' '9'.


ENDMODULE.
