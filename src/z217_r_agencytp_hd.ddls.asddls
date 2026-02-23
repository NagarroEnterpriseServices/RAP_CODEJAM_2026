@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Hierarchy: Draft: Agency'

define root view entity Z217_R_AgencyTP_HD
  as select from Z217_I_Agency_HD

  composition of exact one to many Z217_R_EmployeeTP_HD as _Employee 

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
      _Employee
}
