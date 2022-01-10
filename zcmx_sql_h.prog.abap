*&---------------------------------------------------------------------*
*& Report ZCMX_SQL_H
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcmx_sql_h MESSAGE-ID zcm01.


DATA : ok_code TYPE sy-ucomm.

TYPES: gty_text(132) TYPE c OCCURS 0.

DATA:  gt_text TYPE gty_text.


* Type for output
*TYPES: BEGIN OF gty_s_result,
*         f001 TYPE  string,
*         f002 TYPE  string,
*         f003 TYPE  string,
*       END OF gty_s_result,

*TYPES : gty_s_result TYPE znxs_str,
*
*        gty_t_result TYPE STANDARD TABLE OF  gty_s_result.

* Data declaration
DATA: gr_sql_connection         TYPE REF TO cl_sql_connection,
      gr_sql_statement          TYPE REF TO cl_sql_statement,
      gr_sql_result_set         TYPE REF TO cl_sql_result_set,
*      gt_result                 TYPE gty_t_result,
*      gs_result                 TYPE gty_s_result,

      gv_where_clause_statement TYPE string,
      gv_error_text             TYPE string,

      gr_sql_exception          TYPE REF TO cx_sql_exception,
      gr_sql_parameter_invalid  TYPE REF TO cx_parameter_invalid,
      gr_parameter_invalid_type TYPE REF TO cx_parameter_invalid_type,
      gr_salv_exception         TYPE REF TO cx_salv_msg.

FIELD-SYMBOLS : <fs_struc> TYPE any.
FIELD-SYMBOLS : <fs_table> TYPE ANY TABLE.


DATA : gv_operation(20).

INITIALIZATION.


START-OF-SELECTION.

  CALL SCREEN 100.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR 'T100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'EXEC'.
      CLEAR ok_code.
      PERFORM execute_editor_query.

    WHEN OTHERS.
      CLEAR ok_code..

  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form execute_editor_query
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM execute_editor_query .
  DATA : lv_answer.
  DATA : lv_text TYPE text100.

  lv_text = '실행하시겠습니까?'.
  PERFORM data_popup_to_confirm_yn(zcms0) USING lv_answer
                                         '실행'
                                         lv_text
                                         ''.
  CHECK lv_answer = 'J' .

  PERFORM get_editor .

  TRANSLATE gv_where_clause_statement TO UPPER CASE.

  IF gv_where_clause_statement CS 'SELECT'.
    gv_operation = 'SELECT'.
  ELSE.
    IF sy-uname CS 'SSUOP'.

    ELSE.
      MESSAGE s001 WITH 'DB Update 실행불가!' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
  ENDIF.

* Step 1 : database connection 설정.
  PERFORM make_db_connection  CHANGING gr_sql_connection.

* Step 2 : statement object를 instance한다.
  PERFORM ini_sql_statement     USING gr_sql_connection
                             CHANGING gr_sql_statement.

* Step 3 : SQL을 실행한다. ( result set class를 득한다. )
  PERFORM issue_native_sql_call USING gr_sql_statement
                                      gv_where_clause_statement
                             CHANGING gr_sql_result_set .

  IF gv_operation = 'SELECT'.
* Step 4 : Make dynamic Table
    PERFORM set_select_operation_struc USING gr_sql_result_set.

* Step 5 : 획득한 result set class의 결과가 itab에 저장될 수 있도록 지정해 준다.
    PERFORM assign_target_result    USING gr_sql_result_set.

* Step 6 : 획득한 result set class의 결과를 itab에 채워준다.
    PERFORM retrieve_complete_result_set USING gr_sql_result_set.
  ENDIF.

* Step 7 : 획득한 result set class의 결과를 itab을 닫아준다.
  PERFORM close_query USING gr_sql_result_set..

* Step 8 : DB connection을 닫아준다.
  PERFORM close_db_connection USING gr_sql_connection.

