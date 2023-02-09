*&---------------------------------------------------------------------*
*&  Include           ZCMCVC000
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*

CONSTANTS: gc_bukrs LIKE bkpf-bukrs        VALUE    'SM00', "회사코드
           gc_kokrs LIKE csks-kokrs        VALUE    'SM00', "관리회계영역
           gc_ktopl LIKE cska-ktopl        VALUE    'SM00', "계정과목표.
           gc_fikrs LIKE fmcit-fikrs       VALUE    'SM00'. "예산관리

CONSTANTS: gc_plvar  LIKE hrp1000-plvar     VALUE    '01',
           gc_istat1 LIKE hrp1000-istat     VALUE    '1',
           gc_istat2 LIKE hrp1000-istat     VALUE    '2',
           gc_istat3 LIKE hrp1000-istat     VALUE    '3',
           gc_istat4 LIKE hrp1000-istat     VALUE    '4',
           gc_istat5 LIKE hrp1000-istat     VALUE    '5',
           gc_o      LIKE hrp1000-otype     VALUE    'O',
           gc_eo     LIKE hrp1000-otype     VALUE    'EO',
           gc_sc     LIKE hrp1000-otype     VALUE    'SC',
           gc_cg     LIKE hrp1000-otype     VALUE    'CG',
           gc_cs     LIKE hrp1000-otype     VALUE    'CS',
           gc_st     LIKE hrp1000-otype     VALUE    'ST',
           gc_se     LIKE hrp1000-otype     VALUE    'SE',
           gc_sm     LIKE hrp1000-otype     VALUE    'SM',
           gc_cw     LIKE hrp1000-otype     VALUE    'CW',
           gc_p      LIKE hrp1000-otype     VALUE    'P',
           gc_e      LIKE hrp1000-otype     VALUE    'E',
           gc_d      LIKE hrp1000-otype     VALUE    'D'.
*----------------------------------------------------------------------*
* 공통
*----------------------------------------------------------------------*
TYPE-POOLS:cntl,icon,cntb,slis.
DATA: ok_code LIKE sy-ucomm.        " SCREEN OK_CODE
* Unix server file directory
DATA: gc_unixdev(50) TYPE c VALUE  '/sapmnt/'.
DATA: gv_ucom(3).
DATA: gv_dobid LIKE hrp1000-objid .
DATA: gv_peryr LIKE hrp1739-peryr.
DATA: gv_perid LIKE hrp1739-perid..
DATA: gv_begda TYPE begda.
DATA: gv_endda TYPE endda.
*
DATA: gv_yeartxt LIKE sy-msgv1,
      gv_sesstxt LIKE sy-msgv1.

DATA: BEGIN OF gt_menu OCCURS 0,
        fcode LIKE sy-ucomm,
      END OF gt_menu .
* Error Log
DATA: gt_log LIKE zcmslog OCCURS 0 WITH HEADER LINE .
*
DATA: gv_togl TYPE c .      " Column SCREEN TOGGLE ON/OFF
DATA: gv_togl_r TYPE c .    " Row SCREEN TOGGLE ON/OFF
*
DATA: gv_lines LIKE sy-tabix .
* Pop Up 실행여부
DATA: gv_answer(1),
      gc_answer TYPE c  VALUE 'J' .     "저장여부
*&---------------------------------------------------------------------*
*&  ALV
*&---------------------------------------------------------------------*


DATA: gt_rows TYPE lvc_t_row,
      gs_rows TYPE lvc_s_row.
CONSTANTS: gc_screen_inst TYPE string VALUE 'INST',
           gc_screen_dele TYPE string VALUE 'DELE',
           gc_screen_issu TYPE string VALUE 'ISSU',
           gc_screen_sele TYPE string VALUE 'SELE'.
