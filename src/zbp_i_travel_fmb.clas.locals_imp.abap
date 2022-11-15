CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS: acceptTravel FOR MODIFY IMPORTING keys
  FOR ACTION Travel~acceptTravel RESULT result,
  rejectTravel FOR MODIFY IMPORTING keys FOR
  ACTION Travel~rejectTravel RESULT result,
  createTravelByTemplate FOR MODIFY IMPORTING keys FOR
  ACTION Travel~createTravelByTemplate RESULT result.

    METHODS get_features FOR FEATURES IMPORTING keys REQUEST
    requested_features FOR Travel RESULT result.

    METHODS: validateCustomer FOR VALIDATE ON SAVE IMPORTING
                                                     keys FOR Travel~validateCustomer,
      validateDates FOR VALIDATE ON SAVE IMPORTING keys
                                                     FOR Travel~validateDates,
      validateStatus FOR VALIDATE ON SAVE IMPORTING keys
                                                      FOR Travel~validateStatus.

    METHODS get_authorizations FOR AUTHORIZATION IMPORTING
    keys REQUEST requested_authorizations FOR Travel RESULT
    result.
    METHODS completedescription FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~completedescription.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE travel.

  ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD validateCustomer.

    READ ENTITIES OF z_i_travel_fmb IN LOCAL MODE
    ENTITY Travel
    FIELDS ( customer_id )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH
    UNIQUE KEY customer_id.

    lt_customer = CORRESPONDING #( lt_travel DISCARDING
    DUPLICATES MAPPING customer_id = customer_id EXCEPT * ).

    DELETE lt_customer WHERE customer_id IS INITIAL.

    SELECT FROM /dmo/customer FIELDS customer_id
    FOR ALL ENTRIES IN @lt_customer
    WHERE customer_id EQ @lt_customer-customer_id
    INTO TABLE @DATA(lt_customer_db).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      IF <ls_travel>-customer_id IS INITIAL
      OR NOT line_exists( lt_customer_db[ customer_id =
      <ls_travel>-customer_id ] ).
        APPEND VALUE #( travel_id = <ls_travel>-travel_id )
        TO failed-travel.
        APPEND VALUE #( travel_id = <ls_travel>-travel_id
        %msg = new_message( id =  'Z_MC_TRAVEL_FMB'
                            number = '001'
                            v1 = <ls_travel>-travel_id
                            severity = if_abap_behv_message=>severity-error )
                            %element-customer_id = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateDates.

    READ ENTITY z_i_travel_fmb\\Travel
    FIELDS ( begin_date end_date )
    WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
    RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      IF ls_travel_result-end_date LT ls_travel_result-begin_date. "end_date before begin_date

        APPEND VALUE #( %key = ls_travel_result-%key
                        travel_id = ls_travel_result-travel_id ) TO failed-travel.

        APPEND VALUE #( %key = ls_travel_result-%key
        %msg = new_message( id =
        'Z_MC_TRAVEL_FMB'
        number =
        '005'
        v1 =
        ls_travel_result-begin_date
        v2 =
        ls_travel_result-end_date
        v3 =
        ls_travel_result-travel_id
        severity =
        if_abap_behv_message=>severity-error )
        %element-begin_date =
        if_abap_behv=>mk-on
        %element-end_date =
        if_abap_behv=>mk-on ) TO reported-travel.

      ELSEIF ls_travel_result-begin_date < cl_abap_context_info=>get_system_date( ). "begin_date must be in the future

        append value #( %key = ls_travel_result-%key
                        travel_id = ls_travel_result-travel_id ) to failed-travel.

        APPEND VALUE #( %key = ls_travel_result-%key
        %msg = new_message( id =
        'Z_MC_TRAVEL_FMB'
        number = '002'
        severity =
        if_abap_behv_message=>severity-error )
        %element-begin_date =
        if_abap_behv=>mk-on
        %element-end_date =
        if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITY z_i_travel_fmb\\Travel
    FIELDS ( overall_status )
    WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
    RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).
      CASE ls_travel_result-overall_status.
        WHEN 'O'. " Open
        WHEN 'X'. " Cancelled
        WHEN 'A'. " Accepted
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-travel.
          APPEND VALUE #( %key = ls_travel_result-%key
          %msg = new_message( id =
          'Z_MC_TRAVEL_fmb'
          number =
          '004'
          v1 =
          ls_travel_result-overall_status
          severity =
          if_abap_behv_message=>severity-error )
          %element-overall_status =
          if_abap_behv=>mk-on ) TO reported-travel.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_authorizations.

    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name( ) EQ 'CB9980001141' " 'CB0000000099'
                            THEN if_abap_behv=>auth-allowed
                            ELSE if_abap_behv=>auth-unauthorized ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).

      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).

      <ls_result> = VALUE #( %key = <ls_keys>-%key
                             %op-%update = lv_auth
                             %delete      = lv_auth
                             %action-acceptTravel = lv_auth
                             %action-rejectTravel = lv_auth
                             %action-createTravelByTemplate = lv_auth
                             %assoc-_Booking = lv_auth ).

    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.

