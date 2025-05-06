class ZCL_OVS_EXAMPLE definition
  public
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_OVS_CHECK .
PROTECTED SECTION.
PRIVATE SECTION.
  CONSTANTS:
    GC_STCEG type abap_parmname  value 'STCEG',
    GC_STCEGS type abap_parmname  value 'STCEGS',
    GC_BP_NUM type abap_parmname  value 'BP_NUM',
    GC_BP_TYPE type abap_parmname  value 'BP_TYPE',
    "! Replace by the ID of your validation
    GC_CHECK_ID type ovs_d_checkid value 'XXXXX'.

  "! Perform validation from the Sales Order creation or Billing (SD module).
  "!
  "! @parameter it_data | Data to be validated.
  "! @parameter iv_integration_spot | Name of the integration sport ('BILLING' or 'SALES')
  "! @parameter ct_result | Validation results
  METHODS validate_billing_sales
  IMPORTING
    it_data TYPE abap_parmbind_tab
    iv_integration_spot TYPE ovs_d_integration_spot
  CHANGING ct_result TYPE ovs_t_history.

  "! An example how to convert a string variable to an BASE64 encoded xstring.
  "!
  "! @parameter iv_data | String value to be converted.
  "! @parameter rv_result | Converted value.
  METHODS to_xstring
    IMPORTING iv_data TYPE string
    RETURNING VALUE(rv_result) TYPE xstring.


  "! An example how to find corresponding business partner for a customer or vendor.
  "!
  "! @parameter iv_partner_type | Type of the partner. V = Vendor, C = Customer
  "! @parameter iv_partner_number | ID of the vendor/customer/
  "! When iv_partner_type = 'V', than this parameter corresponds to LFA1-lifnr,
  "! when iv_partner_type = 'C' then parameter corresponds to KNA1-KUNNR.
  "! @parameter rv_partner | Corresponding BP ID (BUT000-partner).
  METHODS get_bp_for_cust_vendor
    importing iv_partner_type  type ovs_d_partnertype
      iv_partner_number  type ovs_d_partnerid
    returning value(rv_partner)  type ovs_d_partnerid
  .

  "! Perform validation from the Validate Multiple Partners program.
  "!
  "! @parameter it_data | Data to be validated.
  "! @parameter it_integration_spot | Always 'MASS_CHECK'.
  "! @parameter ct_result | Validation results
  METHODS validate_mass_check
    IMPORTING
      it_data TYPE abap_parmbind_tab
      it_integration_spot TYPE ovs_d_integration_spot
    CHANGING
      ct_result TYPE ovs_t_history.

 "! Perform validation from the Business Partner maintenance transaction.
  "!
  "! @parameter it_data | Data to be validated.
  "! @parameter iv_integration_spot | Always 'BP'.
  "! @parameter ct_result | Validation results
  METHODS validate_bp
    IMPORTING
      it_data TYPE abap_parmbind_tab
      iv_integration_spot TYPE ovs_d_integration_spot
    CHANGING
      ct_result TYPE ovs_t_history.

  "! Perform validation from the Automatic Payment Program (F110)
  "!
  "! @parameter it_data | Data to be validated.
  "! @parameter iv_integration_spot | Name of the integration spot
  "! @parameter io_msg_handler | Message handler.
  "! @parameter ct_result | Validation results
  METHODS validate_payment
    IMPORTING
      it_data TYPE abap_parmbind_tab
      iv_integration_spot TYPE ovs_d_integration_spot
      io_msg_handler TYPE REF TO IF_OVS_MESSAGE_HANDLER
    CHANGING
      ct_result TYPE ovs_t_history.

  "! Perform validation Post FI document (FB01, FB60 etc.)
  "!
  "! @parameter it_data | Data to be validated.
  "! @parameter iv_integration_spot | Name of the integration spot
  "! @parameter io_msg_handler | Message handler.
  "! @parameter ct_result | Validation results
  METHODS validate_fi_post
    IMPORTING
      it_data TYPE abap_parmbind_tab
      iv_integration_spot TYPE ovs_d_integration_spot
      io_msg_handler TYPE REF TO if_ovs_message_handler
    CHANGING
      ct_result TYPE ovs_t_history.

  "! Perform validation Change FI document (FB02, Maintain Journal Entries Fiori app)
  "!
  "! @parameter it_data | Data to be validated.
  "! @parameter iv_integration_spot | Name of the integration spot
  "! @parameter io_msg_handler | Message handler.
  "! @parameter ct_result | Validation results
  METHODS validate_fi_change
    IMPORTING
      it_data TYPE abap_parmbind_tab
      iv_integration_spot TYPE ovs_d_integration_spot
      io_msg_handler TYPE REF TO if_ovs_message_handler
    CHANGING
      ct_result TYPE ovs_t_history.

  "! Perform validation Post/Change MM document (MIRO)
  "!
  "! @parameter it_data | Data to be validated.
  "! @parameter iv_integration_spot | Name of the integration spot
  "! @parameter io_msg_handler | Message handler.
  "! @parameter ct_result | Validation results
  METHODS validate_mm
    IMPORTING
      it_data TYPE abap_parmbind_tab
      iv_integration_spot TYPE ovs_d_integration_spot
    CHANGING
      ct_result TYPE ovs_t_history.

  "! Check, whether the user requested to validate parnters not assigned to selected company code.
  "! This flag is supported in the Mass Check report only. The proper checkbox must be is selected.
  "! Although the selection of partners has been done by the Mass Check report, the parameter
  "! might be needed here.
  "!
  "! @parameter it_data | Data to be validated.
  "! @parameter rv_result | True if the user requested to validate unassigned partners.
  CLASS-METHODS is_validate_all_requested
    IMPORTING
      it_data TYPE abap_parmbind_tab
    RETURNING VALUE(rv_result) type abap_bool.


  "! Use this method if you don't require a more specific message.
  "! The user will see the text that is maintained in the customizing (transaction OVS_CHECKS) and associated with the actual validation result.
  "!
  "! @parameter io_msg_handler | Massage handler instace (passed to the main method validation).
  "! @parameter iv_val_result | Thye result code of the validation.
  "! @parameter iv_integration_spot | Integration spot (passed to the main method validation).
  CLASS-METHODS display_standard_msg
    IMPORTING io_msg_handler TYPE REF TO IF_OVS_MESSAGE_HANDLER
              iv_val_result TYPE ovs_d_checkresult
              iv_integration_spot TYPE ovs_d_integration_spot.
