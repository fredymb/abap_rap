CLASS zcl_virt_image_fmb DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VIRT_IMAGE_FMB IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
  CASE <fs_calc_element>.
        WHEN 'AGENCYINITS'.
        APPEND 'AGENCYNAME' TO et_requested_orig_elements.
  ENDCASE.
 ENDLOOP.

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.

   DATA lt_original_data TYPE STANDARD TABLE OF z_c_travel_fmb WITH DEFAULT KEY.

lt_original_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<ls_original_data>).
      <ls_original_data>-ImageURL =  'https://image.shutterstock.com/image-vector/travel-agency-tour-operator-flat-600w-1323177512.jpg'.
      <ls_original_data>-AgencyInits = <ls_original_data>-AgencyName(2).
    ENDLOOP.
    ct_calculated_data = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.
ENDCLASS.
