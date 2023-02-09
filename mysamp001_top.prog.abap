*&---------------------------------------------------------------------*
*&  Include           MYSAMP001_TOP
*&---------------------------------------------------------------------*
CLASS cl_gui_column_tree DEFINITION LOAD.
CLASS cl_gui_cfw DEFINITION LOAD.

CONSTANTS : gc_tabnm TYPE char20 VALUE 'GT_DATA'.

DATA gv_ucomm TYPE syucomm.
DATA gv_index TYPE i.

DATA  g_styl_btn       TYPE     lvc_t_styl.

DATA : BEGIN OF gs_1000 .
         INCLUDE TYPE hrp1000.
         DATA :  style TYPE  lvc_t_styl,
       END OF gs_1000.



DATA : gt_tree LIKE TABLE OF gs_1000 WITH HEADER LINE.
DATA : gt_temp LIKE TABLE OF gs_1000 WITH HEADER LINE.

DATA : gt_data1 LIKE TABLE OF gs_1000 WITH HEADER LINE.
DATA : gt_data2 LIKE TABLE OF gs_1000 WITH HEADER LINE.
DATA : gt_data3 LIKE TABLE OF gs_1000 WITH HEADER LINE.
DATA : gt_data4 LIKE TABLE OF gs_1000 WITH HEADER LINE.
DATA : gt_data5 LIKE TABLE OF gs_1000 WITH HEADER LINE.
DATA : gt_data6 LIKE TABLE OF gs_1000 WITH HEADER LINE.
DATA : gt_data7 LIKE TABLE OF gs_1000 WITH HEADER LINE.
DATA : gt_data8 LIKE TABLE OF gs_1000 WITH HEADER LINE.
DATA : gt_data9 LIKE TABLE OF gs_1000 WITH HEADER LINE.


DATA : gt_alv5 LIKE TABLE OF gs_1000 WITH HEADER LINE.
DATA : gt_alv6 LIKE TABLE OF gs_1000 WITH HEADER LINE.

DATA : gt_sdata LIKE TABLE OF gs_1000 WITH HEADER LINE.
