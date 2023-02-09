*&---------------------------------------------------------------------*
*&  Include           MYSAMP001_CLS02
*&---------------------------------------------------------------------*

CLASS lcl_tree_event_receiver  DEFINITION DEFERRED.

DATA: g_tree_event_receiver TYPE REF TO lcl_tree_event_receiver.

*----------------------------------------------------------------------*
*       CLASS lcl_tree_event_receiver DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_tree_event_receiver DEFINITION.

  PUBLIC SECTION.

    METHODS handle_node_ctmenu_request
                FOR EVENT node_context_menu_request OF cl_gui_alv_tree
      IMPORTING node_key
                menu.
    METHODS handle_node_ctmenu_selected
                FOR EVENT node_context_menu_selected OF cl_gui_alv_tree
      IMPORTING node_key
                fcode.
    METHODS handle_item_ctmenu_request
                FOR EVENT item_context_menu_request OF cl_gui_alv_tree
      IMPORTING node_key
                fieldname
                menu.
    METHODS handle_item_ctmenu_selected
                FOR EVENT item_context_menu_selected OF cl_gui_alv_tree
      IMPORTING node_key
                fieldname
                fcode.

    METHODS handle_item_double_click
                FOR EVENT item_double_click OF cl_gui_alv_tree
      IMPORTING node_key
                fieldname.

    METHODS handle_button_click
                FOR EVENT button_click OF cl_gui_alv_tree
      IMPORTING node_key
                fieldname.

    METHODS handle_link_click
                FOR EVENT link_click OF cl_gui_alv_tree
      IMPORTING node_key
                fieldname.

    METHODS handle_header_click
                FOR EVENT header_click OF cl_gui_alv_tree
      IMPORTING fieldname.

ENDCLASS.

*----------------------------------------------------------------------*
*       CLASS lcl_tree_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_tree_event_receiver IMPLEMENTATION.

  METHOD handle_node_ctmenu_request.
*   append own functions
    CALL METHOD menu->add_function
      EXPORTING
        fcode = 'USER1'
        text  = 'Usercmd 1'.          "#EC NOTEXT
    CALL METHOD menu->add_function
      EXPORTING
        fcode = 'USER2'
        text  = 'Usercmd 2'.          "#EC NOTEXT
    CALL METHOD menu->add_function
      EXPORTING
        fcode = 'USER3'
        text  = 'Usercmd 3'.          "#EC NOTEXT
  ENDMETHOD.

  METHOD handle_node_ctmenu_selected.
    CASE fcode.
      WHEN 'USER1' OR 'USER2' OR 'USER3'.
        MESSAGE i000(0h) WITH 'Node-Context-Menu on Node ' node_key
                              'fcode : ' fcode.             "#EC NOTEXT
    ENDCASE.
  ENDMETHOD.

  METHOD handle_item_ctmenu_request .
*   append own functions
    CALL METHOD menu->add_function
      EXPORTING
        fcode = 'USER1'        "#EC NOTEXT
        text  = 'Usercmd 1'.   "#EC NOTEXT
    CALL METHOD menu->add_function
      EXPORTING
        fcode = 'USER2'        "#EC NOTEXT
        text  = 'Usercmd 2'.   "#EC NOTEXT
    CALL METHOD menu->add_function
      EXPORTING
        fcode = 'USER3'       "#EC NOTEXT
        text  = 'Usercmd 3'.  "#EC NOTEXT
  ENDMETHOD.

  METHOD handle_item_ctmenu_selected.
    CASE fcode.
      WHEN 'USER1' OR 'USER2' OR 'USER3'.
        MESSAGE i000(0h) WITH 'Item-Context-Menu on Node ' node_key
                              'Fieldname : ' fieldname.     "#EC NOTEXT
    ENDCASE.
  ENDMETHOD.

  METHOD handle_item_double_click.
    MESSAGE i000(0h) WITH 'handle_item_double_click' node_key.
  ENDMETHOD.

  METHOD handle_button_click.
    MESSAGE i000(0h) WITH 'handle_button_click' node_key .
  ENDMETHOD.

  METHOD handle_link_click.
    MESSAGE i000(0h) WITH 'handle_link_click' node_key.
  ENDMETHOD.

  METHOD handle_header_click.
    MESSAGE i000(0h) WITH 'handle_header_click' .
  ENDMETHOD.

ENDCLASS.



CLASS lcl_toolbar_event_receiver  DEFINITION DEFERRED.

