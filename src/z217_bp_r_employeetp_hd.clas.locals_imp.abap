CLASS lhc_hierarchy_operation DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:
      copy_keys       TYPE TABLE FOR ACTION IMPORT Z217_R_EMPLOYEETP_HD~copy,
      mapped          TYPE TABLE FOR MAPPED Z217_R_EMPLOYEETP_HD,
      failed          TYPE TABLE FOR FAILED Z217_R_EMPLOYEETP_HD,
      reported        TYPE TABLE FOR REPORTED EARLY Z217_R_EMPLOYEETP_HD,
      failed_agencies TYPE TABLE FOR FAILED Z217_R_AGENCYTP_HD.

    TYPES BEGIN OF parent_copy_map.
    TYPES:
      agency        TYPE Z217_R_AGENCYTP_HD-agency,
      employee      TYPE Z217_R_EMPLOYEETP_HD-employee,
      is_draft      TYPE abp_behv_flag,
      copy_employee TYPE Z217_R_EMPLOYEETP_HD-employee.
    TYPES END OF parent_copy_map.

    TYPES parents_copy_map TYPE SORTED TABLE OF parent_copy_map WITH UNIQUE KEY agency employee is_draft.

    METHODS copy FOR MODIFY IMPORTING keys FOR ACTION employee~copy.

    "Declare the _copy_recursion method to handle recursive operations.
    "Import essential parameters for processing  copy actions.
    "Export relevant fields to categorize employees according to the operation’s status.
    METHODS _copy_recursion IMPORTING keys                   TYPE copy_keys
                                      parents_copy_map_param TYPE parents_copy_map OPTIONAL
                            EXPORTING mapped_employees       TYPE mapped
                                      failed_employees       TYPE failed
                                      reported_employees     TYPE reported.
ENDCLASS.

