@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View Travel Analytical Table'
@Metadata.ignorePropagatedAnnotations: true

define root view entity Z218I_TRVL_AT
  as select from zatrvl_ana_218
{
  key travel_uuid    as TravelUuid,
       travel_id      as TravelId,
       agency_id      as AgencyId,
       customer_id    as CustomerId,
       begin_date     as BeginDate,
       end_date       as EndDate,
       @Semantics.amount.currencyCode: 'CurrencyCode'
       booking_fee    as BookingFee,
       @Semantics.amount.currencyCode: 'CurrencyCode'
       booking_fee    as minBookingFee,
       @Semantics.amount.currencyCode: 'CurrencyCode'
       booking_fee    as maxBookingFee,
       @Semantics.amount.currencyCode: 'CurrencyCode'
       total_price    as TotalPrice,
       currency_code  as CurrencyCode,
       description    as Description,
       overall_status as OverallStatus,
       cast ( 1 as abap.int4 ) as differentCurrencies
}
