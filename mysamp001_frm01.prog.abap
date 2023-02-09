*&---------------------------------------------------------------------*
*&  Include           MYSAMP001_FRM01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CREATE_DISPLAY_ALV_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_COL  text
*      -->P_P_ROW  text
*----------------------------------------------------------------------*
FORM create_display_multi_alv_data  USING    pv_col  pv_row.

  DATA lv_curr_col TYPE i.
  DATA lv_curr_row TYPE i.
  DATA lv_seq TYPE i.
  DATA lv_tree_fg TYPE flag.

  DATA lv_tabnm(20).
  DATA lv_tabnm_tb(20).

  FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.


*--------------------------------------------------------------------*
  " 상위 docking object 한번만 실행..
  PERFORM get_ref_docking_spliter_object USING '1' pv_col pv_row.
*--------------------------------------------------------------------*

  DO pv_col TIMES.
    lv_curr_col = sy-index.

    DO pv_row TIMES.
      lv_curr_row = sy-index.

      ADD 1 TO lv_seq.

      CLEAR lv_tree_fg.
      IF p_trfg IS NOT INITIAL.
        IF lv_seq = p_tree.
          lv_tree_fg = 'X'.
        ENDIF.
      ENDIF.

      " 각 Contrainer 구성 object
      PERFORM get_ref_cont_object USING  lv_seq.

      " TAB NAME & ITAB NAME Assign
      lv_tabnm    = |{ gc_tabnm }{ lv_seq }|.
      lv_tabnm_tb = |{ gc_tabnm }{ lv_seq }[]|.

      ASSIGN (lv_tabnm_tb) TO <fs_tab>.

      IF lv_tree_fg IS INITIAL.
        IF <fs_g_alv_grid> IS INITIAL AND <fs_g_alv_grid> IS ASSIGNED.

          PERFORM create_docking_container USING <fs_g_alv_grid>
                                                 <fs_g_container>
                                                 <fs_g_splitter>
                                                 lv_curr_col
                                                 lv_curr_row.

          PERFORM create_grid_object USING <fs_g_alv_grid>
                                           <fs_g_fcat>
                                           <fs_g_layout>
                                           <fs_g_sort>
                                           <fs_g_fcode>
                                           lv_tabnm .

          PERFORM alv_data_display USING <fs_g_alv_grid>
                                         <fs_g_fcat>
                                         <fs_g_layout>
                                         <fs_g_sort>
                                         <fs_g_fcode>
                                         <fs_tab>.
        ELSE .

          PERFORM alv_refresh_grid USING <fs_g_alv_grid>.

        ENDIF.
      ELSE.

        IF <fs_g_tree> IS INITIAL AND <fs_g_tree> IS ASSIGNED.
          PERFORM create_tree_contrainer USING <fs_g_container>
                                               <fs_g_splitter>
                                               <fs_g_tree>
                                               <fs_g_fcat>
                                               lv_curr_col
                                               lv_curr_row
                                               <fs_tab>.
        ENDIF.
        CALL METHOD cl_gui_cfw=>flush.
      ENDIF.

    ENDDO.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_REF_CONT_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_SEQ  text
*----------------------------------------------------------------------*
FORM get_ref_cont_object  USING    pv_seq.

  DATA lv_grid_nm(30).
  DATA lv_fcat_nm(30).
  DATA lv_container_nm(30).
  DATA lv_custum_cont_nm(30).
  DATA lv_tree_nm(30).
  DATA lv_layout_nm(30).
  DATA lv_sort_nm(30).
  DATA lv_fcode_nm(30).

  lv_grid_nm      = |{ gc_g_grid }{ pv_seq }|.
  lv_container_nm = |{ gc_g_container }{ pv_seq }|.
  lv_custum_cont_nm = |{ gc_g_custom }{ pv_seq }|.
  lv_tree_nm      = |{ gc_g_tree }{ pv_seq }|.

  lv_layout_nm    = |{ gc_gs_layout }{ pv_seq }|.
  lv_fcat_nm      = |{ gc_gt_grid_fcat }{ pv_seq }|.
  lv_sort_nm      = |{ gc_gt_sort }{ pv_seq }|.
  lv_fcode_nm     = |{ gc_gt_fcode }{ pv_seq }|.

  UNASSIGN :  <fs_g_alv_grid>,
              <fs_g_fcat>,
              <fs_g_container>,
              <fs_g_custom>,
              <fs_g_tree>,
              <fs_g_sort>,
              <fs_g_fcode>,
              <fs_g_layout>.

  ASSIGN (lv_grid_nm)      TO <fs_g_alv_grid>.
  ASSIGN (lv_container_nm) TO <fs_g_container>.
  ASSIGN (lv_custum_cont_nm) TO <fs_g_custom>.
  ASSIGN (lv_tree_nm)      TO <fs_g_tree>.

  ASSIGN (lv_fcat_nm)      TO <fs_g_fcat>.
  ASSIGN (lv_sort_nm)      TO <fs_g_sort>.
  ASSIGN (lv_fcode_nm)     TO <fs_g_fcode>.
  ASSIGN (lv_layout_nm)    TO <fs_g_layout>.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_DOCKING_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<FS_G_ALV_GRID>  text
*----------------------------------------------------------------------*
FORM create_docking_container  USING po_grid TYPE REF TO cl_gui_alv_grid
                                     po_container TYPE REF TO cl_gui_container
                                     po_splitter TYPE REF TO cl_gui_splitter_container
                                     pv_col
                                     pv_row.

  po_container  = po_splitter->get_container( row = pv_row column = pv_col ).

