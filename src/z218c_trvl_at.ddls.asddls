@Metadata.allowExtensions: true
@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label: 'Projection View Travel Analytical Table'
@OData.applySupportedForAggregation: #FULL
define root view entity z218c_trvl_at
  provider contract transactional_query
  as projection on Z218I_TRVL_AT
{
  key TravelUuid,
       TravelId,
       AgencyId,
       CustomerId,
       BeginDate,
       EndDate,
       @Aggregation.default: #AVG
       @EndUserText.label: 'Booking Fee (#AVG)'
       @Semantics.amount.currencyCode: 'CurrencyCode'
       BookingFee,
       @Aggregation.default: #MIN
       @EndUserText.label: 'Booking Fee (#MIN)'
       @Semantics.amount.currencyCode: 'CurrencyCode'
       minBookingFee,
       @Aggregation.default: #MAX
       @EndUserText.label: 'Booking Fee (#MAX)'
       @Semantics.amount.currencyCode: 'CurrencyCode'
       maxBookingFee,
       @Semantics.amount.currencyCode: 'CurrencyCode'
       @Aggregation.default: #SUM
       TotalPrice,
       @Aggregation.default: #COUNT_DISTINCT
       @Aggregation.referenceElement: [ 'CurrencyCode' ]
       differentCurrencies,
       @Consumption: {
           valueHelpDefinition: [ {
           entity.element: 'Currency',
           entity.name: 'I_CurrencyStdVH',
           useForValidation: true
           } ]
           }
       CurrencyCode,
       Description,
       OverallStatus
}
