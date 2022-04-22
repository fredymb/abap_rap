CLASS lhc_Employee DEFINITION INHERITING FROM
cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_features FOR FEATURES
    IMPORTING keys REQUEST requested_features FOR
    Employee RESULT result.
    METHODS completeemp FOR MODIFY
      IMPORTING keys FOR ACTION employee~completeemp RESULT result.
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

ENDCLASS.