* Create Code type ALV List
  CREATE OBJECT po_grid
    EXPORTING
      i_parent      = po_container
      i_appl_events = 'X'.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_GRID_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<FS_G_ALV_GRID>  text
*      -->P_<FS_G_FCAT>  text
*      -->P_LV_TABGB  text
*----------------------------------------------------------------------*
FORM create_grid_object  USING   po_grid       TYPE REF TO cl_gui_alv_grid
                                  pt_grid_fcat TYPE lvc_t_fcat
                                  ps_layout    TYPE lvc_s_layo
                                  pt_sort      TYPE lvc_t_sort
                                  pt_fcode      TYPE ui_functions
                                  pv_tabnm.

* Field_Catalog Define
  PERFORM set_fieldcatalog    USING pt_grid_fcat
                                    pv_tabnm.
* Exclude
  PERFORM make_exclude_code   USING pt_fcode.

* Layout
  PERFORM set_layout USING ps_layout pv_tabnm.

* F4
  PERFORM set_f4 USING po_grid pv_tabnm.

* Grid Event가 있을 경우
  PERFORM set_event_handlers USING po_grid.

* Register grid event
  PERFORM register_grid_event USING po_grid.

* Sort
  PERFORM make_grid_sort USING pt_sort pv_tabnm.

  CALL METHOD cl_gui_cfw=>flush.

*  CALL METHOD po_grid->set_ready_for_input
*    EXPORTING
*      i_ready_for_input = 0.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_DATA_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<FS_G_ALV_GRID>  text
*      -->P_<FS_G_FCAT>  text
*      -->P_<FS_TAB>  text
*----------------------------------------------------------------------*
FORM alv_data_display  USING    po_grid      TYPE REF TO cl_gui_alv_grid
                                pt_grid_fcat TYPE lvc_t_fcat
                                ps_layout    TYPE lvc_s_layo
                                pt_sort      TYPE lvc_t_sort
                                pt_fcode     TYPE ui_functions
                                pt_data      TYPE ANY TABLE.

  DATA: ls_variant       LIKE disvariant.
  ls_variant-report   = sy-repid.


  CALL METHOD po_grid->set_table_for_first_display
    EXPORTING
      is_layout            = ps_layout
      i_save               = 'A'
      it_toolbar_excluding = pt_fcode
      is_variant           = ls_variant
    CHANGING
      it_fieldcatalog      = pt_grid_fcat[]
      it_sort              = pt_sort[]
      it_outtab            = pt_data[].

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_REFRESH_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<FS_G_ALV_GRID>  text
*----------------------------------------------------------------------*
FORM alv_refresh_grid  USING  po_grid TYPE REF TO cl_gui_alv_grid.

  DATA: ls_scroll TYPE lvc_s_stbl.

  CLEAR: ls_scroll.
  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      is_stable = ls_scroll.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_GRID_FCAT  text
*      -->P_PV_TABNM  text
*----------------------------------------------------------------------*
FORM set_fieldcatalog  USING    pt_fieldcat TYPE lvc_t_fcat
                                 pv_tabnm .

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_fcat     TYPE lvc_s_fcat.

  DATA: lv_tabname TYPE  slis_tabname .
  DATA: lv_struct  TYPE  dd02l-tabname .

  " like 로 선언되었을 경우 itab 으로 아니면 struc로 처리
*  lv_tabname = pv_tabnm.
  lv_struct = 'HRP1000'.

*
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
*     i_internal_tabname     = lv_tabname
      i_structure_name       = lv_struct
      i_client_never_display = gc_set
      i_inclname             = sy-repid
      i_bypassing_buffer     = gc_set
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc = 0.
    PERFORM transfer_slis_to_lvc CHANGING lt_fieldcat pt_fieldcat.
  ENDIF.


  " Local 로직

  CASE pv_tabnm.
    WHEN 'GT_DATA1'.
    WHEN 'GT_DATA2'.
    WHEN 'GT_TREE'.
      LOOP AT pt_fieldcat INTO ls_fcat.
        CASE ls_fcat-fieldname.
          WHEN 'SHORT' OR 'STEXT' .

          WHEN OTHERS.
            ls_fcat-no_out = 'X'.
        ENDCASE.
        MODIFY pt_fieldcat FROM ls_fcat. CLEAR ls_fcat.
      ENDLOOP.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TRANSFER_SLIS_TO_LVC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_FIELDCAT  text
*      <--P_PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM transfer_slis_to_lvc  CHANGING pt_fieldcat TYPE slis_t_fieldcat_alv
                                    pt_field TYPE lvc_t_fcat.

  DATA : lt_fieldcat TYPE kkblo_t_fieldcat.

  CALL FUNCTION 'REUSE_ALV_TRANSFER_DATA'
    EXPORTING
      it_fieldcat = pt_fieldcat
    IMPORTING
      et_fieldcat = lt_fieldcat.

  CALL FUNCTION 'LVC_TRANSFER_FROM_KKBLO'
    EXPORTING
      it_fieldcat_kkblo = lt_fieldcat
    IMPORTING
      et_fieldcat_lvc   = pt_field.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PO_GRID  text