* Step 9 : itab을 화면에 보여준다.
  PERFORM display_result .

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_EDITOR OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_editor OUTPUT.

  "TEST
  IF gt_text[] IS INITIAL .
    APPEND  `SELECT STUDENT12 as F01, STOBJID as F02 FROM CMACBPST ` TO  gt_text.
  ENDIF.

  CALL FUNCTION 'RH_EDITOR_SET'
    EXPORTING
      repid          = sy-repid
      dynnr          = '0100'
      controlname    = 'CON100'
      max_cols       = '132'
      show_tool      = ' '
      show_status    = ' '
      display_mode   = ' '
    TABLES
      lines          = gt_text[]
    EXCEPTIONS
      create_error   = 1
      internal_error = 2
      OTHERS         = 3.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form get_editor
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_editor .

  DATA : lv_changed(1).
  DATA : lv_text LIKE LINE OF gt_text.

  CLEAR : gt_text[].
  CALL FUNCTION 'RH_EDITOR_GET'
    EXPORTING
      controlname    = 'CON100'
    IMPORTING
      changed        = lv_changed
    TABLES
      lines          = gt_text[]
    EXCEPTIONS
      internal_error = 1
      OTHERS         = 2.

  CLEAR : gv_where_clause_statement.

  LOOP AT gt_text INTO lv_text.
    CONCATENATE gv_where_clause_statement lv_text
           INTO gv_where_clause_statement
   SEPARATED BY space.
    CLEAR lv_text.
  ENDLOOP.


ENDFORM.


**&---------------------------------------------------------------------*
**& Sub Routines
**&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form MAKE_DB_CONNECTION
*&---------------------------------------------------------------------*
* database connection 을 득한다.
*----------------------------------------------------------------------*
FORM make_db_connection CHANGING po_sql_connection TYPE REF TO cl_sql_connection .

  TRY.
* DB (HANA/Non HANA) Connection을 득한다.
* DB name을 넘겨주지 않으면 default database connection을 넘겨준다.
      po_sql_connection ?= cl_sql_connection=>get_connection( ).

    CATCH cx_parameter_invalid_type INTO gr_parameter_invalid_type.
      gv_error_text = gr_parameter_invalid_type->get_text( ).
      MESSAGE e000 WITH gv_error_text.

    CATCH cx_parameter_invalid INTO gr_sql_parameter_invalid.
      gv_error_text = gr_sql_parameter_invalid->get_text( ).
      MESSAGE e001 WITH gv_error_text.

    CATCH cx_sql_exception INTO gr_sql_exception.
      gv_error_text = gr_sql_exception->get_text( ).
      MESSAGE e001 WITH gv_error_text.

    CATCH cx_salv_msg INTO gr_salv_exception.
      gv_error_text = gr_salv_exception->get_text( ).
      MESSAGE e001 WITH gv_error_text.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INI_SQL_STATEMENT
*&---------------------------------------------------------------------*
* Instantiate the statement object
*----------------------------------------------------------------------*
FORM ini_sql_statement USING po_sql_connection TYPE REF TO cl_sql_connection
                       CHANGING po_sql_statement TYPE REF TO cl_sql_statement.
  IF po_sql_connection IS BOUND.

    TRY.

* Get the SQL Statement reference using the instance of the connection
* 방법1
*        CREATE OBJECT po_sql_statement
*          EXPORTING
*            con_ref = po_sql_connection. " Database Connection
*

* 방법2
        po_sql_statement = po_sql_connection->create_statement( ).

* 10. Catch errors/exceptions (if any)
      CATCH cx_parameter_invalid_type INTO gr_parameter_invalid_type.
        gv_error_text = gr_parameter_invalid_type->get_text( ).
        MESSAGE e000 WITH gv_error_text.

      CATCH cx_parameter_invalid INTO gr_sql_parameter_invalid.
        gv_error_text = gr_sql_parameter_invalid->get_text( ).
        MESSAGE e001 WITH gv_error_text.

      CATCH cx_sql_exception INTO gr_sql_exception.
        gv_error_text = gr_sql_exception->get_text( ).
        MESSAGE e001 WITH gv_error_text.

      CATCH cx_salv_msg INTO gr_salv_exception.
        gv_error_text = gr_salv_exception->get_text( ).
        MESSAGE e001 WITH gv_error_text.

    ENDTRY.

    IF po_sql_connection IS NOT BOUND.
      MESSAGE 'No reference to SQL Statements made' TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ENDIF.

  ELSE.
    MESSAGE 'No connection established' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_NATIVE_SQL_STRING
*&---------------------------------------------------------------------*
* Construct the SQL using Concatenate syntax or string operation
*----------------------------------------------------------------------*
FORM prepare_native_sql_string CHANGING pv_sql TYPE string.

