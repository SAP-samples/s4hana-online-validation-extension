# Validation Implementation
Once you have created the BAdI implementation, an implementation class with the IF_OVS_CHECK interface is created. The interface consists of the following methods:


| Field Name | Description |
| ----------- | ----------- |
| `GET_DISABLEMENT_VALUES` | This method provides data for validation disablement. |
| `VALIDATE` | This method performs validation of the business transaction data.  |

## Disablement
The Disablement of Online Validation for Business Partners report enables you to disable the validation of business partners' master data, such as the validation of VAT registration numbers and bank account numbers.
For more information, see [Disable Online Validation for Business Partners](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/b2d44c1091094b5a810c2a879ee95522/596ce9e9a01244eb87d47611996e3769.html). 

The `GET_DISABLEMENT_VALUES` method returns all values from the business partners’ master records that are available to be validated. Once you disable the validation, these values are displayed in the Disablement of Online Validation for Business Partners report. If you don’t need to disable validation of certain values, keep this method empty. 
This method has the following parameters:

| Parameter Name | Description |
| ----------- | ----------- |
| `it_partners` | Partner Type & Number pairs. See Partner Identification section bellow. |
| `ct_values`   | All the values of given partner that would be validated and can be disabled. A value for all columns must be provided in this method. |

The `ct_values` contains also the partner identification as well as the Check ID and the values that can be disabled. 
Find below more details about the Check SubID field. 


## Validation
The Online Validation routes the validation request to all BAdIs that you have configured for a business process in the  [Customizing](Customizing.md).
You can also check directly the implementation of the methods of the class
  example implementation class ../src/zcl_ovs_example.clas.abap can be

The `IF_OVS_CHECK~VALIDATE` method performs the validation. This method has the following parameters: 

| Parameter name | Description |
| ----------- | ----------- |
| `iv_integration_spot` | ID of the business process from which the validation was requested. |
| `it_data` | Data to be validated. The format of the data is different for each integration spot. |


> You can check method `ZCL_OVS_EXAMPLE->if_ovs_check~validate` for an example on how to use the `iv_integration_spot` parameter and related values.
> The value of the `iv_integration_spot` determines the data for the `it_data` parameter. This class is located in this GitHub repository, not part of your SAP S/4HANA system. 

### Data Extraction for Validation
After understanding what the `it_data` parameter is used for, you need to extract the data to be validated.

Check the following methods in the `ZCL_OVS_EXAMPLE` class [here](../src/zcl_ovs_example.clas.abap) as an example of conversion from type-free `it_data` into local variables with the correct data type. The examples show extractions of all available values in `it_data`. You can delete the variables which are not needed. 

You can use the method stub in your implementation and concentrate on the validation itself. 

| Method Name | Description |
| ----------- | ----------- |
| `validate_billing_sales` | Sales Order or Billing posting. The `it_data` contains VAT IDs together with the IDs of the business partners. |
| `validate_BP` | Business partner master data maintenance. The `it_data` contains VAT ID together with the ID of the business partner.  |
| `validate_mass_check` | Online Validation for Multiple Partners report. The `it_data` contains the IDs of business partners from the database to be validated. |
| `validate_payment` | Automatic payment report. The `it_data` contains data about the payment including all payment items. |
| `validate_fi_post` | FI document posting. The `it_data` contains data from the posted document including one time account data. |
| `validate_fi_change` | FI document change. The `it_data` contains data from the posted document including one time account data. |
| `validate_mm` | MM document posting (MIRO). The `it_data` contains data from the posted document including one time account data.  |

Some business process might send additional parameters in the `it_data`, e.g. whether it is possible to reuse cached results from previous validations or whether fresh results from the online service shall be fetched. The access and the availablity of such parameters is desdribed in the above given methods or in the [List of reusable objects](ReusableObjects.md). 

### Partner Identification
In the request and in the result, there are two fields to identify the partner: partner type and partner number. 
In SAP S/4HANA, as a general rule, you can enter 'B' as the partner type and `BUT000-PARTNER` as the partner number.

The same is used in the Disablement function, as follows:

| Partner Type | Partner Number and relation to the source table-column |
| ----------- | ----------- |
| B | Equal to the BUT000-PARTNER |
| C | Equal to KNA1-KUNNR |
| V | Equal to LFA1-LIFNR |

### Check Sub-identification
You can maintain the unique value for each validation value of a business partner in the Check Sub-identification (`OVF_D_CHECKSUBID`) field.
Note that the length of the validated value must not exceed 100 characters. If the VAT registration number or bank account number exceeds the limit, make sure you enter a shorter and yet unique value for a business partner. Keep in mind that the SubID might be visible in the Disablement app. 

### Maintaining the Table with Results
Your validation implementation creates a table with results and append them into the changing parameter `ct_result` of the `IF_OVS_CHECK~VALIDATE` method.
You can reuse the existing DDIC objects from the table type `OVS_T_HISTORY` and the structure `OVS_S_HISTORY`. 
The table has the following fields: 

| Field name | Description |
| ----------- | ----------- |
| `MANDT`  | Leave this field empty. |
| `PARTNER_TYPE`  | Partner type. See Partner identification section. |
| `PARTNER_NUMBER`  | Partner Number. See Partner identification section. |
| `CHECK_ID` | ID of your validation. Must be equal to the ID defined in the [Customizing](Customizing.md). |
| `CHECK_SUB_ID`  | ID of the validated value. See the Check SubID section. |
| `TIMESTAMP`  | Leave this field empty. This field is filled in automatically with the time stamp valid at the moment of writing the record to the database.  |
| `CHECK_RESULT`  | Result of the validation. The result must be equal to one of the values defined in the [Customizing](Customizing.md). |
| `INTEGRATION_SPOT` | ID of the integration spot. The integration spot ID is delivered as a parameter to the `IF_OVS_CHECK~VALIDATE` method. |
| `REQUEST` | If needed, you can store here additional information about the request sent to the online service. | 
| `FULL_RESPONSE` | If needed, you can store here a piece or the whole response form the online service. |

The partner type and partner number are usually derived from the input data. For example, when you use the Automatic Payment report, the input data contains the ID of the vendor or customer. 
The REQUEST and the FULL_RESPONSE contain a value in the xstring form. You can use the `ZCL_OVS_EXAMPLE=>to_xstring` method in the example class. The History of Online Checks report displays the content of the fields in a xml viewer. Although the value can have any form, SAP recommends the usage of an xml form. The XML format is used by other SAP delivered validations. 

## Integration with an external API
Althoug it is technically possible to consume an external API using the protocol of that API, it is recommended using the [Cloud Platform integration](https://help.sap.com/docs/CLOUD_INTEGRATION?version=Cloud)(CPI). It allows building a unified consumption of external services and hiding the API specific protocol in an S/4 Hana system. The CPI simplifies the integration across the landscaspes and allows to process diverse scenarios. More details on how to extend SAP-delivered CPI objects can be found [here](ExtendingIFlows.md). 
<!--
This info shall be published once the way how the BAdIs are called is changed. Currently it is planned for the future. 

## Exceptional states
It might happen that the validation cannot be started or successfully finished. You can either return a dedicated Check Result code for a such situation or you can stop further validations. 
-->