@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTravel217', 
  semanticKey: [ 'TravelID' ]
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TRAVEL217
  provider contract transactional_query
  as projection on ZR_TRAVEL217
  association [1..1] to ZR_TRAVEL217 as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  TravelID,
  Description,
  @Consumption.valueHelpDefinition: [{ entity: { name: '/dmo/c_dest_rec_h',
                                               element: 'CountryName'
                                             }
                                  }]
  Destination,
  @Consumption.valueHelpDefinition: [{ entity: { name: '/dmo/c_acc_rec_h',
                                               element: 'AccName'
                                             }
                                  }]
  Accommodation,
  @Semantics: {
    user.createdBy: true
  }
  LocalCreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  LocalCreatedAt,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  LocalLastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalLastChangedAt,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LastChangedAt,
  _BaseEntity
}
