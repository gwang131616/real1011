*&---------------------------------------------------------------------*
*& Report YSAMP001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ysamp001.

*----------------------------------------------------------------------*
* INCLUDE                                                              *
*----------------------------------------------------------------------*
INCLUDE ysampcvc000 .       " Global 공통변수
INCLUDE mysamp001_top.
INCLUDE mysamp001_cls01." ALV EVENT
INCLUDE mysamp001_cls02." TREE EVENT
INCLUDE mysamp001_cls03." DIALOG EVENT
INCLUDE mysamp001_src01.
INCLUDE mysamp001_frm01.
INCLUDE mysamp001_pbo01.
INCLUDE mysamp001_pai01.

*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN .
* 사용자권한 Check...
  gv_ucomm = sy-ucomm.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  DATA(lv_multi) = p_col * p_row.
  IF lv_multi > 4 OR lv_multi = 0.
    MESSAGE s001(zcmmsg) WITH '9 is Max ' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM get_data_select .

  CALL SCREEN 100.
