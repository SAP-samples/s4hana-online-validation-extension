# Usage of SAP Delivered Objects
You can reuse classes and methods that SAP delivers for your own validation. 

### Disablement
During the validation process, you might need to check whether currently validated value has been disabled for validations. For that, you can reuse the following method: 
```
DATA(iv_disabled) = cl_ovs_services=>is_disabled( 
      EXPORTING 
        iv_partner_type = <partner_type>
        iv_partner_type = <partner_number>
        iv_check_id = <check_id>
        iv_check_sub_id = <sub_id> ).
```
If the value has been disabled, the result of the validation should have an entry for disabled validations in the [Customizing](Customizing.md).



### Reusing Existing validation Results
The validation of one particular value can be executed several times per day. It is unlikely that the used online service would return a different result. The [Customizing](Customizing.md) even enables you to reuse the existing values for a couple of days if the existing value is 'VALID'. If you reuse the existing values, you need to maintain a dedicated result code in the [Customizing](Customizing.md). 
```
cl_ovs_services=>is_valid_in_cache(  
      EXPORTING 
        iv_partner_type = <partner_type>
        iv_partner_type = <partner_number>
        iv_check_id = <check_id>
        iv_check_sub_id = <sub_id> 
      IMPORTING 
        ev_last_check_result = DATA(lv_last_result)
        rv_is_valid = DATA(lv_valid) ).
IF lv_valid IS NOT INITIAL AND lv_last_result = <valid_in_cache>. 
  " don't validate, directly assing a result code for Valid in Cache status. 
ENDIF.
```

The parameter `lv_valid` is set if the cache contains a value within the validity set in the [Customizing](Customizing.md). Only if the `lv_valid` is set, you can use the `lv_last_result`. Otherwise, it has an undefined value. 

### Checking, whether Reusing Existing validation Results has been suppressed 
The validation is supposed to reuse the existing results if it is possible. However, some business processes allow the users to request fresh results. You can use the following method to check whether the user requested a fresh validation. In such case, you shall not use the cached results. 
```
DATA(bypass_buffer) = cl_ovs_services=>is_online_validation_required( data = it_data ).
```

 ### Get Message Type
 Based on the [Customizing](Customizing.md), you need to decide whether you want to display any validation message in addition to the validation result. If you decide to display a validation message, maintain the message type and message text in the Customizing. 
```
DATA(ls_msg) = cl_ovs_services=>get_message(
            iv_check_id         = <check_id>
            iv_check_result     = <check_result>
            iv_integration_spot = <integration_spot> ).
IF ls_msg-type = 'E'.
  MESSAGE ...
ENDIF. 		
```

Alternatively you can use the method `ZCL_OVS_EXAMPLE->display_standard_msg` that translates a vaidation result to a message and passes this message to the `io_msg_handler`.  

### Validate Unassigned Partners
In the Online Validation of Multiple Partners report (OVF_MASS_CHECK), it is possible to request validation of partners, that are not assigned to the selected Company codes. Although the partner selection is done in that report, the value of the parameter migth be needed during the validation. 
```
DATA(validate_unnasigned_partners) = ZCL_OVS_EXAMPLE=>is_validate_all_requested( it_data = it_data ).
```


### Reuse of Methods for Customizing
If you need to access some other values maintained in the [Customizing](Customizing.md), you can reuse one of the methods defined in the `cl_ovs_customizing` class. 

 
 ### Communication with an External Service
If a simple communication with an external service is required through xml or text payload, you can reuse the `cl_ovs_comm` class. The communication is synchronous. 
Note that this class might not be suitable for REST-like based services in which a part of the request is a part of the URL. 

| Method | Description |
| ----------- | ----------- |
| `open_connection` | Opens a connection to an online resource. `iv_comm_system` requires a name of an RFC. This name can be obtained from the customizing using the `cl_ovs_customizing` class.  | 
| `send_sync` | Sends the request in the http request body and waits for a response which is then returned.  | 
| `close_connection` | Must be called at the end of the validation process to release all the network resources.  | 

If there is an issue with the communication, the `send_sync` method throws an `cx_ovs_error`. Similarly, the `open_connection` method throws the same exception if the communication cannot be opened (wrong URL, Unauthorized etc.).