* Modify in local mode - BO - related updates there are not relevant for autorization objects

    modify entities of z_i_travel_fmb in local mode
    entity Travel
    update fields ( overall_status )
    with value #( for key_row in keys ( travel_id = key_row-travel_id
                                        overall_status  = 'A' ) ) " Accepted
    failed failed
    reported reported.

    READ ENTITIES OF z_i_travel_fmb IN LOCAL MODE
    ENTITY Travel
    FIELDS ( agency_id
             customer_id
             begin_date
             end_date
            booking_fee
            total_price
            currency_code
            overall_status
            description
            created_by
            created_at
            last_changed_by
            last_changed_at )
    WITH VALUE #( FOR key_row IN keys ( travel_id = key_row-travel_id ) )
    RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel ( travel_id = ls_travel-travel_id
                                                   %param = ls_travel ) ).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      DATA(lv_travel_msg) = <ls_travel>-travel_id.
      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.
      APPEND VALUE #( travel_id = <ls_travel>-travel_id
      %msg = new_message( id =
      'Z_MC_TRAVEL_fmb'
      number =
      '006'
      v1 =
      lv_travel_msg
      severity =
      if_abap_behv_message=>severity-success )
      %element-customer_id =
      if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD rejectTravel.

* Modify in local mode - BO - related updates there are not relevant for autorization objects

    modify entities of z_i_travel_fmb in local mode
    entity Travel
    update fields ( overall_status )
    with value #( for key_row in keys ( travel_id =  key_row-travel_id
                                        overall_status = 'X' ) ) " Rejected
    failed failed
    reported reported.

    READ ENTITIES OF z_i_travel_fmb IN LOCAL MODE
    ENTITY Travel
    FIELDS ( agency_id
    customer_id
    begin_date
    end_date
    booking_fee
    total_price
    currency_code
    overall_status
    description
    created_by
    created_at
    last_changed_by
    last_changed_at )
    WITH VALUE #( FOR key_row1 IN keys ( travel_id = key_row1-travel_id ) )
    RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel ( travel_id = ls_travel-travel_id
                                                   %param = ls_travel ) ).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      DATA(lv_travel_msg) = <ls_travel>-travel_id.
      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.
      APPEND VALUE #( travel_id = <ls_travel>-travel_id
      %msg = new_message( id =
      'Z_MC_TRAVEL_fmb'
      number =
      '007'
      v1 =
      lv_travel_msg
      severity =
      if_abap_behv_message=>severity-success )
      %element-customer_id =
      if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD createTravelByTemplate.
* keys[ 1 ]-
* result[ 1 ]-
* mapped-
* failed-
* reported-

    READ ENTITIES OF z_i_travel_fmb
    ENTITY Travel
    FIELDS ( travel_id agency_id customer_id booking_fee
    total_price currency_code )
    WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
    RESULT DATA(lt_entity_travel)
    FAILED failed
    REPORTED reported.

* READ ENTITY z_i_travel_fmb
* FIELDS ( travel_id agency_id customer_id booking_fee
*    total_price currency_code )
* WITH VALUE #( FOR row_key IN keys ( %key = row_key-
*    %key ) )
* RESULT lt_entity_travel
* FAILED failed
* REPORTED reported.

data lv_copies type zde_copies.

