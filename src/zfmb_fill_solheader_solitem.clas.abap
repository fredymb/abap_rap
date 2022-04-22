CLASS zfmb_fill_solheader_solitem DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zfmb_fill_solheader_solitem IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

  data: lt_solheader TYPE STANDARD TABLE OF zfmb_solheader,
        lt_solitem TYPE STANDARD TABLE OF zfmb_solitem.

        lt_solheader = value #(  ( solnum = '0000000010'
                                   society = 'CO01'
                                   status = 'O'
                                   created_by   = cl_abap_context_info=>get_user_technical_name(  )
                                   created_at = cl_abap_context_info=>get_system_date(  )
                                   last_changed_by = cl_abap_context_info=>get_user_technical_name(  )
                                   last_changed_at = cl_abap_context_info=>get_system_date(  )
                                   )
                                   ( solnum = '0000000020'
                                   society = 'CO01'
                                   status = 'O'
                                   created_by   = cl_abap_context_info=>get_user_technical_name(  )
                                   created_at = cl_abap_context_info=>get_system_date(  )
                                   last_changed_by = cl_abap_context_info=>get_user_technical_name(  )
                                   last_changed_at = cl_abap_context_info=>get_system_date(  )
                                   )
                                   ( solnum = '0000000030'
                                   society = 'CO01'
                                   status = 'O'
                                   created_by   = cl_abap_context_info=>get_user_technical_name(  )
                                   created_at = cl_abap_context_info=>get_system_date(  )
                                   last_changed_by = cl_abap_context_info=>get_user_technical_name(  )
                                   last_changed_at = cl_abap_context_info=>get_system_date(  )
                                   )

                                    ).

lt_solitem = value #(  ( solnum = '0000000010'
                         posnr = '00010'
                         material = '1234'
                         quantity = '10'
                         unit = 'ST'
                         price = 10
                         currency = 'USD'
                         created_by   = cl_abap_context_info=>get_user_technical_name(  )
                         created_at = cl_abap_context_info=>get_system_date(  )
                         last_changed_by = cl_abap_context_info=>get_user_technical_name(  )
                         last_changed_at = cl_abap_context_info=>get_system_date(  )
                         )
                          ( solnum = '0000000020'
                         posnr = '00010'
                         material = '1234'
                         quantity = '20'
                         unit = 'ST'
                         price = 10
                         currency = 'USD'
                         created_by   = cl_abap_context_info=>get_user_technical_name(  )
                         created_at = cl_abap_context_info=>get_system_date(  )
                         last_changed_by = cl_abap_context_info=>get_user_technical_name(  )
                         last_changed_at = cl_abap_context_info=>get_system_date(  )
                         )
                         ( solnum = '0000000030'
                         posnr = '00010'
                         material = '1234'
                         quantity = '30'
                         unit = 'ST'
                         price = 10
                         currency = 'USD'
                         created_by   = cl_abap_context_info=>get_user_technical_name(  )
                         created_at = cl_abap_context_info=>get_system_date(  )
                         last_changed_by = cl_abap_context_info=>get_user_technical_name(  )
                         last_changed_at = cl_abap_context_info=>get_system_date(  )
                         )
                                    ).

try.
modify zfmb_solheader from table @lt_solheader.
commit work and wait.
catch cx_root.
endtry.

try.
modify zfmb_solitem from table @lt_solitem.
commit work and wait.
catch cx_root.
endtry.

out->write( 'DONE!' ).



  ENDMETHOD.

ENDCLASS.