*----------------------------------------------------------------------*
FORM set_event_handlers   USING po_grid TYPE REF TO cl_gui_alv_grid.

  CREATE OBJECT g_event_receiver_grid.

  SET HANDLER g_event_receiver_grid->handle_data_changed  FOR po_grid.
  SET HANDLER g_event_receiver_grid->handle_onf4          FOR po_grid.
  SET HANDLER g_event_receiver_grid->handle_hotspot_click FOR po_grid.
  SET HANDLER g_event_receiver_grid->handle_double_click  FOR po_grid.
  SET HANDLER g_event_receiver_grid->handle_user_command  FOR po_grid.
  SET HANDLER g_event_receiver_grid->handle_data_changed  FOR po_grid.
  SET HANDLER g_event_receiver_grid->handle_toolbar       FOR po_grid.
  SET HANDLER g_event_receiver_grid->handle_button_click  FOR po_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  REGISTER_GRID_EVENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PO_GRID  text
*----------------------------------------------------------------------*
FORM register_grid_event  USING po_grid TYPE REF TO cl_gui_alv_grid.

  CALL METHOD po_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  CALL METHOD po_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PS_LAYOUT  text
*----------------------------------------------------------------------*
FORM set_layout  USING    ps_layout TYPE lvc_s_layo
                          pv_tabnm.

  ps_layout-zebra      = 'X'.              "얼룩무늬
  ps_layout-sel_mode   = 'D'.
*  ps_layout-col_opt    = 'X'.
  ps_layout-cwidth_opt = 'X'.                  "필드길이 자동조정
  ps_layout-stylefname = 'STYLE'.


*--------------------------------------------------------------------*
  " Local 로직

  CASE pv_tabnm.
    WHEN 'GT_DATA1'.
    WHEN 'GT_DATA2'.
    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_select .

  DATA : lt_1000 LIKE TABLE OF gs_1000 WITH HEADER LINE.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_1000
           FROM hrp1000
           UP TO 10 ROWS
           WHERE otype = 'O'.

  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE lt_1000
           FROM hrp1000
           UP TO 20 ROWS
           WHERE otype = 'SC'.

  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE lt_1000
           FROM hrp1000
           UP TO 20 ROWS
           WHERE otype = 'CG'.

  gt_data1[] =  lt_1000[].

  LOOP AT gt_data1 ASSIGNING FIELD-SYMBOL(<fs_line>).

    IF <fs_line>-otype = 'SC'.
      PERFORM set_grid_style_button USING <fs_line>
                                 CHANGING g_styl_btn.

      INSERT LINES OF g_styl_btn INTO TABLE <fs_line>-style.
    ENDIF.

  ENDLOOP.

  gt_temp[] = gt_data1[].


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LINE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*----------------------------------------------------------------------*
FORM line_double_click  USING    p_sender
                                 p_e_row
                                 p_e_column.

  IF p_sender = g_grid1.
    MESSAGE s001(zcmmsg) WITH 'GRID1 더블클릭'.

    READ TABLE gt_data1 INDEX p_e_row ASSIGNING FIELD-SYMBOL(<fs_data1>).
    IF sy-subrc = 0.
      APPEND <fs_data1> TO gt_data2.
      APPEND <fs_data1> TO gt_data3.
      APPEND <fs_data1> TO gt_data4.
      APPEND <fs_data1> TO gt_data5.
      APPEND <fs_data1> TO gt_data6.
      APPEND <fs_data1> TO gt_data7.
      APPEND <fs_data1> TO gt_data8.
      APPEND <fs_data1> TO gt_data9.
    ENDIF.
  ENDIF.

  IF p_sender = g_grid2.
    MESSAGE s001(zcmmsg) WITH 'GRID2 더블클릭'.

    DELETE gt_data2 INDEX p_e_row.

  ENDIF.

  IF p_sender = g_grid3.
    MESSAGE s001(zcmmsg) WITH 'GRID3 더블클릭'.
    DELETE gt_data3 INDEX p_e_row.
  ENDIF.

  IF p_sender = g_grid4.
    MESSAGE s001(zcmmsg) WITH 'GRID4 더블클릭'.
    DELETE gt_data4 INDEX p_e_row.
  ENDIF.

  IF p_sender = g_grid5.
    MESSAGE s001(zcmmsg) WITH 'GRID5 더블클릭'.
    DELETE gt_data5 INDEX p_e_row.
  ENDIF.

  IF p_sender = g_grid6.
    MESSAGE s001(zcmmsg) WITH 'GRID6 더블클릭'.

    DELETE gt_data6 INDEX p_e_row.
  ENDIF.

  IF p_sender = g_grid7.
    MESSAGE s001(zcmmsg) WITH 'GRID7 더블클릭'.
    DELETE gt_data7 INDEX p_e_row.

  ENDIF.

  IF p_sender = g_grid8.
    MESSAGE s001(zcmmsg) WITH 'GRID8 더블클릭'.
    DELETE gt_data8 INDEX p_e_row.
  ENDIF.

  IF p_sender = g_grid9.
    MESSAGE s001(zcmmsg) WITH 'GRID9 더블클릭'.
    DELETE gt_data9 INDEX p_e_row.
  ENDIF.




ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_GRID_BUTTON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*      -->P_E_OBJECT  text
*      -->P_E_INTERACTIVE  text
*----------------------------------------------------------------------*
FORM add_grid_button  USING    p_sender
                               p_object      TYPE REF TO cl_alv_event_toolbar_set
                               p_interactive TYPE any.
