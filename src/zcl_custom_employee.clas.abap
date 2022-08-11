CLASS zcl_custom_employee DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES IF_RAP_QUERY_PROVIDER.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CUSTOM_EMPLOYEE IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

DATA query_result  TYPE TABLE OF Z_I_CUSTOM_EMPLOYEE.
DATA total_number_of_records type int8.
DATA(top)               = io_request->get_paging( )->get_page_size( ).
DATA(skip)              = io_request->get_paging( )->get_offset( ).
DATA(requested_fields)  = io_request->get_requested_elements( ).
DATA(sort_order)        = io_request->get_sort_elements( ).
TRY.
 DATA(filter_condition) = io_request->get_filter( )->get_as_ranges( ).

 "Here you have to implement your custom query
 "and store the result in the internal table query_result
 LOOP AT requested_fields ASSIGNING FIELD-SYMBOL(<fs_requested_fields>).
 <fs_requested_fields> = |{ <fs_requested_fields> } ,|.
 at last.
 replace all OCCURRENCES OF ',' in <fs_requested_fields> with space.
 endat.
 ENDLOOP.
 SELECT (requested_fields)
 FROM zemployee_fmb
 INTO CORRESPONDING FIELDS OF TABLE @query_result.

 total_number_of_records = lines( query_result ).

 IF io_request->is_total_numb_of_rec_requested(  ).
   io_response->set_total_number_of_records( total_number_of_records ).
 ENDIF.
 io_response->set_data( query_result ).
CATCH cx_root INTO DATA(exception).
DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).
ENDTRY.

  ENDMETHOD.
ENDCLASS.
