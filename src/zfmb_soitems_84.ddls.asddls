@AbapCatalog.sqlViewName: 'ZFMB_VW_SOITEMS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Sales order'
define view ZFMB_SOITEMS_84 as select from zfmb_vbap
association to parent ZFMB_SO_84 as _SO on $projection.vbeln = _SO.vbeln
 {
    
    // zfmb_vbap
    key vbeln,
    key posnr,
    matnr,
    matkl,
    meins,
    netwr,
    waerk,
    erdat,
    ernam,
    netpr,
    _SO
        
}
