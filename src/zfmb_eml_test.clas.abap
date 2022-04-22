CLASS zfmb_eml_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zfmb_eml_test IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " Read entity
    READ ENTITIES OF z_i_travel_fmb
        ENTITY Travel
        ALL FIELDS
        WITH VALUE #( ( %key = '00000003' ) )
        RESULT DATA(travels)
        FAILED DATA(failed)
        REPORTED DATA(reported).
    out->write( travels ).
    out->write( failed ).
    out->write( reported ).

    " Modify entity
    MODIFY ENTITIES OF z_i_travel_fmb
      ENTITY travel
       UPDATE
       SET FIELDS WITH VALUE
       #( (  Travel_id = '00000003'
             Description = 'Vacation' ) )
       FAILED failed
       REPORTED reported.

    out->write( 'Update done' ).

    COMMIT ENTITIES
    RESPONSE OF z_i_travel_fmb
    FAILED     DATA(failed_commit)
    REPORTED   DATA(reported_commit).

    " Create entity
    MODIFY ENTITIES OF z_i_travel_fmb
    ENTITY travel
    CREATE
    SET FIELDS WITH VALUE
    #( ( travel_id    = '900000004'
         agency_id    = '070008'
         customer_id  = '000071'
         begin_date   = cl_abap_context_info=>get_system_date( )
         end_date     = cl_abap_context_info=>get_system_date( ) + 10
         booking_fee = '80.00'
         currency_code = 'USD'
         overall_status = 'O'
         description = 'I created this!' ) )
MAPPED DATA(mapped)
FAILED failed
REPORTED reported.

    out->write( mapped-travel ).

    COMMIT ENTITIES
      RESPONSE OF z_i_travel_fmb
      FAILED     failed_commit
      REPORTED   reported_commit.

    DATA: lt_create_travel TYPE TABLE FOR CREATE z_i_travel_fmb\\Travel,
          lw_create_travel LIKE LINE OF lt_create_travel.
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<fs_travels>).
      <fs_travels>-travel_id = '90000003'.
      <fs_travels>-description = 'Created'.
      <fs_travels>-overall_status = 'O'.
      MOVE-CORRESPONDING <fs_travels> TO lw_create_travel.
      APPEND lw_create_travel TO lt_create_travel.
    ENDLOOP.

    MODIFY ENTITIES OF z_i_travel_fmb "  IN LOCAL MODE
    ENTITY travel
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

    COMMIT ENTITIES
          RESPONSE OF z_i_travel_fmb
          FAILED     failed_commit
          REPORTED   reported_commit.

    " Read entity
    READ ENTITIES OF z_i_travel_fmb
        ENTITY Travel
        ALL FIELDS
        WITH VALUE #( ( %key = '90000003' ) )
        RESULT travels
        FAILED failed
        REPORTED reported.
    out->write( travels ).
    out->write( failed ).
    out->write( reported ).


    " Delete entity
    MODIFY ENTITIES OF z_i_travel_fmb
    ENTITY travel
      DELETE FROM
        VALUE
          #( ( %key  = '900000003' ) )
   FAILED failed
   REPORTED reported.


  ENDMETHOD.

ENDCLASS.