** In line data declaration and converting selection option to a where clause string for S_carrid
*  DATA(lr_seltab) = cl_lib_seltab=>new( it_sel = s_OTYPE[] ).
*  DATA(lv_where_clause_sel) = lr_seltab->sql_where_condition( iv_field = 'M.OTYPE' ).
*
** In line data declaration and converting selection option to a where clause string for S_connid
*  DATA(lr_seltab2) = cl_lib_seltab=>new( it_sel = s_OBJID[] ).
*  DATA(lv_where_clause_sel2) = lr_seltab2->sql_where_condition( iv_field = 'M.OBJID' ).

*--------------------------------------------------------------------*
* Begin of script for HANA Database
*--------------------------------------------------------------------*
* Construct the SQL in SQL Console Eclipse and put it in a string ( Native SQL Only )
* ? : 변수로 치환할 수 있다. (순서대로)
*  pv_sql = | SELECT M.CARRID, M.CONNID, M.FLDATE |
*  && | FROM SFLIGHT AS M |
*  && | WHERE M.MANDT = '{ sy-mandt }' |
*  && | AND { lv_where_clause_sel } |
*  && | AND { lv_where_clause_sel2 } |
*  && | AND FLDATE > ?  |
*  && | AND FLDATE < ?  |
*  && | ORDER BY M.CARRID |
*  .


*--------------------------------------------------------------------*
* End of script for HANA Database
*--------------------------------------------------------------------*

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ISSUE_NATIVE_SQL_CALL
*&---------------------------------------------------------------------*
* Issue Native SQL Call
*----------------------------------------------------------------------*
FORM issue_native_sql_call USING po_sql_statement TYPE REF TO cl_sql_statement
                                 pv_sql TYPE string
                           CHANGING po_result TYPE REF TO cl_sql_result_set

  .


  "SQL에서 [ ? ]로 표시된 Parameter항목을 변경해 준다.( 순서대로 변경된다. )
*  DATA : lv_date TYPE string VALUE '20210311'.
*  GET REFERENCE OF lv_date INTO DATA(lv_date_ref).
*
*  po_sql_statement->set_param( lv_date_ref ).
*
*  DATA : lv_date1 TYPE string VALUE '20220330'.
*  GET REFERENCE OF lv_date1 INTO DATA(lv_date1_ref).
*
*  po_sql_statement->set_param( lv_date1_ref ).

  TRY.



* Using the reference of the statement call the respective methods to execute the query
      po_sql_statement->execute_query(
      EXPORTING
        statement = pv_sql " SELECT Statement Being Executed
        hold_cursor = space
      RECEIVING
        result_set = po_result ). " Database Cursor

* 10. Catch errors/exceptions (if any)
    CATCH cx_parameter_invalid_type INTO gr_parameter_invalid_type.
      gv_error_text = gr_parameter_invalid_type->get_text( ).
      MESSAGE e000 WITH gv_error_text.

    CATCH cx_parameter_invalid INTO gr_sql_parameter_invalid.
      gv_error_text = gr_sql_parameter_invalid->get_text( ).
      MESSAGE e001 WITH gv_error_text.

    CATCH cx_sql_exception INTO gr_sql_exception.
      gv_error_text = gr_sql_exception->get_text( ).
      MESSAGE e001 WITH gv_error_text.

    CATCH cx_salv_msg INTO gr_salv_exception.
      gv_error_text = gr_salv_exception->get_text( ).
      MESSAGE e001 WITH gv_error_text.

  ENDTRY.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form ASSIGN_TARGET_RESULT
*&---------------------------------------------------------------------*
* Assign Target variable for result set
*----------------------------------------------------------------------*
FORM assign_target_result USING po_result TYPE REF TO cl_sql_result_set.


  CHECK gv_operation = 'SELECT'.

  DATA : lr_data  TYPE REF TO data.

  TRY.

* Get the result of the query in a table

      GET REFERENCE OF <fs_table> INTO lr_data.

      po_result->set_param_table(
      EXPORTING
        itab_ref = lr_data ). " Reference to Output Variable

* 10. Catch errors/exceptions (if any)
    CATCH cx_parameter_invalid_type INTO gr_parameter_invalid_type.
      gv_error_text = gr_parameter_invalid_type->get_text( ).
      MESSAGE e000 WITH gv_error_text.

    CATCH cx_parameter_invalid INTO gr_sql_parameter_invalid.
      gv_error_text = gr_sql_parameter_invalid->get_text( ).
      MESSAGE e001 WITH gv_error_text.

    CATCH cx_sql_exception INTO gr_sql_exception.
      gv_error_text = gr_sql_exception->get_text( ).
      MESSAGE e001 WITH gv_error_text.

    CATCH cx_salv_msg INTO gr_salv_exception.
      gv_error_text = gr_salv_exception->get_text( ).
      MESSAGE e001 WITH gv_error_text.

  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form RETRIEVE_COMPLETE_RESULT_SET
