@AbapCatalog.sqlViewName: 'ZV_TRAV_FMB'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface - Travel'
define root view z_i_travel_fmb
as select from ztravel_fmb as Travel
composition [0..*] of z_i_booking_fmb as _Booking
association [0..1] to /DMO/I_Agency as _Agency
on $projection.agency_id = _Agency.AgencyID
association [0..1] to /DMO/I_Customer as _Customer
on $projection.customer_id = _Customer.CustomerID
association [0..1] to I_Currency as _Currency
on $projection.currency_code = _Currency.Currency
{
key travel_id,
agency_id,
customer_id,
begin_date,
end_date,
@Semantics.amount.currencyCode:
'currency_code'
booking_fee,
@Semantics.amount.currencyCode:
'currency_code'
total_price,
@Semantics.currencyCode: true
currency_code,
description,
overall_status,
@Semantics.user.createdBy: true
created_by,
@Semantics.systemDateTime.createdAt: true
created_at,
@Semantics.user.lastChangedBy: true
last_changed_by,
@Semantics.systemDateTime.lastChangedAt: true
last_changed_at,
case 
when total_price = 0 then 0
else 
division(cast(booking_fee as abap.dec(10,2)) * 10 , cast(total_price as abap.dec(10,2)), 4) * 100
end as Percent,
@Semantics.largeObject:
{ mimeType: 'MimeType',
  fileName: 'Filename',
  contentDispositionPreference: #INLINE }
attachment            as Attachment,
@Semantics.mimeType: true
mimetype              as MimeType,
filename              as Filename,
_Booking,
_Agency,
_Customer,
_Currency
}
