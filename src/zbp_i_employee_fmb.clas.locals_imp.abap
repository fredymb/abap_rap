CLASS lhc_Employee DEFINITION INHERITING FROM
cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_features FOR FEATURES
    IMPORTING keys REQUEST requested_features FOR
    Employee RESULT result.
    METHODS completeemp FOR MODIFY
      IMPORTING keys FOR ACTION employee~completeemp RESULT result.
    METHODS checkemployee FOR MODIFY
      IMPORTING keys FOR ACTION employee~checkemployee RESULT result.
ENDCLASS.

CLASS lhc_Employee IMPLEMENTATION.
  METHOD get_features.
  ENDMETHOD.

  METHOD CompleteEMP.

  " Modify the entities with required fields
  MODIFY ENTITIES OF z_i_employee_fmb IN LOCAL MODE
  ENTITY Employee
  UPDATE FIELDS ( Status )
    WITH VALUE #(  FOR key IN keys ( %tky = key-%tky
                                      status = 'C' ) ).

 " Check if there are any draft instances?
 DATA(lt_draft_docs) = keys.
 DELETE lt_draft_docs WHERE %is_draft = if_abap_behv=>mk-off.

  IF lt_draft_docs IS NOT INITIAL.

  " EXECUTE Active only in draft instances

  MODIFY ENTITIES OF z_i_employee_fmb IN LOCAL MODE
  ENTITY Employee
  EXECUTE Activate FROM
  VALUE #( FOR key IN keys ( %key = key-%key )  )
  reported data(activate_reported)
  failed data(activate_failed)
  mapped data(activate_mapped).

  " Change keys to read active instances
  DATA(lt_keys) = keys.
  LOOP AT lt_keys ASSIGNING FIELD-SYMBOL(<fs_key>).
  <fs_key>-%is_draft = if_abap_behv=>mk-off.
  ENDLOOP.

  " Read the active instance to send back to Fiori App
  READ ENTITIES OF z_i_employee_fmb IN LOCAL MODE
  ENTITY Employee
  ALL FIELDS WITH CORRESPONDING #( lt_keys )
  RESULT DATA(lt_employees).

  " Populate %key, %tky to be filled from source instance while %param-%key to be filled from new instance
  result = VALUE #( FOR <fs_old_key> IN keys
                    FOR <fs_new_key> IN lt_keys WHERE ( %key = <fs_old_key>-%key )"ObjectId = <fs_old_key>-ObjectId )
                                                      ( %key = <fs_old_key>-%key
                                                        %tky = <fs_old_key>-%tky
                                                        %param-%key = <fs_new_key>-%key ) ).
  mapped-Employee = CORRESPONDING #( lt_employees ).


  ENDIF.


  ENDMETHOD.

  METHOD CheckEmployee.


 " Create a draft instance for all active instance
 MODIFY ENTITIES OF z_i_employee_fmb IN LOCAL MODE
  ENTITY Employee
  EXECUTE edit FROM
  VALUE #( FOR <fs_active_key> IN keys WHERE ( %is_draft = if_abap_behv=>mk-off )
                                            ( %key = <fs_active_key>-%key
                                              %param-preserve_changes = 'X'
                                            ) )
  reported data(activate_reported)
  failed data(activate_failed)
  mapped data(activate_mapped).

  DATA(lt_temp_keys) = keys.
    LOOP AT lt_temp_keys ASSIGNING FIELD-SYMBOL(<fs_temp_keys>).
        <fs_temp_keys>-%is_draft = if_abap_behv=>mk-on.
    ENDLOOP.

    " Modify the entities with required fields
  MODIFY ENTITIES OF z_i_employee_fmb IN LOCAL MODE
  ENTITY Employee
  UPDATE FIELDS ( Status )
    WITH VALUE #(  FOR key IN lt_temp_keys ( %tky = key-%tky
                                      status = 'V' ) ).

  " Read the draft instance to send back to Fiori App
  READ ENTITIES OF z_i_employee_fmb IN LOCAL MODE
  ENTITY Employee
  ALL FIELDS WITH CORRESPONDING #( lt_temp_keys )
  RESULT DATA(lt_employees).

*result = CORRESPONDING #( lt_employees ).

result = VALUE #( FOR lw_employees IN lt_employees INDEX INTO idx
                    ( %cid_ref = keys[ idx ]-%cid_ref
                      %is_draft = lw_employees-%is_draft
                      %key = lw_employees-%key
                      e_number = lw_employees-e_number
                      %param = CORRESPONDING #( lw_employees ) ) ).

*   READ ENTITIES OF z_i_employee_fmb
*    ENTITY Employee
*    all fields
*    WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
*    RESULT DATA(lt_employees)
*    FAILED failed
*    REPORTED reported.
*
*  APPEND VALUE #( %key = keys[ 1 ]-%key
*        %msg = NEW_MESSAGE_WITH_TEXT(
*        severity = if_abap_behv_message=>severity-information
*        text = 'Employee Verified' )
*        ) TO reported-employee.
*
*   result = VALUE #( FOR result_row IN lt_employees INDEX INTO idx
*                    ( %cid_ref = keys[ idx ]-%cid_ref
*                      %key = keys[ idx ]-%key
*                      %param = CORRESPONDING #( result_row ) ) ).

  ENDMETHOD.

ENDCLASS.
