CLASS lhc_Employee DEFINITION INHERITING FROM
cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_features FOR FEATURES
    IMPORTING keys REQUEST requested_features FOR
    Employee RESULT result.
ENDCLASS.

CLASS lhc_Employee IMPLEMENTATION.
  METHOD get_features.
  ENDMETHOD.
ENDCLASS.