*  0 버튼(일반)
*  1 메뉴 및 기본 버튼
*  2 메뉴
*  3 분리자
*  4 라디오 버튼
*  5 체크박스
*  6 메뉴 엔트리

  DATA : ls_toolbar TYPE stb_button.

  IF p_sender = g_grid1.
    CLEAR ls_toolbar.
    MOVE   ''               TO ls_toolbar-disabled.
    MOVE   0                TO ls_toolbar-butn_type.
    MOVE   'PRINT'          TO ls_toolbar-function.
    MOVE   icon_view_form   TO ls_toolbar-icon.
    MOVE   '미리보기'       TO ls_toolbar-quickinfo.
    MOVE   '미리보기'       TO ls_toolbar-text.
    INSERT ls_toolbar INTO p_object->mt_toolbar INDEX 1.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GRID_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM grid_user_command  USING    p_sender
                                 p_e_ucomm.


  IF p_sender = g_grid1.
    CASE p_e_ucomm.
      WHEN 'PRINT'.
        MESSAGE i001(zcmmsg) WITH 'Toolbar Print'.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PO_GRID  text
*      -->P_PV_TABNM  text
*----------------------------------------------------------------------*
FORM set_f4  USING     po_grid TYPE REF TO cl_gui_alv_grid
                      pv_tabnm.

  DATA: lt_f4 TYPE lvc_t_f4,
        ls_f4 TYPE lvc_s_f4.

  DEFINE insert_f4.
    ls_f4-fieldname  = &1.
    ls_f4-register   = &2.
    ls_f4-getbefore  = &3.
    ls_f4-chngeafter = &4.
    INSERT ls_f4 INTO TABLE &5.
  END-OF-DEFINITION.

  DATA lv_tabname(30).

  CASE pv_tabnm.
    WHEN 'GT_DATA1'.
      lv_tabname = 'HRP1000'.

    WHEN OTHERS.
  ENDCASE.

  " 검색도움말 매개변수 설정된 값
*  SELECT * INTO TABLE @DATA(lt_dd36s)
*           FROM dd36s
*           WHERE tabname = @lv_tabname
*           AND   shlpfield = 'L_CODE'
*           AND   as4local  = 'A'
*           AND   shtype    = 'C'.
*
*  LOOP AT lt_dd36s ASSIGNING FIELD-SYMBOL(<fs_dd36s>).
*    insert_f4: <fs_dd36s>-fieldname   'X'  'X'  'X'  lt_f4.
*  ENDLOOP.

  CALL METHOD po_grid->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ON_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*      -->P_E_FIELDNAME  text
*      -->P_E_FIELDVALUE  text
*      -->P_ES_ROW_NO  text
*      -->P_ER_EVENT_DATA  text
*      -->P_ET_BAD_CELLS  text
*      -->P_E_DISPLAY  text
*----------------------------------------------------------------------*
FORM on_f4  USING  p_sender
                     p_fieldname    TYPE lvc_fname
                     p_fieldvalue   TYPE lvc_value
                     ps_row_no      TYPE lvc_s_roid
                     pr_event_data  TYPE REF TO cl_alv_event_data
                     pt_bad_cells   TYPE lvc_t_modi
                     p_display      TYPE char01.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GRID_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*      -->P_ER_DATA_CHANGED  text
*      -->P_E_ONF4  text
*----------------------------------------------------------------------*
FORM grid_data_changed  USING    po_sender
                                 po_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                 p_onf4    TYPE any.


  DATA lv_itab_tb(30).
  DATA lv_reftabname(30).


  DATA: ls_modi      LIKE lvc_s_modi.

  FIELD-SYMBOLS: <fs_any> TYPE any,
                 <fs_id>  TYPE any,
                 <fs_txt> TYPE any.

  FIELD-SYMBOLS: <fs_fld>    TYPE any.


  FIELD-SYMBOLS : <fs_itab> TYPE STANDARD TABLE.
  FIELD-SYMBOLS : <fs_value> TYPE any.

  CASE po_sender.
    WHEN g_grid1.
      lv_itab_tb = 'GT_DATA1[]'.
    WHEN g_grid2.
      lv_itab_tb = 'GT_DATA2[]'.
    WHEN OTHERS.
  ENDCASE.

  ASSIGN (lv_itab_tb) TO <fs_itab>.
  CHECK <fs_itab> IS ASSIGNED.

  CLEAR ls_modi.
  LOOP AT po_data_changed->mt_good_cells INTO ls_modi.
    READ TABLE <fs_itab> ASSIGNING FIELD-SYMBOL(<fs_line>) INDEX ls_modi-row_id.
    CHECK sy-subrc = 0.

    UNASSIGN <fs_value>.
    ASSIGN COMPONENT 'CHECK' OF STRUCTURE <fs_line> TO <fs_value>.
    IF <fs_value> IS ASSIGNED.
      <fs_value> = 'X'.
    ENDIF.

    IF <fs_txt> IS ASSIGNED.
      PERFORM get_domain_text(zcms0) USING 'ZCMFG' ls_modi-value <fs_txt>.
    ENDIF.

  ENDLOOP.



  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
    EXPORTING
      functioncode           = '='
    EXCEPTIONS
      function_not_supported = 1
      OTHERS                 = 2.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*      -->P_E_ROW_ID_INDEX  text
*      -->P_E_COLUMN_ID_FIELDNAME  text
*----------------------------------------------------------------------*
FORM display_hotspot_click  USING    po_sender
                                     pv_row_id_index
                                     pv_colum_fieldname.
  IF po_sender = g_grid1.
    READ TABLE gt_data1 INDEX pv_row_id_index.
    CASE pv_colum_fieldname .
      WHEN 'STEXT' .


    ENDCASE.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  HANDLE_BUTTON_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*      -->P_ES_COL_ID  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM handle_button_click   USING   po_sender
                                   ps_col_id TYPE lvc_s_col
                                   ps_row_no TYPE lvc_s_roid.
  DATA lv_mode(4).
  DATA lv_url TYPE string.

  CLEAR gv_index.

  IF  po_sender = g_grid1.
    READ TABLE gt_data1 INDEX ps_row_no-row_id ASSIGNING FIELD-SYMBOL(<fs_data1>).
    IF sy-subrc = 0.
      gv_index = sy-tabix.

      MESSAGE s001(zcmmsg) WITH <fs_data1>-mc_short .

