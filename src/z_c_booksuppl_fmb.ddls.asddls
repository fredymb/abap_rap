@EndUserText.label: 'Consumption - Booking
Supplement'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity z_c_booksuppl_fmb
as projection on z_i_booksuppl_fmb
{
key travel_id as TravelID,
key booking_id as BookingID,
key booking_supplement_id as
BookingSupplementID,
@ObjectModel.text.element:
['SupplementDescription']
supplement_id as SupplementID,
_SupplementText.Description as
SupplementDescription : localized,
@Semantics.amount.currencyCode :
'CurrencyCode'
price as Price,
@Semantics.currencyCode: true
currency as CurrencyCode,
last_changed_at as LastChangedAt,
/* Associations */
_Travel : redirected to z_c_travel_fmb,
_Booking : redirected to parent z_c_booking_fmb,
_Product,
_SupplementText
}
