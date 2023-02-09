*&---------------------------------------------------------------------*
*&  Include           MYSAMP001_CLS01
*&---------------------------------------------------------------------*

CLASS: lcl_event_receiver_grid   DEFINITION DEFERRED.

DATA: g_event_receiver_grid   TYPE REF TO lcl_event_receiver_grid .

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER_GRID_DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_event_receiver_grid DEFINITION.
  PUBLIC SECTION.
    METHODS: handle_toolbar
                 FOR EVENT toolbar               OF cl_gui_alv_grid
                 IMPORTING sender
                           e_object
                           e_interactive,
             handle_double_click
                 FOR EVENT double_click          OF cl_gui_alv_grid
                 IMPORTING sender
                           e_row
                           e_column
                           es_row_no ,
             handle_user_command
                 FOR EVENT user_command          OF cl_gui_alv_grid
                 IMPORTING sender
                           e_ucomm,
             handle_data_changed
                 FOR EVENT data_changed          OF cl_gui_alv_grid
                 IMPORTING sender
                           er_data_changed
                           e_onf4 ,
             handle_data_changed_finished
                 FOR EVENT data_changed_finished OF cl_gui_alv_grid
                 IMPORTING sender
                           e_modified
                           et_good_cells,
             handle_onf4
                 FOR EVENT onf4                  OF cl_gui_alv_grid
                 IMPORTING sender
                           e_fieldname
                           e_fieldvalue
                           es_row_no
                           er_event_data
                           et_bad_cells
                           e_display,

             handle_hotspot_click
                 FOR EVENT hotspot_click         OF cl_gui_alv_grid
                 IMPORTING sender
                           e_row_id
                           e_column_id
                           es_row_no,

             handle_button_click
                FOR EVENT button_click OF cl_gui_alv_grid
                IMPORTING sender
                          es_col_id
                          es_row_no.


ENDCLASS.                    "LCL_EVENT_RECEIVER_GRID DEFINITION
*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER_GRID IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event_receiver_grid IMPLEMENTATION.
* ToolBar 버튼생성
  METHOD handle_toolbar.
    PERFORM add_grid_button  USING sender e_object e_interactive.
  ENDMETHOD.                    "HANDLE_TOOLBAR
* 더블 클릭시
  METHOD handle_double_click.
    PERFORM line_double_click USING sender e_row e_column .
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
* ToolBar에 생성된 버튼(Function) 처리
  METHOD handle_user_command.
    PERFORM grid_user_command USING sender e_ucomm.
  ENDMETHOD.                    "HANDLE_USER_COMMAND
* Data 변경시 처리
  METHOD handle_data_changed.
    PERFORM grid_data_changed USING sender
                                    er_data_changed
                                    e_onf4.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED
* Data 변경완료시 처리
  METHOD handle_data_changed_finished.
*    PERFORM grid_data_changed_finished USING e_modified
*                                             et_good_cells.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED
* Search Help..
  METHOD handle_onf4.
    PERFORM on_f4  USING sender
                         e_fieldname
                         e_fieldvalue
                         es_row_no
                         er_event_data
                         et_bad_cells
                         e_display.
  ENDMETHOD.                    "HANDLE_ONF4

  METHOD handle_hotspot_click.
    PERFORM display_hotspot_click USING sender
                                        e_row_id-index
                                        e_column_id-fieldname .
  ENDMETHOD.                    "handle_DOUBLE_CLICK

* 버튼 클릭시...
  METHOD handle_button_click.
    PERFORM handle_button_click USING sender
                                      es_col_id
                                      es_row_no.
  ENDMETHOD.                    "handle_DOUBLE_CLICK

ENDCLASS.                    "LCL_EVENT_RECEIVER_GRID_IMPLEMENTATION