ENDCLASS.



CLASS ZCL_OVS_EXAMPLE IMPLEMENTATION.


  METHOD GET_BP_FOR_CUST_VENDOR.
    IF iv_partner_type = 'V'.  " Vendor
      SELECT SINGLE partner
        INTO rv_partner
        FROM but000 JOIN cvi_vend_link
        ON but000~partner_guid = cvi_vend_link~partner_guid
        WHERE cvi_vend_link~vendor = iv_partner_number.
    ELSEIF iv_partner_type = 'C'.  " Customer
      SELECT SINGLE partner
        INTO rv_partner
        FROM but000 JOIN cvi_cust_link
        ON but000~partner_guid = cvi_cust_link~partner_guid
        WHERE cvi_cust_link~customer = iv_partner_number.
    ENDIF.
  ENDMETHOD.


  METHOD IF_OVS_CHECK~GET_DISABLEMENT_VALUES.

  ENDMETHOD.


  METHOD IF_OVS_CHECK~VALIDATE.
  " @todo: As this class is just an example from https://github.com/SAP-samples/s4hana-online-validation-extension
  " Let it dump by default. Manual adaptation is needed. Check the GitHub page for more details.
  " DON'T forget to updfate the value of the GC_CHECK_ID attribute
   MESSAGE 'Validation not implemented' type 'X'.

    CASE iv_integration_spot.
      WHEN 'BILLING'      "Billing Document Posting
        OR 'SALES'.       "Sales Order Posting
        validate_billing_sales(
          EXPORTING
            it_data = it_data
            iv_integration_spot = iv_integration_spot
            CHANGING ct_result = ct_result ).
      WHEN 'BP'.           "Business Partner Check Event
        validate_BP(
          EXPORTING
            it_data = it_data
            iv_integration_spot = iv_integration_spot
            CHANGING ct_result = ct_result ).
      WHEN 'FI_DOCPOST'.   "FI Document Posting
        validate_fi_post(
          EXPORTING
            it_data = it_data
            iv_integration_spot = iv_integration_spot
            io_msg_handler = io_msg_handler
            CHANGING ct_result = ct_result ).
      WHEN 'MASS_CHECK'.   "Partners Mass Check Report
        validate_mass_check(
          EXPORTING
            it_data = it_data
            it_integration_spot = iv_integration_spot
            CHANGING ct_result = ct_result ).
      WHEN 'MM_DOCPOST'.   "MM Document Posting
        validate_mm(
          EXPORTING
            it_data = it_data
            iv_integration_spot = iv_integration_spot
            io_msg_handler = io_msg_handler
            CHANGING ct_result = ct_result ).
      WHEN 'PAYMENT'.      "Payment Run
        validate_payment(
          EXPORTING
            it_data = it_data
            iv_integration_spot = iv_integration_spot
            io_msg_handler = io_msg_handler
            CHANGING ct_result = ct_result ).
    ENDCASE.
  ENDMETHOD.


  METHOD TO_XSTRING.
     CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
                EXPORTING text = iv_data
                IMPORTING buffer = rv_result.
  ENDMETHOD.


  METHOD VALIDATE_BILLING_SALES.
    DATA: lr_data TYPE REF TO data,
          lt_vat_table TYPE cl_ovs_vies_impl=>ty_t_vies_check_request,
          lt_validation_results TYPE ovs_t_history.

    FIELD-SYMBOLS: <fs_par_value> TYPE any,
                   <data_line>    TYPE abap_parmbind.

    " The table shall have a line with name STCEGS and BPNUM,BPTYPE,STCEG rows
    LOOP AT it_data ASSIGNING <data_line> WHERE name = gc_stcegs.
      TRY.
        lr_data ?= <data_line>-value.
          ASSIGN lr_data->* TO <fs_par_value>.
          MOVE <fs_par_value> TO lt_vat_table.
      CATCH cx_sy_move_cast_error.
      ENDTRY.
    ENDLOOP.

    CHECK lt_vat_table[] IS NOT INITIAL.

    " True if a fresh validation is requested by the user. Otherwise, a previous result from the OVF_HISTORY can be returned.
    DATA(bypass_buffer) = cl_ovs_services=>is_online_validation_required( data = it_data ).

    " Here you can implement the validation and collect the results to the lt_validation_results
    " @todo: write your code here.
    " lt_vat_table contains VAT ID. Partner number can be used if you need
    " to select additional data from the DB.


    " Return the result. In the SO/Billing posting, possible warnings/errors will be handled automatically.
    APPEND LINES OF lt_validation_results TO ct_result.

  ENDMETHOD.


  METHOD VALIDATE_BP.
    DATA: lv_stceg  type stceg,
          lv_bpnum  type bu_partner,
          lv_bptype  type ovs_d_partnertype,
          ls_validation_result TYPE ovs_s_history.


    DATA par_value TYPE REF TO DATA.
    FIELD-SYMBOLS: <fs_par_value> TYPE any,
                   <data_line>    TYPE abap_parmbind.
    " The table shall have a line with name STCEG and STCEG value
    LOOP AT it_data ASSIGNING <data_line> WHERE name = gc_stceg.
      TRY.
        par_value ?= <data_line>-value.
          ASSIGN par_value->* TO <fs_par_value>.
          MOVE <fs_par_value> TO lv_stceg.
      CATCH cx_sy_move_cast_error.
      ENDTRY.
    ENDLOOP.

    LOOP AT it_data ASSIGNING <data_line> WHERE name = gc_bp_num.
      TRY.
        par_value ?= <data_line>-value.
          ASSIGN par_value->* TO <fs_par_value>.
          MOVE <fs_par_value> TO lv_bpnum.
      CATCH cx_sy_move_cast_error.
      ENDTRY.
    ENDLOOP.

     LOOP AT it_data ASSIGNING <data_line> WHERE name = gc_bp_type.
      TRY.
        par_value ?= <data_line>-value.
          ASSIGN par_value->* TO <fs_par_value>.
          MOVE <fs_par_value> TO lv_bptype.
      CATCH cx_sy_move_cast_error.
      ENDTRY.
    ENDLOOP.

    " The VAT no might not be empty
    CHECK lv_stceg IS NOT INITIAL.

    " True if a fresh validation is requested by the user. Otherwise, a previous result from the OVF_HISTORY can be returned.
    DATA(bypass_buffer) = cl_ovs_services=>is_online_validation_required( data = it_data ).

    " Here you can implement the validation and collect the results to the lt_validation_results
    " @todo: write your code here.
    " lv_stceg contains the VAT ID. Partner number can be used if you need
    " to select additional data from the DB.

    " Return the result. In the SO/Billing posting, possible warnings/errors will be handled automatically.
    APPEND ls_validation_result TO ct_result.

  ENDMETHOD.


  METHOD VALIDATE_FI_CHANGE.
    FIELD-SYMBOLS:
      <t_bseg>  TYPE bseg_t,
      <t_bsec> TYPE bsec_t,
      <i_bkpf>  TYPE bkpf,
      <origin> TYPE if_ovf_ovs_types=>ty_origin. " Manage Journal Entries require a different error handling.
    DATA: ls_msg           TYPE bapiret2,
          lt_check_results TYPE ovs_t_history,
          ls_check_result TYPE ovs_s_history.

    " Let's extract all the available data. Delete the variables which you don't need.
    " You shall check first whether given line exists: e.g. line_exists( it_data[ name = 'I_BKPF' ] ).
    READ TABLE it_data WITH KEY name = 'T_BSEG' kind = 'I' ASSIGNING FIELD-SYMBOL(<is_par>).
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <t_bseg>.
    CHECK sy-subrc = 0.
    READ TABLE it_data WITH KEY name = 'T_BSEC' kind = 'I' ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <t_bsec>.
    READ TABLE it_data WITH KEY name = 'I_BKPF' kind = 'I' ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <i_bkpf>.
    READ TABLE it_data WITH KEY name = 'ORIGIN' kind = 'I' ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <origin>.

    " @todo: validate the data. Store the results into lt_check_results


    " The exit from Fiori handles the message.
    " In case we are called from the FB02, we have to show the message here.
    IF <origin> <> if_ovf_ovs_types=>gc_origin_change_fiori.
      LOOP AT lt_check_results INTO ls_check_result.
        CLEAR ls_msg.
        display_standard_msg( io_msg_handler = io_msg_handler iv_integration_spot = iv_integration_spot iv_val_result = ls_check_result-check_result ).
      ENDLOOP.
    ENDIF.
    " Return the results
    APPEND LINES OF lt_check_results TO ct_result.
  ENDMETHOD.


  METHOD VALIDATE_FI_POST.
    TYPES: ltt_bseg TYPE TABLE OF bseg,
           ltt_bsec TYPE TABLE OF bsec.
    FIELD-SYMBOLS: <t_bseg> TYPE ltt_bseg,
                   <t_bsec> TYPE ltt_bsec,
                   <s_bkpf> TYPE bkpf,
                   <is_par> TYPE abap_parmbind,
                   <s_bkdf> TYPE bkdf
                   .
    DATA lt_val_results TYPE ovs_t_history. "Validation results

    " Let's extract  available data. Delete the variables which you don't need.
    " You shall check first whether given line exists: e.g. line_exists( it_data[ name = 'I_BKPF' ] ).
    READ TABLE it_data WITH KEY name = 'I_BKPF' kind = 'C' ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <s_bkpf>.
    READ TABLE it_data WITH KEY name = 'T_BSEG' kind = 'C' ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <t_bseg>.
    READ TABLE it_data WITH KEY name = 'T_BSEC' kind = 'C' ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <t_bsec>.
    READ TABLE it_data WITH KEY name = 'I_BKDF' kind = 'I' ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <s_bkdf>.

    " If additional data are needed, you can use this patter to extract more data:
    " READ TABLE it_data WITH KEY name = 'T_XXXXX' kind = 'C' ASSIGNING <is_par>.
    " CHECK sy-subrc = 0.
    " ASSIGN <is_par>-value->* TO <t_XXXXX>.
    " where the XXXXX / <t_XXXXX> is a TABLE OF XXXXX for the following tables:
    " In case the table type differs, it is provided in brackets
    " AUSZ1, AUSZ2, and AUSZ3 (AUSZ3 is a TABLE OF AUSZ_CLR). All values are optional.
    " BKP1, BKPF, BSED, T_BSET, BSEU, RSGTAB (TABLE OF IRSGTAB), RENUM (TABLE OF IRENUM), T_POSTAB (TABLE OF AUSZ_INFO)

    " @todo: perform the validation, store the results to lt_val_results

    " Check the results
    LOOP AT lt_val_results INTO DATA(ls_result).
      display_standard_msg( io_msg_handler = io_msg_handler iv_integration_spot = iv_integration_spot iv_val_result = ls_result-check_result ).
    ENDLOOP.

    " Return the results
    APPEND LINES OF lt_val_results TO ct_result.

  ENDMETHOD.


  METHOD VALIDATE_MASS_CHECK.
    DATA: par_value TYPE REF TO DATA,
          lt_partners TYPE ovs_t_partner_keys,
          lt_validation_results TYPE ovs_t_history..

    FIELD-SYMBOLS: <fs_par_value> TYPE any,
                   <data_line>    TYPE abap_parmbind.

    " Extract the table with BP numbers
    LOOP AT it_data ASSIGNING <data_line> WHERE name = if_ovs_constants=>GC_BP_NUM_TAB.
      TRY.
          par_value ?= <data_line>-value.
          ASSIGN par_value->* TO <fs_par_value>.
          MOVE <fs_par_value> TO lt_partners.
      CATCH cx_sy_move_cast_error.
      ENDTRY.
    ENDLOOP.

    " Don't continue if the request is empty.
    CHECK lt_partners[] IS NOT INITIAL.

    " True if a fresh validation is requested by the user. Otherwise, a previous result from the OVF_HISTORY can be returned.
    DATA(bypass_buffer) = cl_ovs_services=>is_online_validation_required( data = it_data ).

    " True if the user request validation of partners not assigned to the selected Company Code.
    DATA(validate_unnasigned_partners) = is_validate_all_requested( it_data = it_data ).

    " Here you can implement the validation and collect the results to the lt_validation_results
    " @todo: write your code here.
    " lt_partners contains the BP IDs.You will need to select the data to validate from the DB.

    " Return the result. In the SO/Billing posting, possible warnings/errors will be handled automatically.
    APPEND LINES OF lt_validation_results TO ct_result.

  ENDMETHOD.


  METHOD VALIDATE_MM.
    FIELD-SYMBOLS: <i_rbkp> TYPE RBKP,
                    <t_rseg> TYPE MRM_TAB_MRMRSEG,
                    <t_rbco> TYPE MRM_TAB_MRMRBCO,
                    <t_rbma> TYPE MRM_TAB_MRMRBMA,
                    <t_rbtx> TYPE MRM_TAB_MRMRBTX,
                    <t_rbws> TYPE MRM_TAB_MRMRBWS,
                    <is_par> TYPE abap_parmbind.
    DATA: lt_check_results TYPE ovs_t_history.

    READ TABLE it_data WITH KEY name = 'I_RBKP' kind = 'I' ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <i_rbkp>.
    READ TABLE it_data WITH KEY name = 'TI_RSEG_NEW' kind = 'I' ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <t_rseg>.
    READ TABLE it_data WITH KEY name = 'TI_RBCO_NEW' kind = 'I' ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <t_rbco>.
    READ TABLE it_data WITH KEY name = 'TI_RBMA_NEW' kind = 'I' ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <t_rbma>.
    READ TABLE it_data WITH KEY name = 'TI_RBTX_NEW' kind = 'I' ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <t_rbtx>.
    READ TABLE it_data WITH KEY name = 'TI_RBWS_NEW' kind = 'I' ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <t_rbws>.

    " @todo: perform the validation

    " Show the results as standard messages (= the text is taken from the OVS_CHECKS customizing transaction). 
    LOOP AT lt_val_results INTO DATA(ls_result).
      display_standard_msg( io_msg_handler = io_msg_handler iv_integration_spot = iv_integration_spot iv_val_result = ls_result-check_result ).
    ENDLOOP.
    
    APPEND LINES OF lt_check_results TO ct_result.
  ENDMETHOD.


  METHOD VALIDATE_PAYMENT.
    TYPES:
      ltt_f110_pbank TYPE TABLE OF f110_pbank,
      ltt_regup      TYPE TABLE OF regup,
      ltt_IHBANK     TYPE TABLE OF IHBANK.
    FIELD-SYMBOLS:
      " O for online to edit the proposal.
      " X to display the messages during the proposal or payment run.
      " SPACE so that you are also called during the proposal/payment run, but the log is deactivated.
      <i_trace>  TYPE char1,
      <ct_pbank> TYPE ltt_f110_pbank,  " Partner's bank
      <is_zhlg1> TYPE zhlg1,  " Payment method
      <is_reguh> TYPE reguh,  " Payment header
      <it_regup> TYPE ltt_regup, " Payment Items
      <I_LAUFD> TYPE LAUFD,   " F110 Run date
      <I_LAUFI> TYPE LAUFI,   " F110 Run ID
      <I_XVORL> TYPE XVORL,   " X = Proposal run, space = Payment run
      <CT_HBANK> TYPE ltt_IHBANK, " House Banks
      <CS_KBANK1> TYPE F110_KBANK, " Correspondence 1
      <CS_KBANK2> TYPE F110_KBANK, " Correspondence 2
      <CS_KBANK3> TYPE F110_KBANK. " Correspondence 3

    DATA lt_val_results TYPE ovs_t_history. "Validation results

    " Extract all avaialble data. Delete the vairables which you don't need.
    " You shall check first whether given line exists: e.g. line_exists( it_data[ name = 'I_TRACE' ] ).
    READ TABLE it_data WITH KEY name = 'I_TRACE' kind = cl_abap_objectdescr=>importing ASSIGNING FIELD-SYMBOL(<is_par>).
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <i_trace>.
    READ TABLE it_data WITH KEY name = 'CT_PBANK' kind = cl_abap_objectdescr=>changing ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <ct_pbank>.
    READ TABLE it_data WITH KEY name = 'IS_ZHLG1' kind = cl_abap_objectdescr=>importing ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <is_zhlg1>.
    READ TABLE it_data WITH KEY name = 'IS_REGUH' kind = cl_abap_objectdescr=>importing ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <is_reguh>.
    READ TABLE it_data WITH KEY name = 'IT_REGUP' kind = cl_abap_objectdescr=>importing ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <it_regup>.
    CHECK sy-subrc = 0.
    READ TABLE it_data WITH KEY name = 'I_LAUFD' kind = cl_abap_objectdescr=>importing ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <I_LAUFD>.
    READ TABLE it_data WITH KEY name = 'I_LAUFI' kind = cl_abap_objectdescr=>importing ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <I_LAUFI>.
    READ TABLE it_data WITH KEY name = 'I_XVORL' kind = cl_abap_objectdescr=>importing ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <I_XVORL>.
    READ TABLE it_data WITH KEY name = 'CT_HBANK' kind = cl_abap_objectdescr=>importing ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <CT_HBANK>.
    READ TABLE it_data WITH KEY name = 'CS_KBANK2' kind = cl_abap_objectdescr=>importing ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <CS_KBANK1>.
    READ TABLE it_data WITH KEY name = 'CS_KBANK2' kind = cl_abap_objectdescr=>importing ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <CS_KBANK2>.
    READ TABLE it_data WITH KEY name = 'CS_KBANK3' kind = cl_abap_objectdescr=>importing ASSIGNING <is_par>.
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <CS_KBANK3>.