*&---------------------------------------------------------------------*
* Retrieve Result set
*----------------------------------------------------------------------*
FORM retrieve_complete_result_set  USING po_result TYPE REF TO cl_sql_result_set.

  CHECK gv_operation = 'SELECT'.

  TRY.

      po_result->next_package( ).

    CATCH cx_parameter_invalid_type INTO gr_parameter_invalid_type.
      gv_error_text = gr_parameter_invalid_type->get_text( ).
      MESSAGE e000 WITH gv_error_text.

    CATCH cx_parameter_invalid INTO gr_sql_parameter_invalid.
      gv_error_text = gr_sql_parameter_invalid->get_text( ).
      MESSAGE e001 WITH gv_error_text.

    CATCH cx_sql_exception INTO gr_sql_exception.
      gv_error_text = gr_sql_exception->get_text( ).
      MESSAGE e001 WITH gv_error_text.

    CATCH cx_salv_msg INTO gr_salv_exception.
      gv_error_text = gr_salv_exception->get_text( ).
      MESSAGE e001 WITH gv_error_text.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLOSE_QUERY
*&---------------------------------------------------------------------*
* Close the query, release resources
*----------------------------------------------------------------------*
FORM close_query USING po_result TYPE REF TO cl_sql_result_set.
  .

  po_result->close( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLOSE_DB_CONNECTION
*&---------------------------------------------------------------------*
* Close DB connection
*----------------------------------------------------------------------*
FORM close_db_connection USING po_sql_connection TYPE REF TO cl_sql_connection ..

  po_sql_connection->close( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_RESULT
*&---------------------------------------------------------------------*
* Display ALV
*----------------------------------------------------------------------*
FORM display_result.

  DATA : lr_salv_alv               TYPE REF TO cl_salv_table.

  DATA : lv_count(255).

  IF gv_operation = 'SELECT'.
** Display the data in an ALV
    cl_salv_table=>factory(
    IMPORTING
      r_salv_table = lr_salv_alv " Basic Class Simple ALV Tables
    CHANGING
      t_table = <fs_table> ).


* Show the output
    lr_salv_alv->display( ).

*    DATA(html) = cl_demo_output=>get( <fs_table> ).
**
*    DESCRIBE TABLE <fs_table>.
*
*    lv_count = sy-tfill.
*
*    cl_abap_browser=>show_html( EXPORTING html_string = html size = 'XXL' title = lv_count  ).

  ELSE.
    MESSAGE s001 WITH 'Commit complete.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_select_operation_struc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_select_operation_struc USING po_result TYPE REF TO cl_sql_result_set.

  CHECK gv_operation = 'SELECT'.

  CALL METHOD po_result->get_metadata
    RECEIVING
      md_tab = DATA(lt_md_tab).

  CHECK  lt_md_tab[] IS NOT INITIAL.


  DATA : lo_struct TYPE REF TO cl_abap_structdescr,
         lo_table  TYPE REF TO cl_abap_tabledescr.

  DATA : struc_components TYPE abap_component_tab,
         struc_component  TYPE abap_componentdescr.

  DATA : lo_ref_dynamic_structure TYPE REF TO data .

  DATA : lr_abapstru_tab TYPE REF TO cl_abap_structdescr.

  LOOP AT lt_md_tab ASSIGNING FIELD-SYMBOL(<fs_md_tab>).
    struc_component-name = <fs_md_tab>-column_name.
    struc_component-type = cl_abap_elemdescr=>get_c( p_length = <fs_md_tab>-length ) .
    APPEND struc_component TO struc_components .
  ENDLOOP.

  lo_struct = cl_abap_structdescr=>create( struc_components ).
  CREATE DATA lo_ref_dynamic_structure TYPE HANDLE lo_struct .

* Make struc symbol
  ASSIGN lo_ref_dynamic_structure->* TO <fs_struc> .

* make tab symbol
  DATA : lo_ref_dynamic_table TYPE REF TO data .
  lo_table  = cl_abap_tabledescr=>create( lo_struct ) .

  CREATE DATA lo_ref_dynamic_table TYPE HANDLE lo_table .
  ASSIGN lo_ref_dynamic_table->* TO <fs_table>.



ENDFORM.