DATA: g_toolbar_event_receiver TYPE REF TO lcl_toolbar_event_receiver.

*----------------------------------------------------------------------*
*       CLASS lcl_toolbar_event_receiver DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_toolbar_event_receiver DEFINITION.

  PUBLIC SECTION.
    METHODS: on_function_selected
                FOR EVENT function_selected OF cl_gui_toolbar
      IMPORTING sender
                fcode,

      on_toolbar_dropdown
                  FOR EVENT dropdown_clicked OF cl_gui_toolbar
        IMPORTING sender
                  fcode
                  posx
                  posy.

ENDCLASS.


*---------------------------------------------------------------------*
*       CLASS lcl_toolbar_event_receiver IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_toolbar_event_receiver IMPLEMENTATION.

  METHOD on_function_selected.
    DATA: ls_sflight TYPE sflight.
    CASE fcode.
      WHEN 'DELETE'.
*       get selected node
*        DATA: lt_selected_node TYPE lvc_t_nkey.
*        CALL METHOD sender->get_selected_nodes
*          CHANGING
*            ct_selected_nodes = lt_selected_node.
*        CALL METHOD cl_gui_cfw=>flush.
*        DATA l_selected_node TYPE lvc_nkey.
*        READ TABLE lt_selected_node INTO l_selected_node INDEX 1.
*
**       delete subtree
*        IF NOT l_selected_node IS INITIAL.
*          CALL METHOD sender->delete_subtree
*            EXPORTING
*              i_node_key                = l_selected_node
*              i_update_parents_expander = ''
*              i_update_parents_folder   = 'X'.
*        ELSE.
*          MESSAGE i227(0h).
*        ENDIF.
      WHEN 'INSERT_LC'.
**       get selected node
*        CALL METHOD sender->get_selected_nodes
*          CHANGING
*            ct_selected_nodes = lt_selected_node.
*        CALL METHOD cl_gui_cfw=>flush.
*        READ TABLE lt_selected_node INTO l_selected_node INDEX 1.

      WHEN 'INSERT_FC'.
**       get selected node
*        CALL METHOD sender->get_selected_nodes
*          CHANGING
*            ct_selected_nodes = lt_selected_node.
*        CALL METHOD cl_gui_cfw=>flush.
*        READ TABLE lt_selected_node INTO l_selected_node INDEX 1.
**       get current Line

      WHEN 'INSERT_FS'.
*       get selected node

      WHEN 'INSERT_LS'.

      WHEN 'INSERT_NS'.
**       get selected node
*        CALL METHOD sender->get_selected_nodes
*          CHANGING
*            ct_selected_nodes = lt_selected_node.


    ENDCASE.

*   update frontend
*    CALL METHOD <fs_g_tree>->frontend_update.
  ENDMETHOD.

  METHOD on_toolbar_dropdown.
* create contextmenu
    DATA: l_menu       TYPE REF TO cl_ctmenu,
          l_fc_handled TYPE as4flag.

    CREATE OBJECT l_menu.
    CLEAR l_fc_handled.

    CASE fcode.
      WHEN 'INSERT_LC'.
        l_fc_handled = 'X'.
*       insert as last child
        CALL METHOD l_menu->add_function
          EXPORTING
            fcode = 'INSERT_LC'
            text  = 'Insert New Line as Last Child'.  "#EC NOTEXT
*       insert as first child
        CALL METHOD l_menu->add_function
          EXPORTING
            fcode = 'INSERT_FC'
            text  = 'Insert New Line as First Child'. "#EC NOTEXT
*       insert as next sibling
        CALL METHOD l_menu->add_function
          EXPORTING
            fcode = 'INSERT_NS'
            text  = 'Insert New Line as Next Sibling'. "#EC NOTEXT
*       insert as last sibling
        CALL METHOD l_menu->add_function
          EXPORTING
            fcode = 'INSERT_LS'
            text  = 'Insert New Line as Last Sibling'. "#EC NOTEXT
*       insert as first sibling
        CALL METHOD l_menu->add_function
          EXPORTING
            fcode = 'INSERT_FS'
            text  = 'Insert New Line as First Sibling'. "#EC NOTEXT
    ENDCASE.

* show dropdownbox
    IF l_fc_handled = 'X'.
      CALL METHOD g_toolbar->track_context_menu
        EXPORTING
          context_menu = l_menu
          posx         = posx
          posy         = posy.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