CONSTANTS: gc_insert           TYPE string VALUE 'INST',
           gc_insert_text      TYPE string VALUE '추가',
           gc_delete           TYPE string VALUE 'DELE',
           gc_delete_text      TYPE string VALUE '삭제',
           gc_delete_sign      TYPE string VALUE 'DELES',
           gc_delete_sign_text TYPE string VALUE '삭제표시',
           gc_inse             TYPE ui_func  VALUE 'INSE',
           gc_togg             TYPE ui_func  VALUE 'TOGG',
           gc_disp             TYPE ui_func  VALUE 'DISP',
           gc_cmnt             TYPE ui_func  VALUE 'CMNT',
           gc_save             TYPE ui_func  VALUE 'SAVE'.
* ===============

CONSTANTS: gc_set TYPE c VALUE 'X'.
*
CONSTANTS: gc_extension  TYPE i VALUE 3000.  "Docking size

CONSTANTS gc_gt_grid_fcat        TYPE char50 VALUE 'GT_GRID_FCAT'.
CONSTANTS gc_g_container         TYPE char50 VALUE 'G_CONTAINER'.
CONSTANTS gc_g_docking_container TYPE char50 VALUE 'G_DOCKING_CONTAINER'.
CONSTANTS gc_g_custom            TYPE char50 VALUE 'G_CUSTOM'.
CONSTANTS gc_g_grid              TYPE char50 VALUE 'G_GRID'.
CONSTANTS gc_g_splitter          TYPE char50 VALUE 'G_SPLITTER'.
CONSTANTS gc_gs_layout           TYPE char50 VALUE 'GS_LAYOUT'.
CONSTANTS gc_gt_sort             TYPE char50 VALUE 'GT_SORT'.
CONSTANTS gc_gt_fcode            TYPE char50 VALUE 'GT_FCODE'.
CONSTANTS gc_g_tree              TYPE char50 VALUE 'G_TREE'.

FIELD-SYMBOLS : <fs_g_container>         TYPE REF TO cl_gui_container,
                <fs_g_docking_container> TYPE REF TO cl_gui_docking_container,
                <fs_g_alv_grid>          TYPE REF TO cl_gui_alv_grid,
                <fs_g_splitter>          TYPE REF TO cl_gui_splitter_container,
                <fs_g_custom>            TYPE REF TO cl_gui_custom_container,
                <fs_g_tree>              TYPE REF TO cl_gui_alv_tree,
                <fs_g_fcat>              TYPE lvc_t_fcat,
                <fs_g_sort>              TYPE lvc_t_sort,
                <fs_g_fcode>             TYPE ui_functions,
                <fs_g_layout>            TYPE lvc_s_layo.
* Grid Setting
DATA: gt_xls_fcat   TYPE lvc_t_fcat,
      gt_grid_fcat  TYPE lvc_t_fcat,
      gt_grid_fcat1 TYPE lvc_t_fcat,
      gt_grid_fcat2 TYPE lvc_t_fcat,
      gt_grid_fcat3 TYPE lvc_t_fcat,
      gt_grid_fcat4 TYPE lvc_t_fcat,
      gt_grid_fcat5 TYPE lvc_t_fcat,
      gt_grid_fcat6 TYPE lvc_t_fcat,
      gt_grid_fcat7 TYPE lvc_t_fcat,
      gt_grid_fcat8 TYPE lvc_t_fcat,
      gt_grid_fcat9 TYPE lvc_t_fcat.
*
DATA: g_container1 TYPE REF TO cl_gui_container,
      g_container2 TYPE REF TO cl_gui_container,
      g_container3 TYPE REF TO cl_gui_container,
      g_container4 TYPE REF TO cl_gui_container,
      g_container5 TYPE REF TO cl_gui_container,
      g_container6 TYPE REF TO cl_gui_container,
      g_container7 TYPE REF TO cl_gui_container,
      g_container8 TYPE REF TO cl_gui_container,
      g_container9 TYPE REF TO cl_gui_container.
