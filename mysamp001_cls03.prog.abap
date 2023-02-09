*&---------------------------------------------------------------------*
*&  Include           MYSAMP001_CLS03
*&---------------------------------------------------------------------*
CLASS lcl_dialogbox_handler DEFINITION.
  PUBLIC SECTION.
    METHODS: on_dialogbox_close
                FOR EVENT close OF cl_gui_dialogbox_container
      IMPORTING sender.

ENDCLASS.


CLASS lcl_dialogbox_handler IMPLEMENTATION.
  METHOD on_dialogbox_close.

    DATA ls_data LIKE LINE OF gt_data1.

    IF NOT sender IS INITIAL.
      CALL METHOD sender->free
        EXCEPTIONS
          OTHERS = 1.
      IF sy-subrc <> 0.

      ENDIF.

*--------------------------------------------------------------------*
      " 처리로직 추가 부분...(첨부파일 혹은 전자증빈 번호 refresh)
      MESSAGE s001(zcmmsg) WITH 'on_dialogbox_close'.


      READ TABLE gt_data1 INDEX gv_index ASSIGNING FIELD-SYMBOL(<fs_data1>).
      IF sy-subrc = 0.
        <fs_data1>-mc_stext = 'DIALOGBOX CLOSE'.
      ENDIF.
*--------------------------------------------------------------------*

      CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
        EXPORTING
          functioncode           = '='
        EXCEPTIONS
          function_not_supported = 1
          OTHERS                 = 2.

    ENDIF.


  ENDMETHOD.
ENDCLASS.



DATA: g_dialogbox_handler TYPE REF TO lcl_dialogbox_handler.
