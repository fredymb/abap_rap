@EndUserText.label: 'Consumption - Travel'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity z_c_travel_fmb
as projection on z_i_travel_fmb
{
key travel_id as TravelID,
@ObjectModel.text.element: ['AgencyName']
agency_id as AgencyID,
_Agency.Name as AgencyName,
@ObjectModel.text.element: ['CustomerName']
customer_id as CustomerID,
_Customer.LastName as CustomerName,
begin_date as BeginDate,
end_date as EndDate,
@Semantics.amount.currencyCode: 'CurrencyCode'
booking_fee as BookingFee,
@Semantics.amount.currencyCode: 'CurrencyCode'
total_price as TotalPrice,
@Semantics.currencyCode: true
currency_code as CurrencyCode,
description as Description,
overall_status as TravelStatus,
last_changed_at as LastChangedAt,
@Semantics.amount.currencyCode:
'CurrencyCode'
@ObjectModel.virtualElementCalculatedBy:
'ABAP:ZCL_VIRT_ELEM_FMB'
virtual DiscountPrice : /dmo/total_price,
Percent as Percent,
@ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRT_IMAGE_FMB'
virtual ImageURL: abap.string( 256 ),
@ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRT_IMAGE_FMB'
virtual AgencyInits: abap.char( 2 ),
Attachment,
MimeType,
Filename,
/* Associations */
_Agency,
_Booking : redirected to composition child z_c_booking_fmb,
_Currency,
_Customer
}
