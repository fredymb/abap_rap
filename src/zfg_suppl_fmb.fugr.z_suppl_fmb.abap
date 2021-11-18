FUNCTION z_suppl_fmb.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_SUPPLEMENTS) TYPE  ZTT_SUPPL_FMB
*"     REFERENCE(IV_OP_TYPE) TYPE  ZDE_FLAG
*"  EXPORTING
*"     REFERENCE(EV_UPDATED) TYPE  ZDE_FLAG
*"----------------------------------------------------------------------
  CHECK NOT it_supplements IS INITIAL.

  CASE iv_op_type.
    WHEN 'C'.
      INSERT zbooksuppl_fmb FROM TABLE @it_supplements.
    WHEN 'U'.
      UPDATE zbooksuppl_fmb FROM TABLE @it_supplements.
    WHEN 'D'.
      DELETE zbooksuppl_fmb FROM TABLE @it_supplements.
  ENDCASE.
  IF sy-subrc EQ 0.
    ev_updated = abap_true.
  ENDIF.

ENDFUNCTION.