*      lv_url  = 'https://www.naver.com/'.
      lv_url  = 'http://eccdev.sookmyung.ac.kr:8001/zu4a/y_test002?sap-client=100'.
      lv_mode = 'EDIT'.
      PERFORM open_dialogbox_htmlviewer USING <fs_data1>-mc_short lv_mode lv_url.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_REF_DOCKING_SPLITER_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0079   text
*----------------------------------------------------------------------*
FORM get_ref_docking_spliter_object  USING pv_seq
                                            pv_col
                                            pv_row.

*--------------------------------------------------------------------*
  DATA lv_docking_nm(30).
  DATA lv_splitter_nm(30).

  lv_docking_nm   = |{ gc_g_docking_container }{ pv_seq }|.
  lv_splitter_nm  = |{ gc_g_splitter }{ pv_seq }|.

*  UNASSIGN :  <fs_g_docking_container>,
*              <fs_g_splitter>.

  ASSIGN (lv_docking_nm)   TO <fs_g_docking_container>.
  ASSIGN (lv_splitter_nm)  TO <fs_g_splitter>.


*--------------------------------------------------------------------*
  IF <fs_g_docking_container> IS INITIAL AND <fs_g_docking_container> IS ASSIGNED.
* Docking Container Object 선언.
    CREATE OBJECT <fs_g_docking_container>
      EXPORTING
        style     = cl_gui_control=>ws_child
        repid     = sy-cprog                          "현재 프로그램 ID
        dynnr     = SY-dynnr                          "현재 화면번호
*       side      = g_docking_container->dock_at_left "CONTAINER POS
        side      = <fs_g_docking_container>->dock_at_top "CONTAINER POS
        lifetime  = cl_gui_control=>lifetime_imode
        extension = gc_extension                      "CONTAINER SIZE
      EXCEPTIONS
        OTHERS    = 1.
  ENDIF.
*--------------------------------------------------------------------*
  IF <fs_g_splitter> IS INITIAL AND <fs_g_splitter> IS ASSIGNED.
* Splitter Container Object 선언.
    CREATE OBJECT <fs_g_splitter>
      EXPORTING
        parent  = <fs_g_docking_container>
        rows    = pv_row
        columns = pv_col.
  ENDIF.
*--------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_GRID_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_SORT  text
*      -->P_PV_TABNM  text
*----------------------------------------------------------------------*
FORM make_grid_sort  USING    pt_sort TYPE lvc_t_sort
                              pv_tabnm.

  DATA: ls_sort_wa TYPE lvc_s_sort.
  CLEAR: pt_sort, pt_sort[].

*  CLEAR ls_sort_wa .
*  ls_sort_wa-fieldname = 'ZZBTYPE_CD'.
**  LS_SORT_WA-DOWN      = 'X'.
*  APPEND ls_sort_wa TO gt_sort.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_EXCLUDE_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_FCODE  text
*----------------------------------------------------------------------*
FORM make_exclude_code  USING  pt_fcode TYPE ui_functions.
  DATA: ls_fcode TYPE ui_func.
  CLEAR: pt_fcode, pt_fcode[].
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_fcode TO gt_fcode.
*  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_copy.
*  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_fcode TO gt_fcode.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_TREE_CONTRAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_tree_contrainer USING  po_container TYPE REF TO cl_gui_container
                                    po_splitter  TYPE REF TO cl_gui_splitter_container
                                    po_tree      TYPE REF TO cl_gui_alv_tree
                                    pt_grid_fcat TYPE lvc_t_fcat
                                    pv_col
                                    pv_row
                                    pt_data      TYPE ANY TABLE.


  po_container  = po_splitter->get_container( row = pv_row column = pv_col ).

  CREATE OBJECT po_tree
    EXPORTING
      parent                      = po_container
      node_selection_mode         = cl_gui_column_tree=>node_sel_mode_multiple  "
      item_selection              = abap_true "
      no_html_header              = 'X'
      no_toolbar                  = ''
      hide_selection              = 'X'
    EXCEPTIONS
      lifetime_error              = 1
      cntl_system_error           = 2
      create_error                = 3
      failed                      = 4
      illegal_node_selection_mode = 5.

  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'.                          "#EC NOTEXT
  ENDIF.



  po_splitter->set_column_width(
    EXPORTING
      id                = 1                 " Column ID
      width             =  30                " NPlWidth
  ).

  po_splitter->set_column_width(
    EXPORTING
      id                = 2                 " Column ID
      width             =  70                " NPlWidth
  ).


* create Hierarchy-header
  DATA l_hierarchy_header TYPE treev_hhdr.
  PERFORM build_hierarchy_header CHANGING l_hierarchy_header.

* Field_Catalog Define
  PERFORM set_fieldcatalog    USING pt_grid_fcat
                                    'GT_TREE'.
* create emty tree-control
  PERFORM create_emty_treecontrol USING po_tree
                                        pt_grid_fcat
                                        l_hierarchy_header.

* create hierarchy
  PERFORM create_hierarchy USING po_tree.

