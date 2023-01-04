CLASS lsc_z_i_employee_fmb DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_z_i_employee_fmb IMPLEMENTATION.

  METHOD save_modified.

data: lt_employees type table for change z_i_employee_fmb\\employee.

      lt_employees = create-employee.

 raise entity event z_i_employee_fmb~eventemp
 from value  #( FOR lw_employees IN lt_employees INDEX INTO idx (
                      %key = lw_employees-%key
                      e_number = lw_employees-e_number ) ) .

  ENDMETHOD.

ENDCLASS.

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

  TRY.
"create http destination by url; API endpoint for API sandbox
DATA(lo_http_destination) =
cl_http_destination_provider=>create_by_url( 'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata4/sap/api_bank/srvd_a2x/sap/bank/0002/Bank(BankCountry=''AT'',BankInternalID=''20321'')' ).
*     cl_http_destination_provider=>create_by_url( 'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BANKDETAIL_SRV/A_BankDetail(BankCountry=''AT'',BankInternalID=''20321'')' ).
*     cl_http_destination_provider=>create_by_url( 'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BANKDETAIL_SRV/A_BankDetail?$inlinecount=allpages&$top=50' ).
  "alternatively create HTTP destination via destination service
    "cl_http_destination_provider=>create_by_cloud_destination( i_name = '<...>' AT 20321
     "                            i_service_instance_name = '<...>' )
    "SAP Help: https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/f871712b816943b0ab5e04b60799e518.html

"create HTTP client by destination
DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

"adding headers with API Key for API Sandbox
DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
lo_web_http_request->set_header_fields( VALUE #(
(  name = 'APIKey' value = 'd6Z3NAgSvGrNSRvbcouTTosYxhKWlwpj' )
(  name = 'DataServiceVersion' value = '2.0' )
(  name = 'Accept' value = 'application/json' )
 ) ).

"set request method and execute request
DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>GET ).
DATA(lv_response) = lo_web_http_response->get_text( ).

CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
    "error handling
ENDTRY.

"uncomment the following line for console output; prerequisite: code snippet is implementation of if_oo_adt_classrun~main
"out->write( |response:  { lv_response }| ).

data: lr_data          TYPE REF TO data,
      lv_bankname      TYPE string.

      FIELD-SYMBOLS: <fs_data>        TYPE data,
                     <fs_table>       TYPE STANDARD TABLE,
                     <fs_d>           TYPE any,
                     <fs_d2>          TYPE any,
                     <fs_field>       TYPE any.

                     TYPES:
  BEGIN OF ts_input,
    bankname      TYPE string,
  END OF ts_input.
  data: lt_input type STANDARD TABLE OF ts_input.

DATA ls_input TYPE ts_input.

*xco_ku_json=>data->from_string( lv_response )->apply( VALUE #(
*  ( xco_ku_json=>transformation->pascal_case_to_underscore )
*  ( xco_ku_json=>transformation->boolean_to_abap_bool )
*) )->write_to( REF #( ls_input ) ).

   CALL METHOD /ui2/cl_json=>deserialize
    EXPORTING
      json         = lv_response
      pretty_name  = /ui2/cl_json=>pretty_mode-user
      assoc_arrays = abap_true
    CHANGING
      data         = ls_input.

    IF ls_input IS NOT INITIAL.
    lv_bankname = ls_input-bankname.
    ENDIF.

*    ASSIGN ('<FS_DATA>-BANKNAME') TO <fs_field>.
*    IF sy-subrc = 0.
*    lv_bankname = <fs_field>.
*    ENDIF.

*  ASSIGN COMPONENT 'BANKNAME' OF STRUCTURE <fs_data> to <fs_field>.
*  IF sy-subrc = 0.
*   lv_bankname = <fs_field>.
*  ENDIF.


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
IF lv_bankname IS NOT INITIAL.
  APPEND VALUE #( %key = keys[ 1 ]-%key
        %msg = NEW_MESSAGE_WITH_TEXT(
        severity = if_abap_behv_message=>severity-information
        text = |'Bank Name: { lv_bankname }'| )
        ) TO reported-employee.
 ENDIF.

*
*   result = VALUE #( FOR result_row IN lt_employees INDEX INTO idx
*                    ( %cid_ref = keys[ idx ]-%cid_ref
*                      %key = keys[ idx ]-%key
*                      %param = CORRESPONDING #( result_row ) ) ).

  ENDMETHOD.

ENDCLASS.