CLASS lhc_hierarchy_operation IMPLEMENTATION.
  METHOD copy.


   "Invoke the _copy_recursion method.
    _copy_recursion( EXPORTING keys = keys
                     IMPORTING mapped_employees   = mapped-employee
                               failed_employees   = failed-employee
                               reported_employees = reported-employee ).

  ENDMETHOD.

  METHOD _copy_recursion.

  CONSTANTS: my_cid_kid TYPE abp_behv_cid VALUE 'My%CID_KID' ##NO_TEXT.

    DATA:
      employees_cba    TYPE TABLE FOR CREATE Z217_R_AGENCYTP_HD\_employee,
      employees_rba    TYPE TABLE FOR READ IMPORT Z217_R_EMPLOYEETP_HD\_employee,
      employee_rba     LIKE LINE OF employees_rba,
      parents_copy_map TYPE parents_copy_map.

    FIELD-SYMBOLS <control> TYPE x.

    CLEAR: mapped_employees, failed_employees.

    "Read to get the information of employee instance to be copied.
    READ ENTITY IN LOCAL MODE Z217_R_EMPLOYEETP_HD
      ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(result_sources)
    REPORTED DATA(reported_source)
    FAILED DATA(failed_source).



    "Iterate over the keys of the instance to be copied and make sure to handle the case of invalid keys.
    LOOP AT  keys INTO DATA(key).
       READ TABLE keys ASSIGNING FIELD-SYMBOL(<dupl_key>) WITH KEY id COMPONENTS %tky = key-%tky .

        IF <dupl_key>-%cid <> key-%cid.
          failed_source-employee =  VALUE #( (  %fail    =  VALUE #( cause = if_abap_behv=>cause-unspecific )
                                                %cid     = key-%cid
                                                Agency   = key-Agency
                                                Employee = key-Employee ) ).

          INSERT LINES OF  failed_source-employee INTO TABLE failed_employees.
          CLEAR failed_source.

          APPEND VALUE #(  %cid = key-%cid
                           %tky = key-%tky
                           %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error ) ) TO reported_source-employee.

          INSERT LINES OF  reported_source-employee INTO TABLE reported_employees.
          CLEAR reported_source.

      ELSE.

        READ TABLE result_sources ASSIGNING FIELD-SYMBOL(<source>) WITH KEY id COMPONENTS %tky = key-%tky .

        IF sy-subrc <> 0.
          failed_source-employee =  VALUE #( (  %fail    =  VALUE #( cause = if_abap_behv=>cause-unspecific )
                                                %cid     = key-%cid
                                                Agency   = key-Agency
                                                Employee = key-Employee )  ).

          INSERT LINES OF  failed_source-employee INTO TABLE failed_employees.
          CLEAR failed_source.

          APPEND VALUE #( %cid     = key-%cid
                          %tky     = key-%tky
                          %msg     = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error ) ) TO reported_source-employee.

          INSERT LINES OF reported_source-employee INTO TABLE reported_employees.
          CLEAR reported_source.

        ENDIF.

      ENDIF.

    ENDLOOP.

    "Perform a read-by-association operation to gather data about employees and their links to agencies.
    "Make sure to handle the filling of failed parameter accordingly.
    READ ENTITY IN LOCAL MODE Z217_R_EMPLOYEETP_HD
      BY \_agency
      FIELDS ( agency ) WITH CORRESPONDING #( result_sources )
    LINK DATA(directory_links)
    RESULT DATA(result_rba)
    REPORTED DATA(reported_rba)
    FAILED failed_source.

    INSERT LINES OF  failed_source-employee INTO TABLE failed_employees.

    "Loop into the directory links and specify the fields you want to copy.
    LOOP AT directory_links ASSIGNING FIELD-SYMBOL(<directory_link>).

      ASSIGN employees_cba[ KEY id %tky = <directory_link>-target-%tky  ] TO FIELD-SYMBOL(<cba>).

      IF sy-subrc <> 0.
        INSERT VALUE #( %tky = <directory_link>-target-%tky ) INTO TABLE employees_cba ASSIGNING <cba>.
      ENDIF.

      ASSIGN result_sources[ KEY id %tky = <directory_link>-source-%tky ] TO FIELD-SYMBOL(<source_directory>).
      ASSERT sy-subrc = 0.

      INSERT VALUE #( %data = CORRESPONDING #( <source_directory> )  ) INTO TABLE <cba>-%target ASSIGNING FIELD-SYMBOL(<cba_target>).

      IF parents_copy_map_param IS SUPPLIED.
        ASSIGN parents_copy_map_param[   agency   = <source_directory>-agency
                                         employee = <source_directory>-manager
                                         is_draft = <source_directory>-%is_draft ] TO FIELD-SYMBOL(<parent_copy_map>).
        ASSERT sy-subrc = 0.
        <cba_target>-manager = <parent_copy_map>-copy_employee.

      ELSE.
        CLEAR <cba_target>-manager.
      ENDIF.

      employee_rba-%tky = <source_directory>-%tky.
      <cba_target>-%cid = keys[ KEY id %tky = <source_directory>-%tky ]-%cid.
      <cba_target>-%is_draft = <source_directory>-%is_draft.

      " business logic: fields to be copied
      <cba_target>-firstname          = <source_directory>-firstname.
      <cba_target>-lastname           = <source_directory>-lastname.
      <cba_target>-salary             = <source_directory>-salary.
      <cba_target>-salarycurrency     = <source_directory>-salarycurrency.
      <cba_target>-siblingordernumber = <source_directory>-siblingordernumber.
      "  business logic end

      ASSIGN <cba_target>-%control TO <control> CASTING.
      CLEAR <control> WITH if_abap_behv=>mk-on IN BYTE MODE. "as long as there is no selective information, all elements are marked
      CLEAR: <cba_target>-%control-agency, <cba_target>-%control-employee.
      INSERT employee_rba INTO TABLE employees_rba.


    ENDLOOP.

    READ ENTITY IN LOCAL MODE Z217_R_EMPLOYEETP_HD
      BY \_employee FROM employees_rba
    LINK DATA(children_links)
    RESULT DATA(result_rba_children)
    FAILED DATA(failed_rba_children)
    REPORTED DATA(reported_rba_children).


    "If an employee has child nodes, make sure to copy them as well.
    MODIFY ENTITY IN LOCAL MODE Z217_R_AGENCYTP_HD
      CREATE BY \_employee FROM employees_cba
    MAPPED DATA(mapped_create)
    FAILED DATA(failed_create)
    REPORTED DATA(reported_create).


    "Make sure to remove any children links in case failed is filled.
    "Then, fill the parents_copy_map with values provided from the read by association.
    LOOP AT failed_create-employee ASSIGNING FIELD-SYMBOL(<failed>).
      DELETE children_links USING KEY draft WHERE source-%tky = <failed>-%tky.
    ENDLOOP.


    IF NOT parents_copy_map_param IS SUPPLIED.
      mapped_employees = mapped_create-employee.
    ENDIF.

    IF result_rba_children IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT employees_rba ASSIGNING FIELD-SYMBOL(<rba>).
      ASSIGN mapped_create-employee[ KEY cid COMPONENTS %cid = keys[ KEY id %tky = <rba>-%tky ]-%cid ] TO FIELD-SYMBOL(<mapped>).

      CHECK sy-subrc = 0.
      ASSERT <mapped>-agency    = <rba>-agency AND <mapped>-%is_draft = <rba>-%is_draft.

      INSERT VALUE #( agency      = <rba>-agency
                      employee    = <rba>-employee
                      is_draft    = <rba>-%is_draft
                      copy_employee = <mapped>-employee ) INTO TABLE parents_copy_map.
    ENDLOOP.


    "Iterate this also for every child. Use recursive calls to copy child entities within hierarchy
    "using result_rba_children and insert them into parents_copy_map.
    _copy_recursion( keys = VALUE #( FOR <child> IN result_rba_children INDEX INTO lv_index
                                   ( %cid = my_cid_kid && lv_index  %tky = <child>-%tky ) )
                     parents_copy_map_param = parents_copy_map ).

  ENDMETHOD.
ENDCLASS.