* add own functioncodes to the toolbar
  PERFORM change_toolbar  USING po_tree.

* register events
  PERFORM register_events  USING po_tree.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BUILD_HIERARCHY_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_HIERARCHY_HEADER  text
*----------------------------------------------------------------------*
FORM build_hierarchy_header  CHANGING
                               p_hierarchy_header TYPE treev_hhdr.

  p_hierarchy_header-heading = 'Header'.                    "#EC NOTEXT
  p_hierarchy_header-tooltip = 'Hierarchy Header'.          "#EC NOTEXT
  p_hierarchy_header-width = 50.
  p_hierarchy_header-width_pix = ''.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_HIERARCHY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_hierarchy USING po_tree     TYPE REF TO cl_gui_alv_tree.

* add data to tree
  DATA: l_node1_key TYPE lvc_nkey,
        l_node2_key TYPE lvc_nkey,
        l_node3_key TYPE lvc_nkey.

  SORT gt_tree BY otype begda objid.
  DELETE ADJACENT DUPLICATES FROM gt_tree COMPARING otype begda objid.

  LOOP AT gt_tree.
    ON CHANGE OF gt_tree-otype.
      PERFORM add_node1_line USING    po_tree
                                      gt_tree
                                       ''
                             CHANGING l_node1_key.
    ENDON.

    ON CHANGE OF gt_tree-begda.
      PERFORM add_node2_line USING    po_tree
                                      gt_tree
                                      l_node1_key
                             CHANGING l_node2_key.
    ENDON.

    PERFORM add_complete_line USING  po_tree
                                     gt_tree
                                     l_node2_key
                            CHANGING l_node3_key.
  ENDLOOP.

* calculate totals
  CALL METHOD po_tree->update_calculations.

* this method must be called to send the data to the frontend
  CALL METHOD po_tree->frontend_update.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_NODE1_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_DATA1  text
*      -->P_1536   text
*      <--P_L_NODE1_KEY  text
*----------------------------------------------------------------------*
FORM add_node1_line  USING   po_tree     TYPE REF TO cl_gui_alv_tree
                             ps_data LIKE gs_1000
                               p_relat_key TYPE lvc_nkey
                     CHANGING  p_node_key TYPE lvc_nkey.

  DATA: l_node_text TYPE lvc_value.

* set item-layout
  DATA: lt_item_layout TYPE lvc_t_layi,
        ls_item_layout TYPE lvc_s_layi.

  ls_item_layout-t_image   = '@3P@'.
  ls_item_layout-fieldname = po_tree->c_hierarchy_column_name.
  ls_item_layout-style     = cl_gui_column_tree=>style_intensifd_critical.
  APPEND ls_item_layout TO lt_item_layout.

* add node
  l_node_text =  ps_data-otype.

  DATA: ls_node TYPE lvc_s_layn.
  ls_node-n_image   = space.
  ls_node-exp_image = space.

  CALL METHOD po_tree->add_node
    EXPORTING
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_node_text
      is_outtab_line   = ps_data
      is_node_layout   = ls_node
      it_item_layout   = lt_item_layout
    IMPORTING
      e_new_node_key   = p_node_key.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_NODE2_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PO_TREE  text
*      -->P_GT_DATA1  text
*      -->P_L_NODE1_KEY  text
*      <--P_L_NODE2_KEY  text
*----------------------------------------------------------------------*
FORM add_node2_line  USING    po_tree     TYPE REF TO cl_gui_alv_tree
                              ps_data LIKE gs_1000
                               p_relat_key TYPE lvc_nkey
                     CHANGING  p_node_key TYPE lvc_nkey.


  DATA: l_node_text TYPE lvc_value.

* set item-layout
  DATA: lt_item_layout TYPE lvc_t_layi,
        ls_item_layout TYPE lvc_s_layi.

  ls_item_layout-t_image = '@3Y@'.
  ls_item_layout-style   = cl_gui_column_tree=>style_intensified.
  ls_item_layout-fieldname = po_tree->c_hierarchy_column_name.
  APPEND ls_item_layout TO lt_item_layout.

* add node
  l_node_text =  ps_data-begda.


  DATA: relat TYPE int4.

  relat = cl_gui_column_tree=>relat_last_child.
  CALL METHOD po_tree->add_node
    EXPORTING
      i_relat_node_key = p_relat_key
      i_relationship   = relat
      i_node_text      = l_node_text
      is_outtab_line   = ps_data
      it_item_layout   = lt_item_layout
    IMPORTING
      e_new_node_key   = p_node_key.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_COMPLETE_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PO_TREE  text
*      -->P_GT_DATA1  text
*      -->P_L_NODE2_KEY  text
*      <--P_L_NODE3_KEY  text
*----------------------------------------------------------------------*
FORM add_complete_line  USING   po_tree     TYPE REF TO cl_gui_alv_tree
                                ps_data LIKE gs_1000
                               p_relat_key TYPE lvc_nkey
                     CHANGING  p_node_key TYPE lvc_nkey.


  DATA: l_node_text TYPE lvc_value.
  DATA: l_number    TYPE regen-maxcount.

* set item-layout
  DATA: lt_item_layout TYPE lvc_t_layi,
        ls_item_layout TYPE lvc_s_layi.
  ls_item_layout-fieldname = po_tree->c_hierarchy_column_name.

  ls_item_layout-class   = cl_gui_column_tree=>item_class_text.
  ls_item_layout-editable = ''.

  CALL FUNCTION 'ISU_RANDOM_INTEGER'
    EXPORTING
      ranint_max    = 10
    IMPORTING
      ranint_number = l_number.

  ls_item_layout-style    = l_number.

  " 체크박스 사용 시
