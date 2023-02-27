# Creating Your Own Validation

## Prerequisites
Online Validation (OVS) is an ABAP-based service available for SAP S/4 HANA systems. You will need to implement the SAP Notes with the Online Validation or upgrade to a corresponding Support package level. The list of all available corrections is attached to the [3291504](https://launchpad.support.sap.com/#/notes/3291504). The overal picture of the Online Validations can be found in the SAP Note [3085468](https://launchpad.support.sap.com/#/notes/3085468).

## Preparation
Learn about how to implement and activate a new validation in your system. 
Make sure you read through all the sections before start coding so you can reuse the [example class](../src/zcl_ovs_example.clas.abap) from this repository and the existing code in your system.


### [1. Customizing](Customizing.md)
### [2. Business Add-In implementation](BAdIImplementation.md)
### [3. Validation Implementation](CheckImplementation.md)
### [4. Reusable Objects](ReusableObjects.md)


## Useful tips
Here you can find useful information about issues that are not directly connected to the validation development. Learn about how to solve various issues or how to get started with development tasks that are new to you. 

### [Testing your iFlows](TestingiFlow.md)