*
DATA: g_docking_container  TYPE REF TO cl_gui_docking_container,
      g_docking_container1 TYPE REF TO cl_gui_docking_container,
      g_docking_container2 TYPE REF TO cl_gui_docking_container,
      g_docking_container3 TYPE REF TO cl_gui_docking_container,
      g_docking_container4 TYPE REF TO cl_gui_docking_container,
      g_docking_container5 TYPE REF TO cl_gui_docking_container,
      g_docking_container6 TYPE REF TO cl_gui_docking_container,
      g_docking_container7 TYPE REF TO cl_gui_docking_container,
      g_docking_container8 TYPE REF TO cl_gui_docking_container,
      g_docking_container9 TYPE REF TO cl_gui_docking_container.
*
DATA: g_grid  TYPE REF TO cl_gui_alv_grid,
      g_grid1 TYPE REF TO cl_gui_alv_grid,
      g_grid2 TYPE REF TO cl_gui_alv_grid,
      g_grid3 TYPE REF TO cl_gui_alv_grid,
      g_grid4 TYPE REF TO cl_gui_alv_grid,
      g_grid5 TYPE REF TO cl_gui_alv_grid,
      g_grid6 TYPE REF TO cl_gui_alv_grid,
      g_grid7 TYPE REF TO cl_gui_alv_grid,
      g_grid8 TYPE REF TO cl_gui_alv_grid,
      g_grid9 TYPE REF TO cl_gui_alv_grid.
*
DATA: g_splitter  TYPE REF TO cl_gui_splitter_container,
      g_splitter1 TYPE REF TO cl_gui_splitter_container,
      g_splitter2 TYPE REF TO cl_gui_splitter_container,
      g_splitter3 TYPE REF TO cl_gui_splitter_container,
      g_splitter4 TYPE REF TO cl_gui_splitter_container,
      g_splitter5 TYPE REF TO cl_gui_splitter_container,
      g_splitter6 TYPE REF TO cl_gui_splitter_container,
      g_splitter7 TYPE REF TO cl_gui_splitter_container,
      g_splitter8 TYPE REF TO cl_gui_splitter_container,
      g_splitter9 TYPE REF TO cl_gui_splitter_container.
*
DATA: g_toolbar             TYPE REF TO cl_gui_toolbar.
*
DATA: gs_layout  TYPE lvc_s_layo,
      gs_layout1 TYPE lvc_s_layo,
      gs_layout2 TYPE lvc_s_layo,
      gs_layout3 TYPE lvc_s_layo,
      gs_layout4 TYPE lvc_s_layo,
      gs_layout5 TYPE lvc_s_layo,
      gs_layout6 TYPE lvc_s_layo,
      gs_layout7 TYPE lvc_s_layo,
      gs_layout8 TYPE lvc_s_layo,
      gs_layout9 TYPE lvc_s_layo.
*
DATA: gt_sort  TYPE lvc_t_sort,
      gt_sort1 TYPE lvc_t_sort,
      gt_sort2 TYPE lvc_t_sort,
      gt_sort3 TYPE lvc_t_sort,
      gt_sort4 TYPE lvc_t_sort,
      gt_sort5 TYPE lvc_t_sort,
      gt_sort6 TYPE lvc_t_sort,
      gt_sort7 TYPE lvc_t_sort,
      gt_sort8 TYPE lvc_t_sort,
      gt_sort9 TYPE lvc_t_sort.
*
DATA: gt_fcode  TYPE ui_functions,
      gt_fcode1 TYPE ui_functions,
      gt_fcode2 TYPE ui_functions,
      gt_fcode3 TYPE ui_functions,
      gt_fcode4 TYPE ui_functions,
      gt_fcode5 TYPE ui_functions,
      gt_fcode6 TYPE ui_functions,
      gt_fcode7 TYPE ui_functions,
      gt_fcode8 TYPE ui_functions,
      gt_fcode9 TYPE ui_functions.
*
DATA: gs_scroll             TYPE lvc_s_stbl.
* 오즈용
DATA  :  gv_init.
DATA  :  go_container TYPE REF TO cl_gui_custom_container.
DATA  :  go_html_viewer TYPE REF TO cl_gui_html_viewer.
DATA  :  lv_zurl TYPE string.
*
* Customer-Screen Setting