*  ls_item_layout-class   = cl_gui_column_tree=>item_class_checkbox.
*  ls_item_layout-editable = 'X'.
  APPEND ls_item_layout TO lt_item_layout.

  CLEAR ls_item_layout.
  ls_item_layout-fieldname = 'STEXT'.
  ls_item_layout-alignment = cl_gui_column_tree=>align_center.
  APPEND ls_item_layout TO lt_item_layout.

  l_node_text =  ps_data-stext.

  DATA: ls_node TYPE lvc_s_layn.
  ls_node-n_image   = space.
  ls_node-exp_image = space.


  CALL METHOD po_tree->add_node
    EXPORTING
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      is_outtab_line   = ps_data
      i_node_text      = l_node_text
      is_node_layout   = ls_node
      it_item_layout   = lt_item_layout
    IMPORTING
      e_new_node_key   = p_node_key.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHANGE_TOOLBAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PO_TREE  text
*----------------------------------------------------------------------*
FORM change_toolbar  USING    po_tree TYPE REF TO cl_gui_alv_tree.

** get toolbar control
*  CALL METHOD po_tree->get_toolbar_object
*    IMPORTING
*      er_toolbar = g_toolbar.
*
*  CHECK NOT g_toolbar IS INITIAL.
*
** add seperator to toolbar
*  CALL METHOD g_toolbar->add_button
*    EXPORTING
*      fcode     = ''
*      icon      = ''
*      butn_type = cntb_btype_sep
*      text      = ''
*      quickinfo = 'This is a Seperator'.                    "#EC NOTEXT
*
** add Standard Button to toolbar (for Delete Subtree)
*  CALL METHOD g_toolbar->add_button
*    EXPORTING
*      fcode     = 'DELETE'
*      icon      = '@18@'
*      butn_type = cntb_btype_button
*      text      = ''
*      quickinfo = 'Delete subtree'.                         "#EC NOTEXT
*
** add Dropdown Button to toolbar (for Insert Line)
*  CALL METHOD g_toolbar->add_button
*    EXPORTING
*      fcode     = 'INSERT_LC'
*      icon      = '@17@'
*      butn_type = cntb_btype_dropdown
*      text      = ''
*      quickinfo = 'Insert Line'.                            "#EC NOTEXT
*
** set event-handler for toolbar-control
*  CREATE OBJECT g_toolbar_event_receiver.
*  SET HANDLER g_toolbar_event_receiver->on_function_selected
*                                                      FOR g_toolbar.
*  SET HANDLER g_toolbar_event_receiver->on_toolbar_dropdown
*                                                      FOR g_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  REGISTER_EVENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PO_TREE  text
*----------------------------------------------------------------------*
FORM register_events  USING    po_tree     TYPE REF TO cl_gui_alv_tree.

* define the events which will be passed to the backend
  DATA: lt_events TYPE cntl_simple_events,
        l_event   TYPE cntl_simple_event.

* define the events which will be passed to the backend
  l_event-eventid = cl_gui_column_tree=>eventid_expand_no_children.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_checkbox_change.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_header_context_men_req.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_node_context_menu_req.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_item_context_menu_req.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_header_click.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_item_keypress.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_item_double_click.
  l_event-appl_event = 'X'.
  APPEND l_event TO lt_events.

  CALL METHOD po_tree->set_registered_events
    EXPORTING
      events                    = lt_events
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'.                          "#EC NOTEXT
  ENDIF.



* set Handler
  CREATE OBJECT g_tree_event_receiver.
  SET HANDLER g_tree_event_receiver->handle_node_ctmenu_request  FOR po_tree.
  SET HANDLER g_tree_event_receiver->handle_node_ctmenu_selected FOR po_tree.
  SET HANDLER g_tree_event_receiver->handle_item_ctmenu_request  FOR po_tree.
  SET HANDLER g_tree_event_receiver->handle_item_ctmenu_selected FOR po_tree.
  SET HANDLER g_tree_event_receiver->handle_item_double_click    FOR po_tree.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_EMTY_TREECONTROL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PO_TREE  text
*----------------------------------------------------------------------*
FORM create_emty_treecontrol  USING     po_tree     TYPE REF TO cl_gui_alv_tree
                                        pt_fieldcat TYPE lvc_t_fcat
                                        p_hierarchy_header TYPE treev_hhdr.
* repid for saving variants
  DATA: ls_variant TYPE disvariant.
  ls_variant-report = sy-repid.

  gt_tree[] = gt_temp[].

  CALL METHOD po_tree->set_table_for_first_display
    EXPORTING
      is_hierarchy_header = p_hierarchy_header
*     i_background_id     = 'ALV_BACKGROUND'
      i_save              = 'A'
      is_variant          = ls_variant
    CHANGING
      it_outtab           = gt_temp[] "table must be emty !!
      it_fieldcatalog     = pt_fieldcat[].

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_STYLE_BUTTON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<FS_LINE>  text
*      <--P_G_STYL_BTN  text
*----------------------------------------------------------------------*
FORM set_grid_style_button  USING   ps_data LIKE gt_data1
                         CHANGING ct_style TYPE lvc_t_styl.


  DATA: ls_button TYPE lvc_s_styl.
  CLEAR ct_style.

  ls_button-style     = cl_gui_alv_grid=>mc_style_button.
  ls_button-style2    = space.
  ls_button-style3    = space.
  ls_button-style4    = space.

  ls_button-fieldname = 'MC_SHORT'.
  INSERT ls_button INTO TABLE ct_style.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  OPEN_DIALOGBOX_HTMLVIEWER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<FS_DATA1>_MC_SHORT  text