*  -------------------------------------------------------------------------
*   While editing proposal, this code is called even for changes in Exceptions.
*   Exceptions don't have neither VBLNR nor RZAWE filled => skip futher checks.
*  -------------------------------------------------------------------------
    IF <i_trace> = 'O' AND <is_reguh>-vblnr = space.
      RETURN.
    ENDIF.

    " Process the results.
     LOOP AT <ct_pbank> ASSIGNING FIELD-SYMBOL(<ls_pbank>).

     " @todo: Perform the validation here and store the results into lt_val_results

      LOOP AT lt_val_results INTO DATA(ls_check_result).
        " Let's block only in case the validation result = error
        " Read the message from the OVS_CHECKS customizing
        DATA(ls_message) = cl_ovs_services=>get_message(
            iv_check_id         = ls_check_result-check_id
            iv_check_result     = ls_check_result-check_result
            iv_integration_spot = iv_integration_spot ).
        CHECK ls_message IS NOT INITIAL.
        IF  ls_message-type = 'E'.
         " Set "Indicator:Bank Details Inaccessible due to Customer Function"
         " This is how you propagate the info to the payment program that current
         " partner's bank account shall be considered invalid.
          <ls_pbank>-xcusf = abap_true.
        ENDIF.

        "Standard logging at F110
        IF <i_trace> = 'X'.
            IF ls_message-type = 'I'.
              " If you want to display info in the log, we need to change the type to a Status msg
              ls_message-type = 'S'.
            ENDIF.

            IF ls_message-type = 'E'.
              " It is not possible to directly display E messages, one solution is to change the type to Warning msg
              ls_message-type = 'W'.
            ENDIF.

            " Add a message to the log
            io_msg_handler->log_message( ls_message ).

        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " Return the results
    APPEND LINES OF lt_val_results TO ct_result.

  ENDMETHOD.

  METHOD is_validate_all_requested.
    FIELD-SYMBOLS <validate_all> TYPE abap_bool.

    CLEAR rv_result.
    READ TABLE it_data WITH KEY name = 'VALIDATE_ALL'  kind = cl_abap_objectdescr=>importing ASSIGNING FIELD-SYMBOL(<is_par>).
    CHECK sy-subrc = 0.
    ASSIGN <is_par>-value->* TO <validate_all>.
    rv_result = <validate_all>.
  ENDMETHOD.

  METHOD display_standard_msg.
    DATA(lv_msg) = cl_ovs_services=>get_message( iv_check_id = gc_check_id iv_check_result = iv_val_result iv_integration_spot = iv_integration_spot  ).
    IF lv_msg IS NOT INITIAL.
      io_msg_handler->log_message( iv_msg = lv_msg ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
