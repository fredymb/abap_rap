@AbapCatalog.sqlViewName: 'ZFMB_VW_SO_84'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Sales order'

define root view ZFMB_SO_84 as select from zfmb_vbak
composition [1..*] of ZFMB_SOITEMS_84 as _SOITEMS 
 {
    
    // zfmb_vbak
    
    @Consumption.semanticObject: 'Action'

    @UI.lineItem: [ { position: 10, label: 'Sales Document Number'}, {type: #FOR_INTENT_BASED_NAVIGATION, semanticObjectAction: 'tortademo'}]
    key vbeln,
    erdat,
    
    @UI.lineItem: [{position: 20, label: 'Created By' }] 
    ernam,
    auart,
    waerk,
    
    @UI.lineItem: [ { position: 30, label: 'Net Value'}]
    netwr,
    vkorg,
    spart,
    _SOITEMS
        
}
