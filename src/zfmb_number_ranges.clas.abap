CLASS zfmb_number_ranges DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  interfaces if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZFMB_NUMBER_RANGES IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

  DATA : lv_norange  TYPE REF TO cl_numberrange_objects,
         lv_interval TYPE REF TO cl_numberrange_intervals,
         lv_runtime  TYPE REF TO cl_numberrange_runtime.

  DATA : nr_attribute  TYPE cl_numberrange_objects=>nr_attribute,
         obj_text      TYPE cl_numberrange_objects=>nr_obj_text,
         lv_returncode TYPE cl_numberrange_objects=>nr_returncode,
         lv_errors     TYPE cl_numberrange_objects=>nr_errors,
         nr_interval   TYPE cl_numberrange_intervals=>nr_interval,
         st_interval   LIKE LINE OF nr_interval,
         nr_number     TYPE cl_numberrange_runtime=>nr_number,
         nr_interval1  TYPE cl_numberrange_runtime=>nr_interval,
         error         TYPE cl_numberrange_intervals=>nr_error,
         error_inf     TYPE cl_numberrange_intervals=>nr_error_inf,
         error_iv      TYPE cl_numberrange_intervals=>nr_error_iv,
         warning       TYPE cl_numberrange_intervals=>nr_warning.

  nr_attribute-buffer = 'X'.
  nr_attribute-object = 'ZNR_BLD_NO'. " object name
  nr_attribute-domlen = 'CHAR10'. " domain to be used eg char 10
  nr_attribute-percentage = 10.
  nr_attribute-devclass = 'ZFMB'. "Class where number range actually gets created
  obj_text-langu = 'E'.
  obj_text-object = 'ZNR_BLD_NO'. "object name
  obj_text-txt = 'Testing Num Range'. "long description
  obj_text-txtshort = 'Test'. "short description

  st_interval-subobject = ''.
  st_interval-nrrangenr = 'N1'. "number range interval
* st_INTERVAL-toyear
  st_interval-fromnumber  = '1000000'. " starting number
  st_interval-tonumber    = '9999999'. " ending number
  st_interval-procind     = 'I'.
  APPEND st_interval TO nr_interval.


    TRY.
      cl_numberrange_objects=>create(
      EXPORTING
          attributes                = nr_attribute
          obj_text                  = obj_text
      IMPORTING
          errors = lv_errors
          returncode = lv_returncode )
         .
    CATCH cx_number_ranges INTO DATA(lx_number_range).
  ENDTRY.


    TRY.

      CALL METHOD cl_numberrange_intervals=>create
        EXPORTING
          interval  = nr_interval
          object    = 'ZNR_BLD_NO'
          subobject = ''
        IMPORTING
          error     = error
          error_inf = error_inf
          error_iv  = error_iv.
    CATCH  cx_nr_object_not_found INTO DATA(lx_no_obj_found).
    catch CX_NUMBER_RANGES into data(cx_number_ranges).

  ENDTRY.

ENDMETHOD.
ENDCLASS.