*      -->P_LV_MODE  text
*      -->P_LV_URL  text
*----------------------------------------------------------------------*
FORM open_dialogbox_htmlviewer  USING    pv_title
                                         pv_mode
                                         pv_url.


  zcmuicl0=>url_in_htmlviewer(
    EXPORTING
      iv_title  = pv_title
      iv_width  = '700'
      iv_height = '500'
      iv_url    = pv_url
      IMPORTING
        eo_dialogbox = DATA(lo_dialogbox) ).


  " 변경모드일 경우 이벤트 등록(close -> 카운트 리프레시)
  " 조회모드일 경우 여러개 창 띄울 수 있음.(close 이벤트 타지 않기 때문에 dialog object가 각자 살아있음)
  IF pv_mode = 'EDIT'.

    CALL METHOD lo_dialogbox->reg_event_close
      EXPORTING
        register = 1.

    IF g_dialogbox_handler IS INITIAL.
      CREATE OBJECT g_dialogbox_handler.
    ENDIF.

    SET HANDLER g_dialogbox_handler->on_dialogbox_close FOR lo_dialogbox.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_DISPLAY_CUSTOM_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0041   text
*      -->P_0042   text
*----------------------------------------------------------------------*
FORM create_display_custom_alv  USING    gv_contrainer_nm
                                         pv_tabnm
                                         pv_assign_seq.

  DATA lv_seq TYPE i.

  DATA lv_tabnm(20).
  DATA lv_tabnm_tb(20).

  FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.

  lv_seq = pv_assign_seq.

  " 각 Contrainer 구성 object
  PERFORM get_ref_cont_object USING  lv_seq.

  " TAB NAME & ITAB NAME Assign
  lv_tabnm    = pv_tabnm.
  lv_tabnm_tb = |{ pv_tabnm }[]|.

  ASSIGN (lv_tabnm_tb) TO <fs_tab>.

  CHECK <fs_tab> IS ASSIGNED.

  IF <fs_g_alv_grid> IS INITIAL AND <fs_g_alv_grid> IS ASSIGNED.

    PERFORM create_custom_contrainer USING  <fs_g_alv_grid>
                                            gv_contrainer_nm
                                            <fs_g_custom>.

    PERFORM create_grid_object USING <fs_g_alv_grid>
                                     <fs_g_fcat>
                                     <fs_g_layout>
                                     <fs_g_sort>
                                     <fs_g_fcode>
                                     lv_tabnm .

    PERFORM alv_data_display USING <fs_g_alv_grid>
                                   <fs_g_fcat>
                                   <fs_g_layout>
                                   <fs_g_sort>
                                   <fs_g_fcode>
                                   <fs_tab>.
  ELSE.
    PERFORM alv_refresh_grid USING <fs_g_alv_grid>.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_CUSTOM_CONTRAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<FS_G_ALV_GRID>  text
*      -->P_GV_CONTRAINER_NM  text
*      -->P_<FS_G_CUSTOM>  text
*----------------------------------------------------------------------*
FORM create_custom_contrainer  USING    po_grid TYPE REF TO cl_gui_alv_grid
                                        pv_contrainer_nm
                                        po_custom TYPE REF TO cl_gui_custom_container.

  CREATE OBJECT po_custom
    EXPORTING
      container_name = pv_contrainer_nm.

  CREATE OBJECT po_grid
    EXPORTING
      i_parent = po_custom.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_DISPLAY_SINGLE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0017   text
*----------------------------------------------------------------------*
FORM create_display_single_alv  USING pv_tabnm pv_assign_seq.


  DATA lv_seq TYPE i.

  DATA lv_tabnm(20).
  DATA lv_tabnm_tb(20).

  FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.

  lv_seq = pv_assign_seq.

*--------------------------------------------------------------------*
  " 상위 docking object 한번만 실행..
  PERFORM get_ref_docking_spliter_object USING  lv_seq '1' '1'.
*--------------------------------------------------------------------*

  " 각 Contrainer 구성 object
  PERFORM get_ref_cont_object USING  lv_seq.

  " TAB NAME & ITAB NAME Assign
  lv_tabnm    = pv_tabnm.
  lv_tabnm_tb = |{ pv_tabnm }[]|.

  ASSIGN (lv_tabnm_tb) TO <fs_tab>.

  CHECK <fs_tab> IS ASSIGNED.

  IF <fs_g_alv_grid> IS INITIAL AND <fs_g_alv_grid> IS ASSIGNED.

    PERFORM create_docking_container USING <fs_g_alv_grid>
                                           <fs_g_container>
                                           <fs_g_splitter>
                                           '1'
                                           '1'.

    PERFORM create_grid_object USING <fs_g_alv_grid>
                                     <fs_g_fcat>
                                     <fs_g_layout>
                                     <fs_g_sort>
                                     <fs_g_fcode>
                                     lv_tabnm .

    PERFORM alv_data_display USING <fs_g_alv_grid>
                                   <fs_g_fcat>
                                   <fs_g_layout>
                                   <fs_g_sort>
                                   <fs_g_fcode>
                                   <fs_tab>.
  ELSE.
    PERFORM alv_refresh_grid USING <fs_g_alv_grid>.
  ENDIF.

ENDFORM.
