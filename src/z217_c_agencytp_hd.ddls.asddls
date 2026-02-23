@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Agency Consumption View'

@Metadata.allowExtensions: true


define root view entity Z217_C_AGENCYTP_HD 
    provider contract transactional_query
    as projection on Z217_R_AgencyTP_HD
{
    key Agency,
    Name,
    Street,
    PostalCode,
    City,
    CountryCode,
    PhoneNumber,
    EMailAddress,
    WebAddress,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Country,
    _Employee  : redirected to composition child Z217_C_EmployeeTP_HD
}
