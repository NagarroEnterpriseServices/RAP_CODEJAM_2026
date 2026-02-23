CLASS lhc_Agency DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Agency.

    METHODS earlynumbering_cba_Employee FOR NUMBERING
      IMPORTING entities FOR CREATE Agency\_Employee.

    METHODS validateCountryCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR Agency~validateCountryCode.

    METHODS validateEMailAddress FOR VALIDATE ON SAVE
      IMPORTING keys FOR Agency~validateEMailAddress.

    METHODS validateName FOR VALIDATE ON SAVE
      IMPORTING keys FOR Agency~validateName.

ENDCLASS.

CLASS lhc_Agency IMPLEMENTATION.

  METHOD earlynumbering_create.
  ENDMETHOD.

  METHOD earlynumbering_cba_Employee.
  ENDMETHOD.

  METHOD validateCountryCode.
  ENDMETHOD.

  METHOD validateEMailAddress.
  ENDMETHOD.

  METHOD validateName.
  ENDMETHOD.

ENDCLASS.