do.

    data lt_create_travel type table for create z_i_travel_fmb\\Travel.

    SELECT MAX( travel_id ) FROM ztravel_fmb
    INTO @DATA(lv_travel_id).
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    lt_create_travel = VALUE #( FOR create_row IN lt_entity_travel INDEX INTO idx
    ( travel_id =
    lv_travel_id + idx + lv_copies
    agency_id =
    create_row-agency_id
    customer_id =
    create_row-customer_id
    begin_date = lv_today
    end_date = lv_today
    booking_fee = create_row-booking_fee
    total_price = create_row-total_price
    currency_code = create_row-currency_code
    description = 'Add comments'
    overall_status = 'O' ) ).

    MODIFY ENTITIES OF z_i_travel_fmb
    IN LOCAL MODE ENTITY travel
    CREATE FIELDS ( travel_id
    agency_id
    customer_id
    begin_date
    end_date
    booking_fee
    total_price
    currency_code
    description
    overall_status )
    WITH lt_create_travel
    MAPPED mapped
    FAILED failed
    REPORTED reported.

    result = VALUE #( FOR result_row IN lt_create_travel INDEX INTO idx
                    ( %cid_ref = keys[ idx ]-%cid_ref
                      %key = keys[ idx ]-%key
                      %param = CORRESPONDING #( result_row ) ) ).

add 1 to lv_copies.
read table keys assigning FIELD-SYMBOL(<keys>) index 1.
if sy-subrc = 0 and lv_copies >= <keys>-%param-copies.
exit.
endif.

enddo.

  ENDMETHOD.

  METHOD get_features.

    READ ENTITIES OF z_i_travel_fmb
    ENTITY Travel
    FIELDS ( travel_id overall_status )
    WITH VALUE #( FOR key_row IN keys ( %key = key_row-%key ) )
    RESULT DATA(lt_travel_result).

    result = VALUE #( FOR ls_travel IN lt_travel_result (
                            %key = ls_travel-%key
                            %field-travel_id = if_abap_behv=>fc-f-read_only
                            %field-overall_status = if_abap_behv=>fc-f-read_only
                            %assoc-_Booking = if_abap_behv=>fc-o-enabled
                            %action-acceptTravel = COND #( WHEN
                            ls_travel-overall_status = 'A'
                            THEN if_abap_behv=>fc-o-disabled
                            ELSE if_abap_behv=>fc-o-enabled )
                            %action-rejectTravel = COND #( WHEN
                            ls_travel-overall_status = 'X'
                            THEN if_abap_behv=>fc-o-disabled
                            ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.

  METHOD completeDescription.

  READ ENTITIES OF z_i_travel_fmb
    ENTITY Travel
    FIELDS ( description )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_entity_travel).

   LOOP AT lt_entity_travel ASSIGNING FIELD-SYMBOL(<fs_entity_travel>).
    IF <fs_entity_travel>-agency_id = '070003'.
     <fs_entity_travel>-description = 'New Vacation'.
    MODIFY ENTITIES OF z_i_travel_fmb IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( description )
    WITH VALUE #( ( %key = <fs_entity_travel>-%key
                    %tky = <fs_entity_travel>-%tky
                    %pky = <fs_entity_travel>-%pky
                    travel_id = <fs_entity_travel>-travel_id
                    description = <fs_entity_travel>-description
                    %control-description = if_abap_behv=>mk-on ) ) reported data(reportedmodify).
    ENDIF.
   ENDLOOP.

*append initial line to  reported-travel ASSIGNING FIELD-SYMBOL(<fs_reported_travel>).
*<fs_reported_travel>-travel_id = <fs_entity_travel>-travel_id.
*<fs_reported_travel>-%update = if_abap_behv=>mk-on.
*<fs_reported_travel>-%tky = <fs_entity_travel>-%tky.
*<fs_reported_travel>-%pky = <fs_entity_travel>-%pky.
.
*   MODIFY entities of z_i_travel_fmb in local mode
*    ENTITY Travel
*    UPDATE FROM VALUE #( FOR ls_entity_travel IN lt_entity_travel
*                                  ( %key = ls_entity_travel-%key
*                                    %tky = ls_entity_travel-%tky
*                                    %pky = ls_entity_travel-%pky
*                                    %data = ls_entity_travel-%data
*                                    travel_id = ls_entity_travel-travel_id
*                                   "%is_draft = ls_entity_travel- -%is_draft
*                                    description = 'New Vacation' "ls_entity_travel-description
*                                    %control-description = cl_abap_behv=>flag_changed  ) ) reported data(reportedmodify). " if_abap_behv=>mk-on

  ENDMETHOD.

  METHOD precheck_update.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entity>).

  " 01 = Value is updated / changed, 00 = Value is not changed

  CHECK <lfs_entity>-%control-agency_id = '01' OR <lfs_entity>-%control-description = '01'.

  READ ENTITIES OF z_i_travel_fmb IN LOCAL MODE
    ENTITY Travel
    FIELDS ( agency_id description )
    WITH VALUE #( ( %key = <lfs_entity>-%key ) )
    RESULT DATA(lt_travel).

    IF sy-subrc = 0.

    READ TABLE lt_travel ASSIGNING FIELD-SYMBOL(<lfs_db_travel>) INDEX 1.
    IF sy-subrc = 0.
     <lfs_db_travel>-agency_id = COND #( WHEN <lfs_entity>-%control-agency_id = '01' THEN
                                              <lfs_entity>-agency_id ELSE <lfs_db_travel>-agency_id ).
     <lfs_db_travel>-description = COND #( WHEN <lfs_entity>-%control-description = '01' THEN
                                              <lfs_entity>-description ELSE <lfs_db_travel>-agency_id ).

     if <lfs_db_travel>-agency_id =  '070003'.

     IF <lfs_db_travel>-description <> 'New Vacation'.

     append value #(  %tky = <lfs_entity>-%tky )  to failed-travel.

     append value #(   %tky = <lfs_entity>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = 'Invalid description')
                          ) to reported-travel.

     ENDIF.

    ENDIF.


    ENDIF.

    ENDIF.


  ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_FMB DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.