DATA: g_custom_container TYPE REF TO cl_gui_custom_container.
DATA: g_container        TYPE scrfname VALUE 'G_CUSTOM_CONTAINER'.
* Tree Setting
DATA: g_html_control     TYPE REF TO cl_gui_html_viewer.
DATA: g_container_tree   TYPE scrfname VALUE 'G_CONTAINER_TREE'.
DATA: g_tree             TYPE REF TO cl_gui_alv_tree.
DATA: g_tree1            TYPE REF TO cl_gui_alv_tree.
DATA: g_tree2            TYPE REF TO cl_gui_alv_tree.
DATA: g_tree3            TYPE REF TO cl_gui_alv_tree.
DATA: g_tree4            TYPE REF TO cl_gui_alv_tree.
DATA: g_tree5            TYPE REF TO cl_gui_alv_tree.
DATA: g_tree6            TYPE REF TO cl_gui_alv_tree.
DATA: g_tree7            TYPE REF TO cl_gui_alv_tree.
DATA: g_tree8            TYPE REF TO cl_gui_alv_tree.
DATA: g_tree9            TYPE REF TO cl_gui_alv_tree.
DATA: g_return           TYPE i.
DATA: gt_tree_fcat       TYPE lvc_t_fcat.
DATA: gs_tree_head       TYPE treev_hhdr.
DATA: gt_item_layout     TYPE lvc_t_layi WITH HEADER LINE .
*
DATA: gs_hierarchy_header TYPE treev_hhdr,
      gs_node_layout      TYPE lvc_s_layn,
      gs_item_layout      TYPE lvc_s_laci.

DATA: gs_vari TYPE disvariant .
* Text Edit
DATA: g_editor           TYPE REF TO cl_gui_textedit,
      g_editor_container TYPE REF TO cl_gui_custom_container.
*
DATA: g_custom  TYPE REF TO cl_gui_custom_container,
      g_custom1 TYPE REF TO cl_gui_custom_container,
      g_custom2 TYPE REF TO cl_gui_custom_container,
      g_custom3 TYPE REF TO cl_gui_custom_container,
      g_custom4 TYPE REF TO cl_gui_custom_container,
      g_custom5 TYPE REF TO cl_gui_custom_container,
      g_custom6 TYPE REF TO cl_gui_custom_container,
      g_custom7 TYPE REF TO cl_gui_custom_container,
      g_custom8 TYPE REF TO cl_gui_custom_container,
      g_custom9 TYPE REF TO cl_gui_custom_container.
*
DATA: g_editor1 TYPE REF TO cl_gui_textedit,
      g_editor2 TYPE REF TO cl_gui_textedit,
      g_editor3 TYPE REF TO cl_gui_textedit,
      g_editor4 TYPE REF TO cl_gui_textedit,
      g_editor5 TYPE REF TO cl_gui_textedit,
      g_editor6 TYPE REF TO cl_gui_textedit,
      g_editor7 TYPE REF TO cl_gui_textedit,
      g_editor8 TYPE REF TO cl_gui_textedit,
      g_editor9 TYPE REF TO cl_gui_textedit.

* Top Of Page
DATA: g_dyndoc_id01  TYPE REF TO cl_dd_document,
      g_dyndoc_id02  TYPE REF TO cl_dd_document,
      g_dyndoc_id03  TYPE REF TO cl_dd_document,
      g_dyndoc_id04  TYPE REF TO cl_dd_document,
      g_dyndoc_id05  TYPE REF TO cl_dd_document,
      g_html_cntrl01 TYPE REF TO cl_gui_html_viewer,
      g_html_cntrl02 TYPE REF TO cl_gui_html_viewer,
      g_html_cntrl03 TYPE REF TO cl_gui_html_viewer,
      g_html_cntrl04 TYPE REF TO cl_gui_html_viewer,
      g_html_cntrl05 TYPE REF TO cl_gui_html_viewer.



DATA go_dialogbox TYPE REF TO  cl_gui_dialogbox_container.
DATA go_dialogbox1 TYPE REF TO  cl_gui_dialogbox_container.
DATA go_dialogbox2 TYPE REF TO  cl_gui_dialogbox_container.