CONSTANTS: create TYPE string VALUE 'CREATE',
update TYPE string VALUE 'UPDATE',
delete TYPE string VALUE 'DELETE'.

PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_FMB IMPLEMENTATION.

  METHOD save_modified.

  DATA: lt_travel_fmb TYPE STANDARD TABLE OF zlog_fmb,
lt_travel_fmb_u TYPE STANDARD TABLE OF zlog_fmb.
DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

IF NOT create-travel IS INITIAL.
lt_travel_fmb = CORRESPONDING #( create-travel ).

LOOP AT lt_travel_fmb ASSIGNING FIELD-SYMBOL(<ls_travel_fmb>).

GET TIME STAMP FIELD <ls_travel_fmb>-created_at.
<ls_travel_fmb>-changing_operation = lsc_z_i_travel_fmb=>create.

READ TABLE create-travel WITH TABLE KEY entity
COMPONENTS travel_id = <ls_travel_fmb>-travel_id
INTO DATA(ls_travel).

IF sy-subrc EQ 0.

IF ls_travel-%control-booking_fee EQ cl_abap_behv=>flag_changed.

<ls_travel_fmb>-changed_field_name = 'booking_fee'.

<ls_travel_fmb>-changed_value = ls_travel-booking_fee.

<ls_travel_fmb>-user_mod = lv_user.

TRY.
<ls_travel_fmb>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
CATCH cx_uuid_error.
ENDTRY.
APPEND <ls_travel_fmb> TO lt_travel_fmb_u.
ENDIF.
ENDIF.
ENDLOOP.

" Lanzar evento
 raise entity event z_i_travel_fmb~createTravelByTemplate2
        from value #(
          for travel in create-travel (
              copies = '1'
            )
          ).

ENDIF.

IF NOT update-travel IS INITIAL.

lt_travel_fmb = CORRESPONDING #( update-travel ).

LOOP AT update-travel INTO DATA(ls_update_travel).

ASSIGN lt_travel_fmb[ travel_id = ls_update_travel-travel_id ] TO FIELD-SYMBOL(<ls_travel_fmb_bd>).

GET TIME STAMP FIELD <ls_travel_fmb_bd>-created_at.
<ls_travel_fmb_bd>-changing_operation = lsc_z_i_travel_fmb=>update.

IF ls_update_travel-%control-customer_id EQ cl_abap_behv=>flag_changed.
<ls_travel_fmb_bd>-changed_field_name = 'customer_id'.
<ls_travel_fmb_bd>-changed_value = ls_update_travel-customer_id.
<ls_travel_fmb_bd>-user_mod = lv_user.
TRY.
<ls_travel_fmb_bd>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
CATCH cx_uuid_error.
ENDTRY.
APPEND <ls_travel_fmb_bd> TO lt_travel_fmb_u.
ENDIF.

ENDLOOP.

ENDIF.

IF NOT delete-travel IS INITIAL.

lt_travel_fmb = CORRESPONDING #( delete-travel ).

LOOP AT lt_travel_fmb ASSIGNING FIELD-SYMBOL(<ls_travel_fmb_del>).

GET TIME STAMP FIELD <ls_travel_fmb_del>-created_at.
<ls_travel_fmb_del>-changing_operation = lsc_z_i_travel_fmb=>delete.
<ls_travel_fmb_del>-user_mod = lv_user.

TRY.
<ls_travel_fmb_del>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
CATCH cx_uuid_error.
ENDTRY.
APPEND <ls_travel_fmb_del> TO lt_travel_fmb_u.
ENDLOOP.
ENDIF.

IF NOT lt_travel_fmb_u IS INITIAL.
INSERT zlog_fmb FROM TABLE @lt_travel_fmb_u.
ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
