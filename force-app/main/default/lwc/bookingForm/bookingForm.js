import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

import { getRecord } from 'lightning/uiRecordApi';


import UserID from "@salesforce/user/Id";
import Name from '@salesforce/schema/User.Name';
import EmployeeNumber from '@salesforce/schema/User.EmployeeNumber';
import RoleName from '@salesforce/schema/User.UserRole.Name';

import getOpportunityRecord from '@salesforce/apex/BookingFormController.OpportunityRecord';
import getProductDetails from '@salesforce/apex/BookingFormController.getProductDetails';
import getRecordDetails from '@salesforce/apex/BookingFormController.getRecordDetails';
import createBookingForm from '@salesforce/apex/BookingFormController.BookFormInsert';
import IsBookingFormExists from '@salesforce/apex/BookingFormController.IsBookingFormExists';
import getBookingFormRecord from '@salesforce/apex/BookingFormController.getBookingFormRecord';
import getOtherApplicantRecord from '@salesforce/apex/BookingFormController.getOtherApplicantRecord';
import getCostSheetRecord from '@salesforce/apex/BookingFormController.getCostSheetRecord';
import getSchemeRecords from '@salesforce/apex/BookingFormController.getSchemeRecords';
import CheckNdsDiscount from '@salesforce/apex/BookingFormController.CheckNdsDiscount';
//import getPaymentDetailsRecords from '@salesforce/apex/BookingFormController.getPaymentDetailsRecords';
import getBookingsourceslist from '@salesforce/apex/BookingFormController.getBookingsourceslist';
import getLoyaltyBonusList from '@salesforce/apex/BookingFormController.getloyaltyBonuslist';
import getPaymentScheduleList from '@salesforce/apex/BookingFormController.getPaymentScheduleList';
import getPaymentScheduleDetails from '@salesforce/apex/BookingFormController.getPaymentScheduleDetails';
import getPaymentScheduleRecord from '@salesforce/apex/BookingFormController.getPaymentScheduleRecord';
import getOrginalBasePrice from '@salesforce/apex/BookingFormController.getOrginalBasePrice';
import getContactDetails from '@salesforce/apex/BookingFormController.getContactDetails';



import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import BOOKINGFORM_OBJECT from '@salesforce/schema/Booking_Form__c';
import PROJECTNAME_FIELDOPTIONS from '@salesforce/schema/Booking_Form__c.Source_Project__c';
import SALETYPE_FIELD from '@salesforce/schema/Booking_Form__c.Sale_Type__c';
import CUSTOMERTYPE_FIELD from '@salesforce/schema/Booking_Form__c.Customer_Type__c';
import SALUTATION_FIELD from '@salesforce/schema/Booking_Form__c.Salutation__c';
import GENDER_FIELD from '@salesforce/schema/Booking_Form__c.Gender__c';
import PROFESSION_FIELD from '@salesforce/schema/Booking_Form__c.Profession__c';
import SALUTATIONR_FIELD from '@salesforce/schema/Booking_Form__c.Salutationr__c';
import MARITALSTATUS_FIELD from '@salesforce/schema/Booking_Form__c.Marital_Status__c';
import STATE_FIELD from '@salesforce/schema/Booking_Form__c.State__c';
import COUNTRY_FIELD from '@salesforce/schema/Booking_Form__c.Country__c';
import STATE_FIELD2 from '@salesforce/schema/Booking_Form__c.State2__c';
import COUNTRY_FIELD2 from '@salesforce/schema/Booking_Form__c.Country2__c';
import SALUTATION_FIELD_Other_Applicants from '@salesforce/schema/Other_Applicants__c.Salutation__c';
import OCCUPATION1_FIELD_Other_Applicants from '@salesforce/schema/Other_Applicants__c.Occupation__c';
import RSalutation_FIELD_Other_Applicants from '@salesforce/schema/Other_Applicants__c.RSalutation__c';
import Marital_Status_Other_Applicants from '@salesforce/schema/Other_Applicants__c.Marital_Status__c';
import GENDER1_FIELD from '@salesforce/schema/Other_Applicants__c.Gender__c';
import SERVICECATEGORY_FIELD from '@salesforce/schema/Booking_Form__c.Service_Category__c';
import PROFESSIONDETAILS_FIELD from '@salesforce/schema/Booking_Form__c.Professional_Details__c';
import ANNUALINCOME_FIELD from '@salesforce/schema/Booking_Form__c.Annual_Income__c';
import PAYMENTSOURCE_FIELD from '@salesforce/schema/Booking_Form__c.Payment_source__c';
import PURCHASE_FIELD from '@salesforce/schema/Booking_Form__c.Purchase_of_Purpose__c';
import OTHERPROJECT_FIELD from '@salesforce/schema/Booking_Form__c.Other_Projects__c';
import LOCATIONOFINTEREST_FIELD from '@salesforce/schema/Booking_Form__c.Location_of_Intrest__c';
import REMARKS_FIELD from '@salesforce/schema/Booking_Form__c.Select_Remarks__c';
import PAYMENTTYPE_FIELD from '@salesforce/schema/Booking_Form__c.Payment_Type__c';






export default class BookingForm extends NavigationMixin(LightningElement) {


    // vfPageUrl;

    /*get vfPageUrl() {
        // Construct the URL with the recordId as a parameter       
        return `/apex/BookingPDF?recordId=${this.recordId}`;
    } */

    //multiple clicks restriction
    @track isSaving = false; // Track the save status
    @track isDraftSaving = false; // Track the DraftSave status

    @api recordId;
    @track isNext = false;

    // Reset all tab states
    @track vfPageUrl;
    @track showModal = false;
    @track currentTab;
    @track isOtherApplicant = false;
    @track isAttachments = false;
    @track isScheme = false;
    @track isAccount = false;
    @track isOtherCharges = false;
    @track isSource = false;
    @track isPaymentSchedule = false;
    @track isOtherInfo = false;
    @track isRemarks = false;

    @track OtherApplicentLimitexceeded = false;

    @track isHi5Payment = false;
    @track isFlexiblePayment = false;

    @track OtherApplicentInputFieldValidation = false;
    @track OtherApplicentComboFieldValidation = false;
    @track OtherApplicentAadharcardvalidation = false;



    @track BookingFormInputFieldValidation = false;
    @track BookingFormComboFieldValidation = false;
    @track Aadharcarvalidation = false;

    @track schemavalidation = false;
    @track SalesNDsMaXDiscount = 0;



    get isAadharRequired() {
        return this.BookingFormDetails.selectedCustomerType == 'Indian Resident';
    }
    get isPanRequired() {
        return this.BookingFormDetails.selectedCustomerType == 'Indian Resident';
    }
    get isPassportRequired() {
        return this.BookingFormDetails.selectedCustomerType == 'Non-Indian Resident';
    }

    get NriMobileNumber() {

        if (this.BookingFormDetails.selectedCustomerType == 'Non-Indian Resident') {
            return 20;
        } else {
            return 10;
        }
    }

    get AccountFieldRequired() {

        if ((this.BookingFormDetails.AccountNo != '' && this.BookingFormDetails.AccountNo != null)
            || (this.BookingFormDetails.NameofBank != '' && this.BookingFormDetails.NameofBank != null)
            || (this.BookingFormDetails.IFSCCode != '' && this.BookingFormDetails.IFSCCode != null)
            || (this.BookingFormDetails.BankBranch != '' && this.BookingFormDetails.BankBranch != null)) {
            return true;
        } else {
            return false;
        }

    }

    //DropdownList 
    @track projectNameOptions;
    @track saletypeOptions;
    @track customerTypeOptions;
    @track salutationOptions;
    @track genderOptions;
    @track professionOptions;
    @track salutationrOptions;
    @track maritalStatusOptions;
    @track stateOptions;
    @track stateOptions2;
    @track selectedState2;
    @track countryOptions2;

    @track schemeOptions = [];
    @track SchemaFullDetails = [];
    @track SourceFullDetails = [];
    @track SourcesOptions = [];


    @track serviceCategoryOptions;
    @track professionDetailsOptions;
    @track annualIncomeOptions;
    @track paymentSourceOptions;
    @track purchaseOptions;
    @track otherProjectOptions;
    @track LocationOptions;
    @track remarksOptions;
    @track paymentTypeOptions;

    @track fileVersions = [];
    @track filesToUpload = [];



    //Other Applicant
    @track BookingFormDetailsJson = [];
    @track selectedLocation = [];


    @track isexistingcustomer = false;
    @track isChannel = false;
    @track isreferenceEmp = false;
    @track isCustomer = false;
    @track opportuniId
    @track isSpinnerRunning = false;



    @track BookingFormDetails = {
        BookingFormId: '',
        Opportunity: '',
        ProjectName: '',
        Block: '',
        Unit: '',
        Tower: '',
        facing: '',
        sftArea: '',
        flatNo: '',
        unitType: '',
        CarpetArea: '',
        Balcony: '',
        Utility: '',
        ExternalWallArea: '',
        UDS: '',
        SBUA: '',
        Saletype: '',
        BasicRate: '',
        LumpSumAmount: '',
        OrginalLumpSUmAmount: '',
        CarParking: '',
        ExtraCarParkingNo: '',
        ExtraCarParking: '0',
        EvCharges: '',
        OtherCharges: '0',
        GrandTotal: '',
        selectedCustomerType: '',
        selectedSalutation: '',
        FirstName: '',
        LastName: '',
        Gender: '',
        Organization: '',
        Designation: '',
        PassportNo: '',
        Validtill: '',
        selectedProfession: '',
        selectedSalutationr: '',
        FirstNamer: '',
        LastNamer: '',
        DateOfBirth: '',
        age: '',
        Mobile: '',
        AlternativeMobile: '',
        TelRes: '',
        TelOffice: '',
        Email: '',
        AlternativeEmail: '',
        selectedMaritalStatus: '',
        AnniversaryDate: '',
        PanNo: '',
        AadharNo: '',
        SignthroughDigitalSignature:false,
        presentStreet: '',
        presentStreet2: '',
        presentStreet3: '',
        presentStreet4: '',
        presentStreet5: '',
        presentCity: '',
        selectedPresentState: '',
        selectedPresentCountry: '',
        presentPinCode: '',
        permanentStreet: '',
        permanentStreet2: '',
        permanentStreet3: '',
        permanentStreet4: '',
        permanentStreet5: '',
        permanentCity: '',
        selectedPermanentState: '',
        selectedPermanentCountry: '',
        permanentPinCode: '',
        SameasPresentAddress: false,
        Booking_Form_Status: 'Draft Save',
        AccountHolderName: '',
        AccountNo: '',
        NameofBank: '',
        IFSCCode: '',
        BankBranch: '',
        CampusFund: '',
        AdvanceMaintenance: '',
        GSTonInstalments: 'APPLICABLE AS PER GOVERNMENT NORMS',
        StampDuty: 'APPLICABLE AS PER GOVERNMENT NORMS  ',
        DocumentationCharges: '',
        OtherChargesIf: 'APPLICABLE AS PER GOVERNMENT NORMS',
        selectedServiceCategory: '',
        selectedProfessionDetails: '',
        selectedAnnualIncome: '',
        selectedPaymentSource: '',
        selectedPurchase: '',
        selectedOtherProject: '',
        selectedLocation: '',
        selectedLocationString: '',
        selectedRemarks: '',
        RemarksDescription: '',
        SalesPersonEmployeeID: '',
        Declaration: false,
        NDSORSDS: false,
        ndsValue: '0',
        sdsValue: '0',
        discount: '0',
        useScheme: false,
        selectedScheme: '',
        ndsDiscountAmount: '',
        ExtraDiscountAmount: '',
        sdsDiscountAmount: '',
        DiscountAmount: '',
        meterial: '',
        OrginalBasePrice: '',
        extraBasePrice: '',
        encash: false,
        SchemeAmount: '',
        SourceValue: '',
        SourceExistCustomerDiscount: '0',
        SourceChannelPartnerCode: '',
        SourceChannelPartnerName: '',
        SourceReferenceEmployeeCode: '',
        SourceEmployeeName: '',
        SourceEmployeeCompanyName: '',
        SourceCustomerCode: '',
        SourceCustomerRelationName: '',
        SourceCustomerName: '',
        SourceFlatNo: '',
        SourceProjectName: '',
        PaymentScheduleTotalAmount: '0',
        PaymentSchedulepercentage: '0',
        selectedPaymentType: '',
        SDSApprovelStatus: '',
        SDSApprovelComments: '',
        SourceExiCustomerCode: '',
        SourceExiCustomerName: '',
        SourceExiCustomerRelationName: '',
        SourceExiFlatNo: '',
        SourceExiProjectName: '',





    }

    //Other Applicant
    @track OtherApplicantDetailsJson = [];

    @track OtherApplicantDetails = {
        Id: "",
        index: "",
        Salutation1: "",
        FirstName1: "",
        LastName1: "",
        Gender1: "",
        Organization1: "",
        Occupation1: "",
        salutationr1Options: "",
        FirstNamer1: "",
        LastNamer1: "",
        DateofBirth1: "",
        age1: "",
        MaritalStatus1: "",
        AnniversaryDate1: "",
        Mobile1: "",
        Email1: "",
        PassportNo1: "",
        Validtill1: "",
        PanNo1: "",
        AadharNo1: "",
        applicantcount: ""
    }


    @track PaymentScheduleMD = [];

    @track PaymentScheduleDetails = {
        Id: "",
        index: "",
        Payment_Schedule_Type: "",
        Payment_Particulars: "",
        Amount: "",
        SerialNumber: "",
        Amount_In_Local_Currency: ""

    }

    @track isShowModal = false;
    @track isApplicantEdit = false;


    @wire(getRecord, { recordId: UserID, fields: [Name, RoleName, EmployeeNumber] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.EmployeeNumber.value != null) {
                this.BookingFormDetails.SalesPersonEmployeeID = data.fields.EmployeeNumber.value;
            }
        }
    }


    @wire(getObjectInfo, { objectApiName: BOOKINGFORM_OBJECT })
    productInfo;;
    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: PROJECTNAME_FIELDOPTIONS
    })
    ProjectPicklistValues({ error, data }) {
        if (data) {
            this.projectNameOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            //. console.log(error);
            // Handle error
        }
    }



    // saletypeOptions dynamic picklist
    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: SALETYPE_FIELD
    })
    handleSaletypePicklistValues({ error, data }) {
        if (data) {
            this.saletypeOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: CUSTOMERTYPE_FIELD
    })
    handleCustomerTypePicklistValues({ error, data }) {
        if (data) {
            this.customerTypeOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: SALUTATION_FIELD
    })
    handleSalutationPicklistValues({ error, data }) {
        if (data) {
            this.salutationOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: GENDER_FIELD
    })
    handleGenderPicklistValues({ error, data }) {
        if (data) {
            this.genderOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: PROFESSION_FIELD
    })
    handleProfessionPicklistValues({ error, data }) {
        if (data) {
            this.professionOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: SALUTATIONR_FIELD
    })
    handleSalutation2RPicklistValues({ error, data }) {
        if (data) {
            this.salutationrOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: MARITALSTATUS_FIELD
    })
    handleMaritalStatusPicklistValues({ error, data }) {
        if (data) {
            this.maritalStatusOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: STATE_FIELD
    })
    handleStatePicklistValues({ error, data }) {
        if (data) {
            this.stateOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }


    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: STATE_FIELD2
    })
    handleState2PicklistValues({ error, data }) {
        if (data) {
            this.stateOptions2 = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: COUNTRY_FIELD
    })
    handleCountryPicklistValues({ error, data }) {
        if (data) {
            this.countryOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: COUNTRY_FIELD2
    })
    handleCountry2PicklistValues({ error, data }) {
        if (data) {
            this.countryOptions2 = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: SALUTATION_FIELD_Other_Applicants
    })
    handleSalutation1PicklistValues({ error, data }) {
        if (data) {
            this.salutation1Options = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: OCCUPATION1_FIELD_Other_Applicants
    })
    handle10OccupationPicklistValues({ error, data }) {
        if (data) {
            this.occupation1Options = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: RSalutation_FIELD_Other_Applicants
    })
    handleSalutation2R1PicklistValues({ error, data }) {
        if (data) {
            this.salutationr1Options = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));


        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: Marital_Status_Other_Applicants
    })
    handleMaritalStatus10PicklistValues({ error, data }) {
        if (data) {
            this.maritalStatus1Options = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: GENDER1_FIELD
    })
    handleGender1PicklistValues({ error, data }) {
        if (data) {
            this.gender1Options = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }


    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: SERVICECATEGORY_FIELD
    })
    handleServiceCategoryPicklistValues({ error, data }) {
        if (data) {
            this.serviceCategoryOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: PROFESSIONDETAILS_FIELD
    })
    handleProfessionDetailsPicklistValues({ error, data }) {
        if (data) {
            this.professionDetailsOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: ANNUALINCOME_FIELD
    })
    handleAnnualIncomePicklistValues({ error, data }) {
        if (data) {
            this.annualIncomeOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: PAYMENTSOURCE_FIELD
    })
    handlePaymentSourcePicklistValues({ error, data }) {
        if (data) {
            this.paymentSourceOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: PURCHASE_FIELD
    })
    handlePurchasePicklistValues({ error, data }) {
        if (data) {
            this.purchaseOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: OTHERPROJECT_FIELD
    })
    handleOtherProjectPicklistValues({ error, data }) {
        if (data) {
            this.otherProjectOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: LOCATIONOFINTEREST_FIELD
    })
    handleLocationPicklistValues({ error, data }) {
        if (data) {
            this.LocationOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$productInfo.data.defaultRecordTypeId',
        fieldApiName: REMARKS_FIELD
    })
    handleRemarksPicklistValues({ error, data }) {
        if (data) {
            this.remarksOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            // Handle error
        }
    }


    connectedCallback() {
        //console.log('test recordID '+this.recordId);
        //this.opportuniId = this.recordId;
        
        if (this.recordId != null) {
            this.ProductDetails(this.recordId);
            //this.BookingFormDetails.Opportunity = this.recordId;
            this.oppDetails(this.recordId);

        }

    }

    lookupRecord(event) {
        //alert('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord));
        if (JSON.stringify(event.detail.selectedRecord) != null) {
            var oppID = event.detail.selectedRecord.Id;
            this.BookingFormDetails.Opportunity = oppID;
            this.oppDetails(oppID);
            this.ProductDetails(oppID);

        } else {
            this.BookingFormDetails.ProjectName = '';
            this.BookingFormDetails.Block = '';
            this.BookingFormDetails.Unit = '';
        }
    }

    oppDetails(oppId) {
        getOpportunityRecord({ recordId: oppId })
            .then((result) => {
                if (result != null) {
                    this.selectedRecord = result;
                    //console.log(result);
                    //this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
                }
            })
            .catch((error) => {
                this.error = error;
                //console.log("hello",error);
                this.selectedRecord = {};
            });
    }

    ProductDetails(oppId) {
        this.isSpinnerRunning = true;
        getProductDetails({ recordId: oppId })
            .then((result) => {
                if (result != null) {
                    this.selectedRecord = result;

                    this.BookingFormDetails.ProjectName = result[0].ProjectName;
                    this.BookingFormDetails.Block = result[0].Block;
                    this.BookingFormDetails.Unit = result[0].Unit;
                    this.BookingFormDetails.Opportunity = result[0].OpportunityId;
                    this.opportuniId = result[0].OpportunityId;
                    this.isSpinnerRunning = false;
                    console.log('opp.    ', this.opportuniId);
                    //this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
                }
            })
            .catch((error) => {
                this.error = error;
                // console.log("hello",error);
                this.showNotification('Error', 'An error occurred while retrieving the record details. Please try again later.', 'error');

                this.selectedRecord = {};
            });
    }

    handleNextClick() {
        IsBookingFormExists({
            OpportunityId: this.BookingFormDetails.Opportunity,
            selectedProject: this.BookingFormDetails.ProjectName,
            selectedBlock: this.BookingFormDetails.Block,
            selectedUnit: this.BookingFormDetails.Unit
        })
            .then(result => {
                //console.log(result);
                if (result) {

                    this.showNotification('Booking Form is Already Created.', 'Depending on the chosen project, block, and unit. Booking Form Is Created; Please Click Drafts.', 'info');


                } else {
                    //booking form is not exist new booking form will create
                    getRecordDetails({
                        selectedProject: this.BookingFormDetails.ProjectName,
                        selectedBlock: this.BookingFormDetails.Block,
                        selectedUnit: this.BookingFormDetails.Unit
                    })
                        .then(result => {
                            if (result) {
                                // Update component state with the received data
                                this.BookingFormDetails.Tower = result.Towers__c;
                                this.BookingFormDetails.facing = result.Facing__c;
                                this.BookingFormDetails.flatNo = result.Flat_No__c;
                                this.BookingFormDetails.unitType = result.Type__c;
                                this.BookingFormDetails.sftArea = result.Area_in_Sqft__c;
                                this.BookingFormDetails.CarpetArea = result.Sale_Unit_Carpet_Area_in_SFT__c;
                                this.BookingFormDetails.Balcony = result.Balcony__c;
                                this.BookingFormDetails.Utility = result.Utility__c;
                                this.BookingFormDetails.ExternalWallArea = result.External_wall_area__c;
                                this.BookingFormDetails.UDS = result.UDS__c;
                                this.BookingFormDetails.SBUA = result.Area_in_Sqft__c;
                                this.BookingFormDetails.ExtraCarParkingNo = result.Extra_Car_Parking__c;
                                this.BookingFormDetails.ExtraCarParking = 0;
                                this.BookingFormDetails.EvCharges = result.EV_Charges__c;
                                this.BookingFormDetails.OtherCharges = result.Other_Charges__c;
                                this.BookingFormDetails.meterial = result.Material__c;

                                let roundedValue = parseFloat((result.Corpus_Fund__c * result.Area_in_Sqft__c).toFixed(2));
                                this.BookingFormDetails.CampusFund = roundedValue;
                                this.BookingFormDetails.AdvanceMaintenance = (result.Advance_Maintenance__c * result.Area_in_Sqft__c);
                                this.BookingFormDetails.DocumentationCharges = (result.Legal_Charges__c);
                                //this.BookingFormDetails.OtherChargesIf = result.Other_Charges__c;




                                this.getCostSheetRecordApi();
                                this.getSchemeRecordsApi();
                                this.getBookingsourceslistApi();
                                this.getPaymentScheduleListApi();
                                this.getOrginalBasePriceApi();
                                this.getNDSDiscountAmountApi();
                                this.getContactListApi();
                                this.isNext = true;


                            } else {
                                // Handle case when no records are found
                                console.error('No records found');

                                this.showNotification('No Records Found', 'No record details found based on the selected project, block, and unit.', 'info');

                            }
                        })
                        .catch(error => {
                            // Handle errors
                            console.error('Error fetching records 1:', error);
                            this.showNotification('Error', 'An error occurred while fetching record details. Please try again later.', 'error');



                        });

                }
            })
            .catch(error => {
                // Handle errors
                console.error('Error fetching records2:', error);
                this.showNotification('Error', 'An error occurred while fetching record details. Please try again later.', 'error');

            });

    }


    getContactListApi() {
        console.log(this.BookingFormDetails.Opportunity);
        getContactDetails({
            OpportunityId: this.BookingFormDetails.Opportunity
        })
            .then(result => {
                //console.log('paymentSchedule',result);
                //this.paymentTypeOptions = result;
                console.log('contact reslts', result);

                if (result) {
                    //console.log('result cost sheet test',csresult);
                    console.log(result.length);
                    if (result.length > 0) {
                        console.log(result[0].LastName);
                        //this.BookingFormDetails.OrginalBasePrice = result[0].Basic_Price__c;
                        this.BookingFormDetails.FirstName = result[0].FirstName;
                        this.BookingFormDetails.LastName = result[0].LastName;
                        this.BookingFormDetails.Email = result[0].Email;
                        this.BookingFormDetails.selectedSalutation = result[0].Salutation;
                        this.BookingFormDetails.Mobile = result[0].Phone;
                        this.BookingFormDetails.AlternativeMobile = result[0].Phone_2__c;
                        if (result[0].DOB__c != null && result[0].DOB__c != '') {
                            this.BookingFormDetails.DateOfBirth = result[0].DOB__c;
                            let inputvalue = result[0].DOB__c;

                            // finding the age with DateOfBirth field;
                            let d1 = new Date(inputvalue);
                            let d2 = new Date();

                            let varAge = d2.getYear() - d1.getYear();
                            //console.log( varAge );

                            if (d1.getUTCMonth() < d2.getUTCMonth()) {
                                -varAge;

                            } else if (d1.getUTCMonth() === d2.getUTCMonth()) {
                                if (d1.getUTCDate() < d2.getUTCDate())
                                    -varAge;
                            }
                            this.BookingFormDetails.age = varAge;
                        }


                    }
                }
            })
            .catch(error => {
                // Handle errors
                //console.error('Error fetching records:', error);
                this.showNotification('Error', 'An error occurred while fetching record details. Please try again later.', 'error');


            });

    }

    getPaymentScheduleListApi() {
        getPaymentScheduleList({
            selectedProject: this.BookingFormDetails.ProjectName
        })
            .then(result => {
                //console.log('paymentSchedule',result);
                this.paymentTypeOptions = result;
            })
            .catch(error => {
                // Handle errors
                //console.error('Error fetching records:', error);
                this.showNotification('Error', 'An error occurred while fetching record details. Please try again later.', 'error');


            });

    }

    getOrginalBasePriceApi() {
        getOrginalBasePrice({
            ProjectName: this.BookingFormDetails.ProjectName,
            MaterialNumber: this.BookingFormDetails.meterial
        })
            .then(result => {
                //console.log('paymentSchedule',result);
                //this.paymentTypeOptions = result;

                if (result) {
                    //console.log('result cost sheet test',csresult);

                    if (result.length > 0) {
                        this.BookingFormDetails.OrginalBasePrice = result[0].Basic_Price__c;
                    }
                }


            })
            .catch(error => {
                // Handle errors
                //console.error('Error fetching records:', error);
                this.showNotification('Error', 'An error occurred while fetching record details. Please try again later.', 'error');


            });

    }

    getNDSDiscountAmountApi() {
        CheckNdsDiscount({
            selectedProject: this.BookingFormDetails.ProjectName
        })
            .then(result => {
                if (result.length > 0) {
                    if (result.length > 0) {
                        this.SalesNDsMaXDiscount = result[0].Amount_in_Local_Currency__c;
                    } else {
                        this.SalesNDsMaXDiscount = 0;
                    }
                } else {
                    this.SalesNDsMaXDiscount = 0;
                }


            })
            .catch(error => {
                // Handle errors
                //console.error('Error fetching records:', error);
                this.showNotification('Error', 'An error occurred while fetching record details. Please try again later.', 'error');


            });


    }






    getBookingsourceslistApi() {
        getBookingsourceslist({})
            .then(result => {
                if (result) {
                    this.SourceFullDetails = result;
                    result.forEach((values) => {

                        var obj = {
                            label: values.Source_Type__c,
                            value: values.Source_Type__c
                        };
                        this.SourcesOptions.push(obj);
                        //console.log('values.Source_Type__c',values.Source_Type__c)

                    });

                }
            })
            .catch(error => {
                // Handle errors
                console.error('Error fetching records3:', error);

                this.showNotification('Error', 'An error occurred while fetching record details. Please try again later.', 'error');

            });
    }

    getSchemeRecordsApi() {
        getSchemeRecords({
            selectedProject: this.BookingFormDetails.ProjectName
        })
            .then(SCresult => {
                if (SCresult) {
                    this.SchemaFullDetails = SCresult;
                    //console.log('SCresult',SCresult);
                    this.schemeOptions = [];
                    SCresult.forEach((values) => {

                        var obj = {
                            label: values.Description__c,
                            value: values.Description__c
                        };
                        this.schemeOptions.push(obj);
                        //console.log('values.Description__c',values.Description__c)

                    });

                    if (this.schemeOptions.length > 0) {
                        this.schemavalidation = true;
                    } else {
                        this.schemavalidation = false;
                    }

                    //console.log(JSON.stringify(this.schemeOptions));              


                }
            })
            .catch(error => {
                // Handle errors
                console.error('Error fetching records4:', error);

                this.showNotification('Error', 'An error occurred while fetching record details. Please try again later.', 'error');

            });
    }

    getCostSheetRecordApi() {
        getCostSheetRecord({
            OpportunityId: this.BookingFormDetails.Opportunity,
            selectedProject: this.BookingFormDetails.ProjectName,
            selectedBlock: this.BookingFormDetails.Block,
            selectedUnit: this.BookingFormDetails.Unit
        })
            .then(csresult => {
                if (csresult) {
                    //console.log('result cost sheet test',csresult);

                    if (csresult.length > 0) {
                        this.BookingFormDetails.BasicRate = csresult[0].Basic_Price__c;
                        this.BookingFormDetails.LumpSumAmount = csresult[0].Cost_of_the_Unit__c + csresult[0].Clubhouse_Charges__c + csresult[0].Infrastructure_charges__c;
                        this.BookingFormDetails.OrginalLumpSUmAmount = csresult[0].Cost_of_the_Unit__c + csresult[0].Clubhouse_Charges__c + csresult[0].Infrastructure_charges__c;
                        this.BookingFormDetails.CarParking = csresult[0].Car_Parking__c;
                    }

                }
                this.GrandTotalHAndler();
            })
            .catch(error => {
                // Handle errors
                console.error('Error fetching record5s:', error);

                this.showNotification('Error', 'An error occurred while fetching record details. Please try again later.', 'error');


            });
    }


    GrandTotalHAndler() {

        console.log('hello' + this.BookingFormDetails.LumpSumAmount + " - " + this.BookingFormDetails.CarParking + " - " + this.BookingFormDetails.ExtraCarParking + " - " + this.BookingFormDetails.EvCharges + " - " + this.BookingFormDetails.OtherCharges);
        let lumpsumAmount = 0;
        let CarParking = 0;
        let ExtraCarParking = 0;
        let EvCharges = 0;
        let OtherCharges = 0;
        let NDSAvalareasft = 0;
        let SDSAvalareasft = 0;
        let schemaAmountcal = 0;
        let discountAmountcal = 0;
        let forumala = 0;


        let areasft = this.BookingFormDetails.sftArea;
        let ndsValue = this.BookingFormDetails.ndsValue;
        let sdsValue = this.BookingFormDetails.sdsValue;
        let discount = this.BookingFormDetails.discount;
        let SchemeAmount = this.BookingFormDetails.SchemeAmount;
        let ExistCustomerDiscount = 0;
        let SourceExistCustomerDiscount = this.BookingFormDetails.SourceExistCustomerDiscount;



        if (ndsValue != '' && ndsValue != null) {
            NDSAvalareasft = (parseInt(ndsValue) * parseInt(areasft))
        } else {
            NDSAvalareasft = 0;
        }

        if (discount != '' && discount != null) {
            discountAmountcal = (parseInt(discount) * parseInt(areasft))
        } else {
            discountAmountcal = 0;
        }

        if (sdsValue != '' && sdsValue != null) {
            SDSAvalareasft = (parseInt(sdsValue) * parseInt(areasft))
        } else {
            SDSAvalareasft = 0;
        }

        if (SourceExistCustomerDiscount != '' && SourceExistCustomerDiscount != null) {
            ExistCustomerDiscount = parseInt(SourceExistCustomerDiscount);
        } else {
            ExistCustomerDiscount = '0';
        }

        if (SchemeAmount != '' && SchemeAmount != null) {
            schemaAmountcal = parseInt(SchemeAmount);
        } else {
            SchemeAmount = 0;
        }

        console.log(this.BookingFormDetails.LumpSumAmount);
        console.log(this.BookingFormDetails.OrginalLumpSUmAmount + "-" + parseInt(NDSAvalareasft) + "-" + parseInt(discountAmountcal) + "-" + parseInt(SDSAvalareasft) + "-" + parseInt(SchemeAmount) + "-" + parseInt(ExistCustomerDiscount));
        if (this.BookingFormDetails.LumpSumAmount != '' && this.BookingFormDetails.LumpSumAmount != null) {
            lumpsumAmount = (parseInt(this.BookingFormDetails.OrginalLumpSUmAmount) - parseInt(NDSAvalareasft) - parseInt(discountAmountcal) - parseInt(SDSAvalareasft) - parseInt(SchemeAmount) - parseInt(ExistCustomerDiscount));
            this.BookingFormDetails.LumpSumAmount = lumpsumAmount;
        } else {
            lumpsumAmount = 0;
        }

        if (this.BookingFormDetails.CarParking != '' && this.BookingFormDetails.CarParking != null) {
            CarParking = this.BookingFormDetails.CarParking;
        } else {
            CarParking = 0;
        }

        if (this.BookingFormDetails.ExtraCarParking != '' && this.BookingFormDetails.ExtraCarParking != null) {
            ExtraCarParking = this.BookingFormDetails.ExtraCarParking;
        } else {
            ExtraCarParking = 0;
        }

        if (this.BookingFormDetails.EvCharges != '' && this.BookingFormDetails.EvCharges != null) {
            EvCharges = this.BookingFormDetails.EvCharges;
        } else {
            EvCharges = 0;
        }

        if (this.BookingFormDetails.OtherCharges != '' && this.BookingFormDetails.OtherCharges != null) {
            OtherCharges = this.BookingFormDetails.OtherCharges;
        } else {
            OtherCharges = 0;
        }


        let GrandTotalprices = parseInt(lumpsumAmount) + parseInt(CarParking) + parseInt(ExtraCarParking) + parseInt(EvCharges) + parseInt(OtherCharges);



        //let GDTotal = this.BookingFormDetails.GrandTotal;



        console.log(GrandTotalprices + " - " + NDSAvalareasft + " - " + discountAmountcal + " - " + SDSAvalareasft + " - " + SchemeAmount + " - " + ExistCustomerDiscount);


        forumala = (parseInt(GrandTotalprices));

        this.BookingFormDetails.GrandTotal = forumala;

        //console.log('forumala',forumala);


        // }

        //this.BookingFormDetails.GrandTotal = parseInt(this.BookingFormDetails.LumpSumAmount)+parseInt(this.BookingFormDetails.CarParking)
        //+parseInt(this.BookingFormDetails.ExtraCarParking)+parseInt(this.BookingFormDetails.EvCharges)+parseInt(this.BookingFormDetails.OtherCharges);

        //console.log('GrandTotal'+this.BookingFormDetails.GrandTotal);
        // return this .BookingFormDetails.GrandTotal;



    }


    handleDraftClick() {


        IsBookingFormExists({
            OpportunityId: this.BookingFormDetails.Opportunity,
            selectedProject: this.BookingFormDetails.ProjectName,
            selectedBlock: this.BookingFormDetails.Block,
            selectedUnit: this.BookingFormDetails.Unit
        })
            .then(result => {
                //console.log(result);
                if (result) {
                    getBookingFormRecord({
                        OpportunityId: this.BookingFormDetails.Opportunity,
                        selectedProject: this.BookingFormDetails.ProjectName,
                        selectedBlock: this.BookingFormDetails.Block,
                        selectedUnit: this.BookingFormDetails.Unit
                    }).then(BFresult => {
                        //console.log('BFresult',JSON.stringify(BFresult));
                        //console.log(BFresult.Block__c);
                        //console.log(BFresult.Customer_Type__c);

                        if (BFresult.Booking_Form_Status__c == 'Final Submit') {


                            this.showNotification('Booking Form: Final Submission Completed', 'Booking Form: This form has been closed based on the project, block, and unit selected.', 'success');

                        } else {

                            this.getSchemeRecordsApi();
                            this.getBookingsourceslistApi();
                            this.getPaymentScheduleListApi();
                            this.getNDSDiscountAmountApi();

                            this.BookingFormDetails.BookingFormId = BFresult.Id;
                            this.BookingFormDetails.Opportunity = BFresult.Opportunity__c;
                            this.BookingFormDetails.ProjectName = BFresult.Project_Name__c;
                            this.BookingFormDetails.Block = BFresult.Block__c;
                            this.BookingFormDetails.Unit = BFresult.Unit__c;
                            this.BookingFormDetails.Tower = BFresult.Towers__c;
                            this.BookingFormDetails.facing = BFresult.Facing__c;
                            this.BookingFormDetails.sftArea = BFresult.Area_in_Sqft__c;
                            this.BookingFormDetails.flatNo = BFresult.Flat_No__c;
                            this.BookingFormDetails.unitType = BFresult.Unit_Type__c;
                            this.BookingFormDetails.CarpetArea = BFresult.Carpet_Area__c;
                            this.BookingFormDetails.Balcony = BFresult.Balcony__c;
                            this.BookingFormDetails.Utility = BFresult.Utility__c;
                            this.BookingFormDetails.ExternalWallArea = BFresult.External_Wall_Area__c;
                            this.BookingFormDetails.UDS = BFresult.UDS__c;
                            this.BookingFormDetails.SBUA = BFresult.Area_in_Sqft__c;
                            this.BookingFormDetails.Saletype = BFresult.Sale_Type__c;
                            this.BookingFormDetails.BasicRate = BFresult.Basic_Price__c;
                            this.BookingFormDetails.LumpSumAmount = BFresult.Lump_Sum_Amount__c;
                            this.BookingFormDetails.OrginalLumpSUmAmount = BFresult.OrginalLumpSUmAmount__c;
                            this.BookingFormDetails.CarParking = BFresult.Car_Parking_Charges__c;
                            this.BookingFormDetails.ExtraCarParkingNo = BFresult.Extra_Car_Parking__c;
                            this.BookingFormDetails.ExtraCarParking = BFresult.Extra_Car_Parking_Charges__c;
                            this.BookingFormDetails.EvCharges = BFresult.EV_Charges__c;
                            this.BookingFormDetails.OtherCharges = BFresult.Other_Charges__c;
                            this.BookingFormDetails.GrandTotal = BFresult.Booking_Form_Grand_Total__c;
                            this.BookingFormDetails.selectedCustomerType = BFresult.Customer_Type__c;
                            this.BookingFormDetails.selectedSalutation = BFresult.Salutation__c;
                            this.BookingFormDetails.FirstName = BFresult.First_Name__c;
                            this.BookingFormDetails.LastName = BFresult.Last_Name__c;
                            this.BookingFormDetails.Gender = BFresult.Gender__c;
                            this.BookingFormDetails.Organization = BFresult.Organization__c;
                            this.BookingFormDetails.Designation = BFresult.Designation__c;
                            this.BookingFormDetails.PassportNo = BFresult.Passport_No__c;
                            this.BookingFormDetails.Validtill = BFresult.Valid_till__c;
                            this.BookingFormDetails.selectedProfession = BFresult.Profession__c;
                            this.BookingFormDetails.selectedSalutationr = BFresult.Salutationr__c;
                            this.BookingFormDetails.FirstNamer = BFresult.First_Namer__c;
                            this.BookingFormDetails.LastNamer = BFresult.Last_Namer__c;
                            this.BookingFormDetails.DateOfBirth = BFresult.DOB__c;
                            this.BookingFormDetails.age = BFresult.Age__c;
                            this.BookingFormDetails.Mobile = BFresult.Mobile__c;
                            this.BookingFormDetails.AlternativeMobile = BFresult.Alternative_Mobile__c;
                            this.BookingFormDetails.TelRes = BFresult.TelRes__c;
                            this.BookingFormDetails.TelOffice = BFresult.TelOffice__c;
                            this.BookingFormDetails.Email = BFresult.Email__c;
                            this.BookingFormDetails.AlternativeEmail = BFresult.Alternative_Email__c;
                            this.BookingFormDetails.selectedMaritalStatus = BFresult.Marital_Status__c;
                            this.BookingFormDetails.AnniversaryDate = BFresult.Anniversary_Date__c;
                            this.BookingFormDetails.PanNo = BFresult.Pan_No__c;
                            this.BookingFormDetails.AadharNo = BFresult.Aadhar__c;
                            this.BookingFormDetails.SignthroughDigitalSignature = BFresult.Sign_through_Digital_Signature__c;
                            this.BookingFormDetails.presentStreet = BFresult.StreetHouse_No__c;
                            this.BookingFormDetails.presentStreet2 = BFresult.Street_2__c;
                            this.BookingFormDetails.presentStreet3 = BFresult.Street_3__c;
                            this.BookingFormDetails.presentStreet4 = BFresult.Street_4__c;
                            this.BookingFormDetails.presentStreet5 = BFresult.Street_5__c;
                            this.BookingFormDetails.presentCity = BFresult.City__c;
                            this.BookingFormDetails.selectedPresentState = BFresult.State__c;
                            this.BookingFormDetails.selectedPresentCountry = BFresult.Country__c;
                            this.BookingFormDetails.presentPinCode = BFresult.Pin_Code__c;
                            this.BookingFormDetails.permanentStreet = BFresult.StreetHouse_No2__c;
                            this.BookingFormDetails.permanentStreet2 = BFresult.Street_21__c;
                            this.BookingFormDetails.permanentStreet3 = BFresult.Street_31__c;
                            this.BookingFormDetails.permanentStreet4 = BFresult.Street_41__c;
                            this.BookingFormDetails.permanentStreet5 = BFresult.Street_51__c;
                            this.BookingFormDetails.permanentCity = BFresult.City2__c;
                            this.BookingFormDetails.selectedPermanentState = BFresult.State2__c;
                            this.BookingFormDetails.selectedPermanentCountry = BFresult.Country2__c;
                            this.BookingFormDetails.permanentPinCode = BFresult.Pin_Code2__c;
                            this.BookingFormDetails.SameasPresentAddress = BFresult.Same_as_Present_Address__c;
                            this.BookingFormDetails.Booking_Form_Status = BFresult.Booking_Form_Status__c;

                            this.BookingFormDetails.AccountHolderName = BFresult.Account_Name__c;
                            this.BookingFormDetails.AccountNo = BFresult.Account_No__c;
                            this.BookingFormDetails.NameofBank = BFresult.Name_of_Bank__c;
                            this.BookingFormDetails.IFSCCode = BFresult.IFSC_Code__c;
                            this.BookingFormDetails.BankBranch = BFresult.Bank_Branch__c;
                            this.BookingFormDetails.CampusFund = BFresult.Corpus_Fund__c;
                            this.BookingFormDetails.AdvanceMaintenance = BFresult.Advance_Maintenance__c;
                            this.BookingFormDetails.GSTonInstalments = BFresult.GST_on_Instalments__c;
                            this.BookingFormDetails.StampDuty = BFresult.Stamp_Duty_Fee__c;
                            this.BookingFormDetails.DocumentationCharges = BFresult.Doc_Charges__c;
                            this.BookingFormDetails.OtherChargesIf = BFresult.Other_Charges_If__c;

                            this.BookingFormDetails.selectedServiceCategory = BFresult.Service_Category__c;
                            this.BookingFormDetails.selectedProfessionDetails = BFresult.Professional_Details__c;
                            this.BookingFormDetails.selectedAnnualIncome = BFresult.Annual_Income__c;
                            this.BookingFormDetails.selectedPaymentSource = BFresult.Payment_source__c;
                            this.BookingFormDetails.selectedPurchase = BFresult.Purchase_of_Purpose__c;
                            this.BookingFormDetails.selectedOtherProject = BFresult.Other_Projects__c;
                            if (BFresult.Location_of_Intrest__c != '' && BFresult.Location_of_Intrest__c != null) {
                                this.selectedLocation = BFresult.Location_of_Intrest__c.split(";");
                                this.BookingFormDetails.selectedLocationString = BFresult.Location_of_Intrest__c;

                            }

                            this.BookingFormDetails.selectedRemarks = BFresult.Select_Remarks__c;
                            this.BookingFormDetails.RemarksDescription = BFresult.Remarks_Description__c;

                            this.BookingFormDetails.SalesPersonEmployeeID = BFresult.Sales_PersonID__c;
                            this.BookingFormDetails.Declaration = BFresult.Declaration__c;


                            this.BookingFormDetails.NDSORSDS = BFresult.NDS_or_SDS__c;
                            this.BookingFormDetails.ndsValue = BFresult.NDS_per_sft__c;
                            this.BookingFormDetails.discount = BFresult.Discount_Amount__c;
                            this.BookingFormDetails.sdsValue = BFresult.SDS_per_sft__c;

                            this.BookingFormDetails.DiscountAmount = BFresult.Scheme_Discount_Amount__c;
                            this.BookingFormDetails.meterial = BFresult.Project_Meterial__c;
                            this.BookingFormDetails.OrginalBasePrice = BFresult.Orginal_Base_Price__c;
                            this.BookingFormDetails.extraBasePrice = BFresult.Extra_Base_Price_Discount__c;

                            this.BookingFormDetails.useScheme = BFresult.Use_Scheme__c;
                            this.BookingFormDetails.selectedScheme = BFresult.SchemesName__c;
                            this.BookingFormDetails.ExtraDiscountAmount = BFresult.Extra_Discount_Amount__c;
                            this.BookingFormDetails.ndsDiscountAmount = BFresult.nds_Discount_Amount__c;
                            this.BookingFormDetails.sdsDiscountAmount = BFresult.sds_Discount_Amount__c;
                            this.BookingFormDetails.SDSApprovelStatus = BFresult.SDS_Approvel_Status__c;
                            this.BookingFormDetails.SDSApprovelComments = BFresult.SDS_Approvel_Comments__c;
                            this.BookingFormDetails.encash = BFresult.encash__c;
                            this.BookingFormDetails.SchemeAmount = BFresult.EnCash_Amount__c;
                            this.BookingFormDetails.SourceValue = BFresult.BookingSource__c;
                            this.isChannel = false;
                            this.isreferenceEmp = false;
                            this.isCustomer = false;
                            this.isexistingcustomer = false;

                            if (BFresult.BookingSource__c == 'Existing Customer') {
                                this.isexistingcustomer = true;
                            } else if (BFresult.BookingSource__c == 'Channel Partner') {
                                this.isChannel = true;
                            } else if (BFresult.BookingSource__c == 'Reference by Employe') {
                                this.isreferenceEmp = true;
                            } else if (BFresult.BookingSource__c == 'Reference by Custome') {
                                this.isCustomer = true;
                            }

                            this.BookingFormDetails.SourceExistCustomerDiscount = BFresult.Exist_Customer_Discount__c;
                            this.BookingFormDetails.SourceChannelPartnerCode = BFresult.Channel_Partner_Code__c;
                            this.BookingFormDetails.SourceChannelPartnerName = BFresult.Channel_Partner_Name__c;
                            this.BookingFormDetails.SourceReferenceEmployeeCode = BFresult.Reference_Employee_Code__c;
                            this.BookingFormDetails.SourceEmployeeName = BFresult.Source_Employee_Name__c;
                            this.BookingFormDetails.SourceEmployeeCompanyName = BFresult.Source_Employee_Company_Name__c;
                            this.BookingFormDetails.SourceCustomerCode = BFresult.Customer_Code__c;
                            this.BookingFormDetails.SourceCustomerName = BFresult.Customer_Name__c;
                            this.BookingFormDetails.SourceCustomerRelationName = BFresult.Customer_Relation__c;
                            this.BookingFormDetails.SourceFlatNo = BFresult.Source_Flat_No__c;
                            this.BookingFormDetails.SourceExiCustomerCode = BFresult.Exist_Customer_Code__c;
                            this.BookingFormDetails.SourceExiCustomerName = BFresult.Exist_Customer_Name__c;
                            this.BookingFormDetails.SourceExiCustomerRelationName = BFresult.Exist_Customer_Relation__c;
                            this.BookingFormDetails.SourceExiFlatNo = BFresult.Exist_Customer_Flat_No__c;
                            this.BookingFormDetails.SourceExiProjectName = BFresult.Exist_Customer_Project_Name__c;
                            this.BookingFormDetails.SourceProjectName = BFresult.Source_Project_Name__c;
                            this.BookingFormDetails.selectedPaymentType = BFresult.Payment_Schedule_Type__c;
                            if (BFresult.Payment_Schedule_Type__c != null && BFresult.Payment_Schedule_Type__c != '') {
                                if (BFresult.Payment_Schedule_Type__c == 'Flexible') {
                                    this.isHi5Payment = false;
                                    this.isFlexiblePayment = true;
                                } else {
                                    this.isHi5Payment = true;
                                    this.isFlexiblePayment = false;
                                }

                            }
                            this.BookingFormDetails.PaymentScheduleTotalAmount = BFresult.Payment_Sc_Total__c;
                            this.BookingFormDetails.PaymentSchedulepercentage = BFresult.Payment_Schedule_percentage__c;

                            if (this.BookingFormDetails.BookingFormId != null) {

                                getOtherApplicantRecord({
                                    BookingFormId: this.BookingFormDetails.BookingFormId
                                }).then(Oappresult => {
                                    for (let key in Oappresult) {
                                        const IndexVal = parseInt(key) + parseInt(1);
                                        this.OtherApplicantDetails.Id = Oappresult[key].Id;
                                        this.OtherApplicantDetails.index = IndexVal;
                                        this.OtherApplicantDetails.Salutation1 = Oappresult[key].Salutation__c;
                                        this.OtherApplicantDetails.FirstName1 = Oappresult[key].First_Name__c;
                                        this.OtherApplicantDetails.LastName1 = Oappresult[key].Last_Name__c;
                                        this.OtherApplicantDetails.Gender1 = Oappresult[key].Gender__c;
                                        //this.OtherApplicantDetails.Organization1 = Oappresult[key].Occupation__c;
                                        this.OtherApplicantDetails.Occupation1 = Oappresult[key].Occupation__c;
                                        this.OtherApplicantDetails.salutationr1Options = Oappresult[key].RSalutation__c;
                                        this.OtherApplicantDetails.FirstNamer1 = Oappresult[key].First_Namer__c;
                                        this.OtherApplicantDetails.LastNamer1 = Oappresult[key].Last_Namer__c;
                                        this.OtherApplicantDetails.DateofBirth1 = Oappresult[key].Date_of_Birth__c;
                                        this.OtherApplicantDetails.age1 = Oappresult[key].Age__c;
                                        this.OtherApplicantDetails.MaritalStatus1 = Oappresult[key].Marital_Status__c;
                                        this.OtherApplicantDetails.AnniversaryDate1 = Oappresult[key].Anniversary_Date__c;
                                        this.OtherApplicantDetails.Mobile1 = Oappresult[key].Mobile__c;
                                        this.OtherApplicantDetails.Email1 = Oappresult[key].Email__c;
                                        this.OtherApplicantDetails.PassportNo1 = Oappresult[key].Passport_No__c;
                                        this.OtherApplicantDetails.Validtill1 = Oappresult[key].Valid_till__c;
                                        this.OtherApplicantDetails.PanNo1 = Oappresult[key].Pan_No__c;
                                        this.OtherApplicantDetails.AadharNo1 = Oappresult[key].Aadhar_No__c;

                                        this.OtherApplicantDetailsJson.push(this.OtherApplicantDetails);
                                        this.OtherApplicantDetailsEmpty();


                                    }
                                    this.CheckOtherApplicentLimit();


                                }).catch(error => {

                                });

                                if (BFresult.Payment_Schedule_Type__c != null && BFresult.Payment_Schedule_Type__c != '') {
                                    getPaymentScheduleRecord({
                                        BookingFormId: this.BookingFormDetails.BookingFormId
                                    }).then(psresult => {
                                        this.PaymentScheduleMD = [];
                                        let i = 0;
                                        for (let key in psresult) {
                                            this.PaymentScheduleDetails.index = i++;
                                            this.PaymentScheduleDetails.Id = psresult[key].Id;
                                            this.PaymentScheduleDetails.Payment_Schedule_Type = psresult[key].Payment_Schedule_Type__c;
                                            this.PaymentScheduleDetails.Payment_Particulars = psresult[key].Payment_Particulars__c;
                                            this.PaymentScheduleDetails.Amount = psresult[key].Agreement_Value__c;
                                            this.PaymentScheduleDetails.Amount_In_Local_Currency = psresult[key].Amount__c;
                                            this.PaymentScheduleDetails.SerialNumber = psresult[key].S_No__c;

                                            this.PaymentScheduleMD.push(this.PaymentScheduleDetails);
                                            this.PaymentScheduleDetailsEmpty();
                                            //let Amount_In_Local_Currency = 0;
                                        }
                                    }).catch(error => {

                                    });
                                }

                            }
                            this.isNext = true;

                        }
                    })
                        .catch(error => {
                            this.showNotification('Error', 'An error occurred while fetching record details. Please try again later.', 'error');

                        });

                } else {

                    this.showNotification('No Records Found', 'No record details found based on the selected project, block, and unit.', 'info');

                }
            })
            .catch(error => {

                this.showNotification('Error', 'An error occurred while fetching record details. Please try again later.', 'error');

            });

    }

    handleToggleSection(event) {
        this.activeSectionMessage =
            'Open section name:  ' + event.detail.openSections;
    }



    //Tabs data   
    handleTabClick(event) {
        const selectedTab = event.currentTarget.dataset.tab;
        this.currentTab = selectedTab;

        // Reset all tab states
        this.isOtherApplicant = false;
        this.isAttachments = false;
        this.isScheme = false;
        this.isAccount = false;
        this.isOtherCharges = false;
        this.isSource = false;
        this.isPaymentSchedule = false;
        this.isOtherInfo = false;
        this.isRemarks = false;

        // Set the state for the clicked tab
        if (selectedTab === 'Other Applicants') {
            this.isOtherApplicant = true;
        } else if (selectedTab === 'Attachments') {
            this.isAttachments = true;
        } else if (selectedTab === 'Scheme') {
            this.isScheme = true;
        } else if (selectedTab === 'Account') {
            this.isAccount = true;
        } else if (selectedTab === 'Other Charges') {
            this.isOtherCharges = true;
        } else if (selectedTab === 'Source') {
            this.isSource = true;
        } else if (selectedTab === 'Payment Schedule') {
            this.isPaymentSchedule = true;
        } else if (selectedTab === 'Other Information') {
            this.isOtherInfo = true;
        } else if (selectedTab === 'Remarks') {
            this.isRemarks = true;
        }

        // Hide all tab contents initially
        const tabContents = this.template.querySelectorAll('.tabcontent');
        tabContents.forEach(content => {
            content.style.display = 'none';
        });

        // Show the selected tab content
        const selectedTabContent = this.template.querySelector(`.tabcontent[data-tab="${selectedTab}"]`);
        if (selectedTabContent) {
            selectedTabContent.style.display = 'block';
        }
    }

    BFonchangeHandler(event) {
        const inputName = event.target.name;
        const inputvalue = event.target.value;


        if (inputName == 'ProjectName') {
            this.BookingFormDetails.ProjectName = inputvalue;
        }
        if (inputName == 'Block') {
            this.BookingFormDetails.Block = inputvalue;
        }
        if (inputName == 'Unit') {
            this.BookingFormDetails.Unit = inputvalue;
        }
        if (inputName == 'Tower') {
            this.BookingFormDetails.Tower = inputvalue;
        }

        if (inputName == 'facing') {
            this.BookingFormDetails.facing = inputvalue;
        }

        if (inputName == 'sftArea') {
            this.BookingFormDetails.sftArea = inputvalue;
        }

        if (inputName == 'flatNo') {
            this.BookingFormDetails.flatNo = inputvalue;
        }

        if (inputName == 'unitType') {
            this.BookingFormDetails.unitType = inputvalue;
        }


        if (inputName == 'CarpetArea') {
            this.BookingFormDetails.CarpetArea = inputvalue;
        }

        if (inputName == 'Balcony') {
            this.BookingFormDetails.Balcony = inputvalue;
        }

        if (inputName == 'Utility') {
            this.BookingFormDetails.Utility = inputvalue;
        }

        if (inputName == 'ExternalWallArea') {
            this.BookingFormDetails.ExternalWallArea = inputvalue;
        }

        if (inputName == 'UDS') {
            this.BookingFormDetails.UDS = inputvalue;
        }

        if (inputName == 'SBUA') {
            this.BookingFormDetails.SBUA = inputvalue;
        }

        if (inputName == 'Saletype') {
            this.BookingFormDetails.Saletype = inputvalue;
        }

        if (inputName == 'BasicRate') {
            this.BookingFormDetails.BasicRate = inputvalue;
        }

        if (inputName == 'LumpSumAmount') {
            this.BookingFormDetails.LumpSumAmount = inputvalue;
        }

        if (inputName == 'CarParking') {
            this.BookingFormDetails.CarParking = inputvalue;
        }

        if (inputName == 'ExtraCarParkingNo') {
            this.BookingFormDetails.ExtraCarParkingNo = inputvalue;
        }


        if (inputName == 'ExtraCarParking') {
            this.BookingFormDetails.ExtraCarParking = inputvalue;
            this.GrandTotalHAndler();
        }

        if (inputName == 'OtherCharges') {
            this.BookingFormDetails.OtherCharges = inputvalue;
            this.GrandTotalHAndler();
        }



        if (inputName == 'EvCharges') {
            this.BookingFormDetails.EvCharges = inputvalue;
        }



        // if(inputName == 'GrandTotal'){
        //     this.BookingFormDetails.GrandTotal = inputvalue;
        // }

        if (inputName == 'selectedCustomerType') {
            this.BookingFormDetails.selectedCustomerType = inputvalue;

            /*if(inputvalue == 'Indian Resident'){
                this.AadharisRequired = true;
                this.PanisRequired = true;
                this.PAssportRequired = false;                
            }else if(inputvalue == 'Non-Indian Resident'){
                this.AadharisRequired = false;
                this.PanisRequired = false;
                this.PAssportRequired = true;
            }else{
                this.AadharisRequired = false;
                this.PanisRequired = false;
                this.PAssportRequired = false;
            } */
        }


        if (inputName == 'selectedSalutation') {
            this.BookingFormDetails.selectedSalutation = inputvalue;
        }

        if (inputName == 'FirstName') {
            this.BookingFormDetails.FirstName = inputvalue;
        }

        if (inputName == 'LastName') {
            this.BookingFormDetails.LastName = inputvalue;
        }

        if (inputName == 'Gender') {
            this.BookingFormDetails.Gender = inputvalue;
        }

        if (inputName == 'Organization') {
            this.BookingFormDetails.Organization = inputvalue;
        }

        if (inputName == 'Designation') {
            this.BookingFormDetails.Designation = inputvalue;
        }

        if (inputName == 'PassportNo') {
            this.BookingFormDetails.PassportNo = inputvalue;
        }

        if (inputName == 'Validtill') {
            this.BookingFormDetails.Validtill = inputvalue;
        }

        if (inputName == 'selectedProfession') {
            this.BookingFormDetails.selectedProfession = inputvalue;
        }

        if (inputName == 'selectedSalutationr') {
            this.BookingFormDetails.selectedSalutationr = inputvalue;
        }

        if (inputName == 'FirstNamer') {
            this.BookingFormDetails.FirstNamer = inputvalue;
        }

        if (inputName == 'LastNamer') {
            this.BookingFormDetails.LastNamer = inputvalue;
        }

        if (inputName == 'DateOfBirth') {
            this.BookingFormDetails.DateOfBirth = inputvalue;

            // finding the age with DateOfBirth field;
            let d1 = new Date(inputvalue);
            let d2 = new Date();

            let varAge = d2.getYear() - d1.getYear();

            if (d1.getUTCMonth() < d2.getUTCMonth()) {
                -varAge;

            } else if (d1.getUTCMonth() === d2.getUTCMonth()) {
                if (d1.getUTCDate() < d2.getUTCDate())
                    -varAge;
            }
            this.BookingFormDetails.age = varAge;

        }

        if (inputName == 'age') {
            this.BookingFormDetails.age = inputvalue;
        }

        if (inputName == 'Mobile') {
            this.BookingFormDetails.Mobile = inputvalue;
        }

        if (inputName == 'AlternativeMobile') {
            this.BookingFormDetails.AlternativeMobile = inputvalue;
        }

        if (inputName == 'TelRes') {
            this.BookingFormDetails.TelRes = inputvalue;
        }

        if (inputName == 'TelOffice') {
            this.BookingFormDetails.TelOffice = inputvalue;
        }

        if (inputName == 'Email') {
            this.BookingFormDetails.Email = inputvalue;
        }

        if (inputName == 'AlternativeEmail') {
            this.BookingFormDetails.AlternativeEmail = inputvalue;
        }


        if (inputName == 'selectedMaritalStatus') {
            this.BookingFormDetails.selectedMaritalStatus = inputvalue;
        }

        if (inputName == 'AnniversaryDate') {
            this.BookingFormDetails.AnniversaryDate = inputvalue;
        }

        if (inputName == 'PanNo') {
            this.BookingFormDetails.PanNo = inputvalue;
        }

        if (inputName == 'AadharNo') {

            let input = event.target.value;

            event.target.value = input.replace(/[^0-9\s]/g, '');
            if (input == "" || input == null) {
                this.Aadharcarvalidation = false;
            } else {
                if (event.target.value.length >= 12) {
                    this.Aadharcarvalidation = false;
                } else {
                    this.Aadharcarvalidation = true;
                }
            }

            this.BookingFormDetails.AadharNo = event.target.value;


        }
        
        if (inputName == 'SignthroughDigitalSignature') {
            this.BookingFormDetails.SignthroughDigitalSignature = event.target.checked;
        }

        if (inputName == 'presentStreet') {
            this.BookingFormDetails.presentStreet = inputvalue;
        }

        if (inputName == 'presentStreet2') {
            this.BookingFormDetails.presentStreet2 = inputvalue;
        }

        if (inputName == 'presentStreet3') {
            this.BookingFormDetails.presentStreet3 = inputvalue;
        }

        if (inputName == 'presentStreet4') {
            this.BookingFormDetails.presentStreet4 = inputvalue;
        }

        if (inputName == 'presentStreet5') {
            this.BookingFormDetails.presentStreet5 = inputvalue;
        }

        if (inputName == 'presentCity') {
            this.BookingFormDetails.presentCity = inputvalue;
        }

        if (inputName == 'selectedPresentState') {
            this.BookingFormDetails.selectedPresentState = inputvalue;
        }

        if (inputName == 'selectedPresentCountry') {
            this.BookingFormDetails.selectedPresentCountry = inputvalue;
        }

        if (inputName == 'presentPinCode') {
            this.BookingFormDetails.presentPinCode = inputvalue;
        }

        if (inputName == 'permanentStreet') {
            this.BookingFormDetails.permanentStreet = inputvalue;
        }

        if (inputName == 'permanentStreet2') {
            this.BookingFormDetails.permanentStreet2 = inputvalue;
        }

        if (inputName == 'permanentStreet3') {
            this.BookingFormDetails.permanentStreet3 = inputvalue;
        }

        if (inputName == 'permanentStreet4') {
            this.BookingFormDetails.permanentStreet4 = inputvalue;
        }

        if (inputName == 'permanentStreet5') {
            this.BookingFormDetails.permanentStreet5 = inputvalue;
        }

        if (inputName == 'permanentCity') {
            this.BookingFormDetails.permanentCity = inputvalue;
        }

        if (inputName == 'selectedPermanentState') {
            this.BookingFormDetails.selectedPermanentState = inputvalue;
        }

        if (inputName == 'selectedPermanentCountry') {
            this.BookingFormDetails.selectedPermanentCountry = inputvalue;
        }

        if (inputName == 'permanentPinCode') {
            this.BookingFormDetails.permanentPinCode = inputvalue;
        }


        if (inputName == 'AccountHolderName') {
            this.BookingFormDetails.AccountHolderName = inputvalue;
        }

        if (inputName == 'AccountNo') {
            this.BookingFormDetails.AccountNo = inputvalue;
        }

        if (inputName == 'NameofBank') {
            this.BookingFormDetails.NameofBank = inputvalue;
        }

        if (inputName == 'IFSCCode') {
            this.BookingFormDetails.IFSCCode = inputvalue;
        }

        if (inputName == 'BankBranch') {
            this.BookingFormDetails.BankBranch = inputvalue;
        }

        if (inputName == 'CampusFund') {
            this.BookingFormDetails.CampusFund = inputvalue;
        }

        if (inputName == 'AdvanceMaintenance') {
            this.BookingFormDetails.AdvanceMaintenance = inputvalue;
        }
        if (inputName == 'GSTonInstalments') {
            this.BookingFormDetails.GSTonInstalments = inputvalue;
        }

        if (inputName == 'StampDuty') {
            this.BookingFormDetails.StampDuty = inputvalue;
        }

        if (inputName == 'DocumentationCharges') {
            this.BookingFormDetails.DocumentationCharges = inputvalue;
        }

        if (inputName == 'OtherChargesIf') {
            this.BookingFormDetails.OtherChargesIf = inputvalue;
        }

        if (inputName == 'selectedServiceCategory') {
            this.BookingFormDetails.selectedServiceCategory = inputvalue;
        }

        if (inputName == 'selectedProfessionDetails') {
            this.BookingFormDetails.selectedProfessionDetails = inputvalue;
        }
        if (inputName == 'selectedAnnualIncome') {
            this.BookingFormDetails.selectedAnnualIncome = inputvalue;
        }

        if (inputName == 'selectedPaymentSource') {
            this.BookingFormDetails.selectedPaymentSource = inputvalue;
        }

        if (inputName == 'selectedPurchase') {
            this.BookingFormDetails.selectedPurchase = inputvalue;
        }

        if (inputName == 'selectedOtherProject') {
            this.BookingFormDetails.selectedOtherProject = inputvalue;
        }

        if (inputName == 'selectedLocation') {

            this.selectedLocation = inputvalue;
            this.BookingFormDetails.selectedLocationString = inputvalue.join(';');

        }

        if (inputName == 'selectedRemarks') {
            this.BookingFormDetails.selectedRemarks = inputvalue;
        }
        if (inputName == 'RemarksDescription') {
            this.BookingFormDetails.RemarksDescription = inputvalue;
        }

        if (inputName == 'RemarksDescription') {
            this.BookingFormDetails.RemarksDescription = inputvalue;
        }

        if (inputName == 'Declaration') {
            this.BookingFormDetails.Declaration = event.target.checked;
        }

        if (inputName == 'selectedPaymentType') {
            this.BookingFormDetails.selectedPaymentType = inputvalue;
            if (inputvalue == 'Flexible') {
                this.isFlexiblePayment = true;
                this.isHi5Payment = false;
                this.PaymentScheduleMD = [];
                this.BookingFormDetails.PaymentScheduleTotalAmount = 0;
                this.BookingFormDetails.PaymentSchedulepercentage = 0;
                this.createRow();
            } else {
                this.selectedPaymentDetails(inputvalue);
            }

        }



        // schema 

        if (inputName == 'NDSORSDS') {
            this.BookingFormDetails.NDSORSDS = event.target.checked;
            if (this.BookingFormDetails.NDSORSDS == false) {

                this.BookingFormDetails.DiscountAmount = null;
                this.BookingFormDetails.discount = 0;
                this.BookingFormDetails.ExtraDiscountAmount = 0;
                this.BookingFormDetails.ndsValue = null;
                this.BookingFormDetails.ndsDiscountAmount = 0;
                this.BookingFormDetails.sdsValue = null;
                this.BookingFormDetails.sdsDiscountAmount = 0;

                this.GrandTotalHAndler();

            }

        }
        if (inputName == 'ndsValue') {
            this.BookingFormDetails.ndsValue = inputvalue;
            this.NDSDiscountCheck(event);

        }
        if (inputName == 'sdsValue') {
            if (inputName != null && inputName != '') {
                this.BookingFormDetails.DiscountAmount = (parseInt(this.BookingFormDetails.ndsValue) + parseInt(this.BookingFormDetails.discount) + parseInt(inputvalue));

            }
            this.BookingFormDetails.sdsValue = inputvalue;

            this.SDSDiscountCheck(event);
        }

        if (inputName == 'useScheme') {
            this.BookingFormDetails.useScheme = event.target.checked;
        }

        if (inputName == 'selectedScheme') {
            this.BookingFormDetails.selectedScheme = inputvalue;
        }


        if (inputName == 'encash') {
            this.BookingFormDetails.encash = event.target.checked;

            if (event.target.checked && (this.BookingFormDetails.selectedScheme != '0' && this.BookingFormDetails.selectedScheme != null)) {

                var SchemaDetails = this.SchemaFullDetails;

                SchemaDetails.forEach((values) => {
                    if (this.BookingFormDetails.selectedScheme == values.Description__c) {
                        this.BookingFormDetails.SchemeAmount = values.Net_Value_in_Doccument_Currency__c;

                    }
                });
            } else {
                this.BookingFormDetails.SchemeAmount == '0';
            }

            this.GrandTotalHAndler()

        }

        if (inputName == 'SourceValue') {
            this.BookingFormDetails.SourceValue = inputvalue;

            this.isexistingcustomer = false;
            this.isChannel = false;
            this.isreferenceEmp = false;
            this.isCustomer = false;



            let BookingSourceId;
            if (inputvalue.includes('Existing Customer')) {
                this.isexistingcustomer = true;
                let SCresult = this.SourceFullDetails;
                SCresult.forEach((values) => {
                    if (values.Source_Type__c == inputvalue) {
                        BookingSourceId = values.Id;
                    }

                });

                // console.log("BookingSourceId"+BookingSourceId);

                if (BookingSourceId != '' && this.BookingFormDetails.ProjectName) {
                    getLoyaltyBonusList({
                        BokingFormSourceId: BookingSourceId, selectedProject: this.BookingFormDetails.ProjectName
                    })
                        .then(result => {
                            console.log('result' + result);
                            if (result.length > 0) {

                                let GrandTotal = this.BookingFormDetails.GrandTotal;
                                let Percentage__c = result[0].Percentage__c;
                                let minloyalty_bonus = result[0].Loyalty_Bonus__c;

                                let getPerecentageVal = GrandTotal * (Percentage__c / 100);
                                //  let getPerecentageVal = 200000;
                                if (getPerecentageVal < minloyalty_bonus) {
                                    this.BookingFormDetails.SourceExistCustomerDiscount = getPerecentageVal;
                                } else {
                                    this.BookingFormDetails.SourceExistCustomerDiscount = minloyalty_bonus;
                                }
                                this.GrandTotalHAndler();



                            }
                        })
                        .catch(error => {
                            const event = new ShowToastEvent({
                                title: 'Error',
                                message: 'An error occurred while fetching record details. Please try again later.',
                                variant: 'error'
                            });
                            this.dispatchEvent(event);

                        });

                } else {
                    //console.log('else');
                    this.BookingFormDetails.SourceExistCustomerDiscount = '0';
                }



                this.BookingFormDetails.SourceChannelPartnerCode = '';
                this.BookingFormDetails.SourceChannelPartnerName = '';
                this.BookingFormDetails.SourceReferenceEmployeeCode = '';
                this.BookingFormDetails.SourceEmployeeName = '';
                this.BookingFormDetails.SourceEmployeeCompanyName = '';
                this.BookingFormDetails.SourceCustomerCode = '';
                this.BookingFormDetails.SourceCustomerName = '';
                this.BookingFormDetails.SourceCustomerRelationName = '';
                this.BookingFormDetails.SourceFlatNo = '';
                this.BookingFormDetails.SourceProjectName = '';


            } else if (inputvalue == 'Channel Partner') {
                this.BookingFormDetails.SourceExistCustomerDiscount = '0';
                this.BookingFormDetails.SourceReferenceEmployeeCode = '';
                this.BookingFormDetails.SourceEmployeeName = '';
                this.BookingFormDetails.SourceEmployeeCompanyName = '';
                this.BookingFormDetails.SourceCustomerCode = '';
                this.BookingFormDetails.SourceCustomerName = '';
                this.BookingFormDetails.SourceCustomerRelationName = '';
                this.BookingFormDetails.SourceFlatNo = '';
                this.BookingFormDetails.SourceProjectName = '';

                this.isChannel = true;
            } else if (inputvalue == 'Reference by Employe') {
                this.BookingFormDetails.SourceExistCustomerDiscount = '0';
                this.BookingFormDetails.SourceChannelPartnerCode = '';
                this.BookingFormDetails.SourceChannelPartnerName = '';
                this.BookingFormDetails.SourceCustomerCode = '';
                this.BookingFormDetails.SourceCustomerName = '';
                this.BookingFormDetails.SourceCustomerRelationName = '';
                this.BookingFormDetails.SourceFlatNo = '';
                this.BookingFormDetails.SourceProjectName = '';


                this.isreferenceEmp = true;
            } else if (inputvalue == 'Reference by Custome') {
                this.BookingFormDetails.SourceExistCustomerDiscount = '0';
                this.BookingFormDetails.SourceChannelPartnerCode = '';
                this.BookingFormDetails.SourceChannelPartnerName = '';
                this.BookingFormDetails.SourceReferenceEmployeeCode = '';
                this.BookingFormDetails.SourceEmployeeName = '';
                this.BookingFormDetails.SourceEmployeeCompanyName = '';

                this.isCustomer = true;
            } else {
                this.BookingFormDetails.SourceExistCustomerDiscount = '0';
                this.BookingFormDetails.SourceChannelPartnerCode = '';
                this.BookingFormDetails.SourceChannelPartnerName = '';
                this.BookingFormDetails.SourceReferenceEmployeeCode = '';
                this.BookingFormDetails.SourceEmployeeName = '';
                this.BookingFormDetails.SourceEmployeeCompanyName = '';
                this.BookingFormDetails.SourceCustomerCode = '';
                this.BookingFormDetails.SourceCustomerName = '';
                this.BookingFormDetails.SourceCustomerRelationName = '';
                this.BookingFormDetails.SourceFlatNo = '';
                this.BookingFormDetails.SourceProjectName = '';
            }

            this.GrandTotalHAndler();
        }


        if (inputName == 'SourceExiCustomerCode') {
            this.BookingFormDetails.SourceExiCustomerCode = inputvalue;
        }

        if (inputName == 'SourceExiCustomerName') {
            this.BookingFormDetails.SourceExiCustomerName = inputvalue;
        }

        if (inputName == 'SourceExiCustomerRelationName') {
            this.BookingFormDetails.SourceExiCustomerRelationName = inputvalue;
        }

        if (inputName == 'SourceExiFlatNo') {
            this.BookingFormDetails.SourceExiFlatNo = inputvalue;
        }

        if (inputName == 'SourceExiProjectName') {
            this.BookingFormDetails.SourceExiProjectName = inputvalue;
        }


        if (inputName == 'SourceChannelPartnerCode') {
            this.BookingFormDetails.SourceChannelPartnerCode = inputvalue;
        }

        if (inputName == 'SourceChannelPartnerName') {
            this.BookingFormDetails.SourceChannelPartnerName = inputvalue;
        }

        if (inputName == 'SourceReferenceEmployeeCode') {
            this.BookingFormDetails.SourceReferenceEmployeeCode = inputvalue;
        }

        if (inputName == 'SourceEmployeeName') {
            this.BookingFormDetails.SourceEmployeeName = inputvalue;
        }

        if (inputName == 'SourceEmployeeCompanyName') {
            this.BookingFormDetails.SourceEmployeeCompanyName = inputvalue;
        }

        if (inputName == 'SourceCustomerCode') {
            this.BookingFormDetails.SourceCustomerCode = inputvalue;
        }

        if (inputName == 'SourceCustomerName') {
            this.BookingFormDetails.SourceCustomerName = inputvalue;
        }
        if (inputName == 'SourceCustomerRelationName') {
            this.BookingFormDetails.SourceCustomerRelationName = inputvalue;
        }

        if (inputName == 'SourceFlatNo') {
            this.BookingFormDetails.SourceFlatNo = inputvalue;
        }
        if (inputName == 'SourceProjectName') {
            this.BookingFormDetails.SourceProjectName = inputvalue;
        }

        if (inputName == 'DiscountAmount') {

            if (inputvalue != null && inputvalue != '') {
                //console.log('hello');                
                this.BookingFormDetails.DiscountAmount = inputvalue;
                let GivenOrginalBasePrice = 0;
                let BFBasicRate = 0;
                if (this.BookingFormDetails.OrginalBasePrice != '' && this.BookingFormDetails.OrginalBasePrice != null) {
                    GivenOrginalBasePrice = this.BookingFormDetails.OrginalBasePrice;
                } else {
                    GivenOrginalBasePrice = 0;
                }

                if (this.BookingFormDetails.BasicRate != '' && this.BookingFormDetails.BasicRate != null) {
                    BFBasicRate = this.BookingFormDetails.BasicRate;
                } else {
                    BFBasicRate = 0;
                }

                //console.log('GivenOrginalBasePrice  '+GivenOrginalBasePrice);
                // console.log('BFBasicRate  '+BFBasicRate);

                let extraCostingAmount = (parseInt(BFBasicRate) - parseInt(GivenOrginalBasePrice));
                console.log('BFBasicRate' + BFBasicRate);
                console.log('GivenOrginalBasePrice' + GivenOrginalBasePrice);
                console.log('extraCostingAmount  ' + extraCostingAmount);

                this.BookingFormDetails.extraBasePrice = extraCostingAmount;
                console.log('SalesNDsMaXDiscount ' + this.SalesNDsMaXDiscount);
                let salesfixedndsdiscountamount = parseInt(this.SalesNDsMaXDiscount);
                let SdsAmount = 0;
                if (inputvalue > salesfixedndsdiscountamount) {
                    //console.log("if "+inputvalue+' - '+salesfixedndsdiscountamount);
                    console.log('extraCostingAmount ' + extraCostingAmount);
                    let Salesdiscountcal = parseInt(extraCostingAmount) + parseInt(salesfixedndsdiscountamount);
                    console.log('Salesdiscountcal    ' + Salesdiscountcal);
                    if (inputvalue > extraCostingAmount) {
                        //console.log('if' +inputvalue +' - '+ Salesdiscountcal);
                        this.BookingFormDetails.discount = parseInt(extraCostingAmount);
                        let ndslimitexide = parseInt(inputvalue) - parseInt(extraCostingAmount);
                        if (ndslimitexide > salesfixedndsdiscountamount) {
                            this.BookingFormDetails.ndsValue = salesfixedndsdiscountamount;
                            this.BookingFormDetails.sdsValue = parseInt(inputvalue) - (parseInt(extraCostingAmount) + parseInt(salesfixedndsdiscountamount));
                        } else {
                            this.BookingFormDetails.ndsValue = ndslimitexide;
                            this.BookingFormDetails.sdsValue = 0;
                        }

                    }
                    else {
                        //console.log('else' +inputvalue +' - '+ Salesdiscountcal);
                        this.BookingFormDetails.discount = inputvalue;
                        this.BookingFormDetails.ndsValue = 0;
                        this.BookingFormDetails.sdsValue = 0;
                    }

                    // this.BookingFormDetails.ndsValue = parseInt(inputvalue)- (parseInt(extraCostingAmount)+parseInt(salesfixedndsdiscountamount));


                } else if (extraCostingAmount == 0) {
                    console.log("hello" + inputvalue + " " + salesfixedndsdiscountamount);
                    this.BookingFormDetails.discount = 0;
                    this.BookingFormDetails.ndsValue = inputvalue;
                    this.BookingFormDetails.sdsValue = 0;
                } else {
                    //console.log("else "+inputvalue+' - '+salesfixedndsdiscountamount);
                    this.BookingFormDetails.discount = inputvalue;
                    this.BookingFormDetails.ndsValue = 0;
                    this.BookingFormDetails.sdsValue = 0;
                }


                this.BookingFormDetails.ExtraDiscountAmount = (parseInt(this.BookingFormDetails.discount) * parseInt(this.BookingFormDetails.sftArea));

                this.BookingFormDetails.ndsDiscountAmount = (parseInt(this.BookingFormDetails.ndsValue) * parseInt(this.BookingFormDetails.sftArea));
                this.BookingFormDetails.sdsDiscountAmount = (parseInt(this.BookingFormDetails.sdsValue) * parseInt(this.BookingFormDetails.sftArea));

                //this.GrandTotalHAndler();
                this.GrandTotalHAndler();




            }
        }



        this.BookingFormValidation(event);







    }


    NDSDiscountCheck(event) {
        let fieldLabel = event.target.label;

        if (this.BookingFormDetails.ndsValue != '' && this.BookingFormDetails.ndsValue != null) {

            CheckNdsDiscount({ selectedProject: this.BookingFormDetails.ProjectName })
                .then(result => {


                    if (result.length > 0) {

                        if (this.BookingFormDetails.ndsValue > result[0].Amount_in_Local_Currency__c) {
                            let fieldErrorMsg = "NDS Discount Amount should not be more than " + result[0].Amount_in_Local_Currency__c + " .";
                            //console.log('greater then');
                            alert("Error" + fieldErrorMsg);
                            this.BookingFormDetails.ndsValue = '0';
                            this.BookingFormDetails.ndsDiscountAmount = (parseInt(this.BookingFormDetails.ndsValue) * parseInt(this.BookingFormDetails.sftArea));
                            this.GrandTotalHAndler();
                        } else {

                            this.BookingFormDetails.ndsDiscountAmount = (parseInt(this.BookingFormDetails.ndsValue) * parseInt(this.BookingFormDetails.sftArea));
                            this.GrandTotalHAndler();
                        }

                    }
                    else {

                        this.BookingFormDetails.ndsDiscountAmount = (parseInt(this.BookingFormDetails.ndsValue) * parseInt(this.BookingFormDetails.sftArea));
                        this.GrandTotalHAndler();
                    }
                })
                .catch(error => {

                    this.showNotification('Error', 'An error occurred while fetching record details. Please try again later.', 'error');



                });

        }

    }

    SDSDiscountCheck() {

        //let SDSDiscountTotalval = (parseInt(this.BookingFormDetails.GrandTotal) - (parseInt(this.BookingFormDetails.sdsValue)* parseInt(this.BookingFormDetails.sftArea))) ;

        // this.BookingFormDetails.sdsDiscountTotal = SDSDiscountTotalval;
        this.BookingFormDetails.sdsDiscountAmount = (parseInt(this.BookingFormDetails.sdsValue) * parseInt(this.BookingFormDetails.sftArea));

        this.GrandTotalHAndler();
    }


    selectedPaymentDetails(paymenttype) {
        // console.log('paymenttype',paymenttype);

        getPaymentScheduleDetails({
            selectedProject: this.BookingFormDetails.ProjectName,
            paymentScheduleType: this.BookingFormDetails.selectedPaymentType

        })
            .then(PSresult => {
                // console.log('result getpayment',PSresult);
                this.isHi5Payment = true;
                this.isFlexiblePayment = false;
                // console.log("this.PaymentScheduleMD",this.PaymentScheduleMD);

                this.PaymentScheduleMD = [];
                let PaymentScheduleTotalAmountjs = 0;
                let PaymentSchedulepercentagejs = 0;

                let tokenAmountval = 0;

                for (let key in PSresult) {
                    // console.log(PSresult[key].Serial_Number__c);
                    this.PaymentScheduleDetails.Payment_Schedule_Type = PSresult[key].Payment_Schedule_Type__c;
                    this.PaymentScheduleDetails.Payment_Particulars = PSresult[key].Payment_Particulars__c;
                    this.PaymentScheduleDetails.Amount = PSresult[key].Amount__c;
                    this.PaymentScheduleDetails.SerialNumber = PSresult[key].S_No__c;
                    let Amount_In_Local_Currency = 0;
                    if (PSresult[key].Amount__c != '' && PSresult[key].Amount__c != null) {
                        if (PSresult[key].Serial_Number__c == 1) {
                            Amount_In_Local_Currency = (parseInt(this.PaymentSchedulepercentagecalculator(PSresult[key].Amount__c)) - tokenAmountval);
                            PaymentSchedulepercentagejs = parseInt(PaymentSchedulepercentagejs) + parseInt(PSresult[key].Amount__c);
                            this.PaymentScheduleDetails.Amount_In_Local_Currency = Amount_In_Local_Currency;
                        } else {
                            Amount_In_Local_Currency = this.PaymentSchedulepercentagecalculator(PSresult[key].Amount__c);
                            PaymentSchedulepercentagejs = parseInt(PaymentSchedulepercentagejs) + parseInt(PSresult[key].Amount__c);
                            this.PaymentScheduleDetails.Amount_In_Local_Currency = this.PaymentSchedulepercentagecalculator(PSresult[key].Amount__c);

                        }
                    } else {

                        tokenAmountval = PSresult[key].Amount_In_Local_Currency__c;
                        Amount_In_Local_Currency = PSresult[key].Amount_In_Local_Currency__c;
                        this.PaymentScheduleDetails.Amount_In_Local_Currency = PSresult[key].Amount_In_Local_Currency__c;
                    }

                    PaymentScheduleTotalAmountjs = PaymentScheduleTotalAmountjs + Amount_In_Local_Currency;



                    this.PaymentScheduleMD.push(this.PaymentScheduleDetails);
                    this.PaymentScheduleDetailsEmpty();

                };

                this.BookingFormDetails.PaymentScheduleTotalAmount = PaymentScheduleTotalAmountjs;
                this.BookingFormDetails.PaymentSchedulepercentage = PaymentSchedulepercentagejs;

                //console.log("this.PaymentScheduleMD",JSON.stringify(this.PaymentScheduleMD));





            })
            .catch(error => {


                this.showNotification('Error', 'An error occurred while fetching record details. Please try again later.', 'error');


            });



    }


    validateAadharNumber(aadharNumber) {
        const aadharPattern = /^\d{4} \d{4} \d{4}$/;
        return aadharPattern.test(aadharNumber);
    }


    PaymentSchedulepercentagecalculator(Amount) {
        let PercentageAmount = parseInt(Amount);
        let GrandTotal = parseInt(this.BookingFormDetails.GrandTotal);
        let getPerecentageVal = GrandTotal * (PercentageAmount / 100);

        return getPerecentageVal;

    }

    /*SchemaCalculation(){
        let areasft = this.BookingFormDetails.sftArea;
        let ndsValue = this.BookingFormDetails.ndsValue;
        let sdsValue = this.BookingFormDetails.sdsValue;
        let GDTotal = this.BookingFormDetails.GrandTotal;
        let NDSAvalareasft = 0;
        let SDSAvalareasft = 0;        
        let forumala;
        let gd = this.GrandTotalHAndler();
        console.log('gd',gd);
        if(ndsValue != '' && ndsValue != null){
            NDSAvalareasft = (parseInt(ndsValue)* parseInt(areasft))
        }

        if(sdsValue != '' && sdsValue != null){
            SDSAvalareasft = (parseInt(sdsValue)* parseInt(areasft))
        }

        forumala = (GDTotal - NDSAvalareasft - SDSAvalareasft);

        console.log('forumala',forumala);


    }

    */

    handleSameAddress(event) {
        var isChecked = event.target.checked;
        if (isChecked == true) {
            this.BookingFormDetails.SameasPresentAddress = isChecked;
            this.BookingFormDetails.permanentStreet = this.BookingFormDetails.presentStreet;
            this.BookingFormDetails.permanentStreet2 = this.BookingFormDetails.presentStreet2;
            this.BookingFormDetails.permanentStreet3 = this.BookingFormDetails.presentStreet3;
            this.BookingFormDetails.permanentStreet4 = this.BookingFormDetails.presentStreet4;
            this.BookingFormDetails.permanentStreet5 = this.BookingFormDetails.presentStreet5;
            this.BookingFormDetails.permanentCity = this.BookingFormDetails.presentCity;
            this.BookingFormDetails.selectedPermanentState = this.BookingFormDetails.selectedPresentState;
            this.BookingFormDetails.selectedPermanentCountry = this.BookingFormDetails.selectedPresentCountry;
            this.BookingFormDetails.permanentPinCode = this.BookingFormDetails.presentPinCode;

        } else {
            this.BookingFormDetails.SameasPresentAddress = isChecked;
            this.BookingFormDetails.permanentStreet = '';
            this.BookingFormDetails.permanentStreet2 = '';
            this.BookingFormDetails.permanentStreet3 = '';
            this.BookingFormDetails.permanentStreet4 = '';
            this.BookingFormDetails.permanentStreet5 = '';
            this.BookingFormDetails.permanentCity = '';
            this.BookingFormDetails.selectedPermanentState = '';
            this.BookingFormDetails.selectedPermanentCountry = '';
            this.BookingFormDetails.permanentPinCode = '';

        }

    }



    handleSaveAsDraft(event) {



        //this.BookingFormValidation(event);
        //if(this.BookingFormInputFieldValidation == false && this.BookingFormComboFieldValidation == false){
        console.log(this.BookingFormInputFieldValidation);
        console.log(this.BookingFormComboFieldValidation);
        console.log(this.Aadharcarvalidation);


        if (this.Aadharcarvalidation == false) {
            this.BookingFormDetails.Booking_Form_Status = 'Draft Save';
            const wrapperDataJSon = JSON.stringify(this.BookingFormDetails);
            const OtherApplicentWP = JSON.stringify(this.OtherApplicantDetailsJson);
            const PaymentScheduleWP = JSON.stringify(this.PaymentScheduleMD);
            //console.log("testing");
            console.log('wrapperDataJSon', wrapperDataJSon);
            console.log('files', JSON.stringify(this.filesToUpload));
            console.log('OtherApplicentWP', OtherApplicentWP);
            console.log('PaymentScheduleWP', PaymentScheduleWP);
            //console.log("OtherApplicentWP",OtherApplicentWP);

            this.isDraftSaving = true; // Disable the button during save

            // Call Apex method
            createBookingForm({ wrapperBookingFormData: wrapperDataJSon, files: JSON.stringify(this.filesToUpload), OtherApplicentWP: OtherApplicentWP, PaymentScheduleWP: PaymentScheduleWP })
                .then(result => {
                    this.showNotification('Booking Form ', 'Draft was successfully saved.', 'success');
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result.Id,
                            objectApiName: 'Booking_Form__c',
                            actionName: 'view'
                        },
                    });
                })
                .catch(error => {
                    this.showNotification('Booking Form', error.body.message, 'error');
                    this.error = error;
                    console.error('Error:', error);


                })
                .finally(() => {
                    this.isDraftSaving = false; // Re-enable the button after save process
                });


        }
        /*console.log(this.BookingFormDetails.ExtraCarParking);
        console.log('final booking',JSON.stringify(this.BookingFormDetails));
        

            */

    }


    handleSave(event) {
        // Prevent multiple clicks while saving
        /*if (this.isSaving) {
            return;
        }*/

        this.BookingFormValidation(event);
        if (this.BookingFormInputFieldValidation == false && this.BookingFormComboFieldValidation == false && this.Aadharcarvalidation == false) {
            this.BookingFormDetails.Booking_Form_Status = 'Final Submit';
            const wrapperDataJSon = JSON.stringify(this.BookingFormDetails);
            const OtherApplicentWP = JSON.stringify(this.OtherApplicantDetailsJson);
            const PaymentScheduleWP = JSON.stringify(this.PaymentScheduleMD);

            // Disable the save button
            this.isSaving = true;

            // Call Apex method
            createBookingForm({ wrapperBookingFormData: wrapperDataJSon, files: JSON.stringify(this.filesToUpload), OtherApplicentWP: OtherApplicentWP, PaymentScheduleWP: PaymentScheduleWP })
                .then(result => {
                    //console.log('Booking Form Created:', result);

                    this.showNotification('Booking Form ', 'The Booking Form was successfully saved.', 'success');
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result.Id,
                            objectApiName: 'Booking_Form__c',
                            actionName: 'view'
                        },
                    });
                })
                .catch(error => {
                    this.error = error;
                    console.error('Error:', error);
                    this.showNotification('Booking Form', error.body.message, 'error');

                })
                .finally(() => {
                    // Re-enable the save button
                    this.isSaving = false;
                });
        }
    }

    BookingFormValidation(event) {


        let fieldErrorMsg = "Please Enter the ";
        this.BookingFormInputFieldValidation = false;
        this.BookingFormComboFieldValidation = false;
        //let FieldTypeErrormsg = 

        this.template.querySelectorAll("lightning-input").forEach(item => {
            let fieldValue = item.value;
            let fieldLabel = item.label;
            let fieldRequired = item.required;
            let FiledName = item.name;

            if (fieldValue == '' && fieldRequired) {
                this.BookingFormInputFieldValidation = true;
                item.setCustomValidity(fieldErrorMsg + ' ' + fieldLabel);
            } else {
                if (FiledName == 'AadharNo') {
                    if (FiledName == 'AadharNo') {
                        let errormsg = " Please Enter 14  Digits Of " + fieldLabel;
                        if (fieldValue.length > 14) {
                            this.BookingFormInputFieldValidation = true;
                            item.setCustomValidity(errormsg);
                        } else {
                            item.setCustomValidity("");
                        }
                    }
                } else {
                    item.setCustomValidity("");
                }

            }

            item.reportValidity();
        });




        let fieldErrorMsge = "Please select the";
        this.template.querySelectorAll("lightning-combobox").forEach(item => {
            let fieldValue = item.value;
            let fieldLabel = item.label;
            let fieldRequired = item.required;
            if (!fieldValue && fieldRequired) {
                this.BookingFormComboFieldValidation = true;
                item.setCustomValidity(fieldErrorMsge + ' ' + fieldLabel);
            }
            else {

                item.setCustomValidity("");
            }
            item.reportValidity();
        });


        //console.log(this.BookingFormInputFieldValidation +""+ this.BookingFormComboFieldValidation);




    }

    handleFileUploaded(event) {
        const files = event.target.files;

        for (let i = 0; i < files.length; i++) {
            const file = files[i];

            // Check if the file is a PDF
            if (file.type === 'application/pdf') {
                const reader = new FileReader();
                reader.onloadend = () => {
                    this.filesToUpload.push({
                        fileName: file.name,
                        fileContent: reader.result.split(',')[1] // Base64 content
                    });
                };
                reader.readAsDataURL(file);
            } else {
                // You might want to notify the user about unsupported file types
                alert('Only PDF files are allowed.');
            }
        }
    }
    removeReceiptImage(event) {
        const index = event.target.dataset.id;
        this.filesToUpload.splice(index, 1);
        this.filesToUpload = [...this.filesToUpload]; // Refresh the UI by creating a new array reference
    }



    showModalBox() {
        this.isShowModal = true;
    }

    hideModalBox() {
        this.isShowModal = false;
        this.isApplicantEdit = false;
        this.OtherApplicantDetailsEmpty();
    }


    DeleteHandler(event) {
        let OtherApplicantDetailsarray = [];
        let deletingindex = event.currentTarget.dataset.id;
        for (let i = 0; i < this.OtherApplicantDetailsJson.length; i++) {
            let tempRecord = Object.assign({}, this.OtherApplicantDetailsJson[i]);
            if (parseInt(tempRecord.index) !== parseInt(deletingindex)) {
                OtherApplicantDetailsarray.push(tempRecord);
            }
        }
        for (let j = 0; j < OtherApplicantDetailsarray.length; j++) {
            OtherApplicantDetailsarray[j].index = parseInt(j) + parseInt(1);
        }
        this.OtherApplicantDetailsJson = OtherApplicantDetailsarray;
        this.CheckOtherApplicentLimit();
    }

    otherapplicantHandler(event) {
        this.handleKeyUp(event);
        const EventName = event.target.name;
        //console.log(event.target.value);

        if (EventName == 'OtherApplicentId') {
            this.OtherApplicantDetails.Id = event.target.value;
        }
        if (EventName == 'salutation1Options') {
            this.OtherApplicantDetails.Salutation1 = event.target.value;
        }

        if (EventName == 'FirstName1') {
            this.OtherApplicantDetails.FirstName1 = event.target.value;
        }

        if (EventName == 'LastName1') {
            this.OtherApplicantDetails.LastName1 = event.target.value;
        }

        if (EventName == 'selectedGender1') {
            this.OtherApplicantDetails.Gender1 = event.target.value;
        }

        if (EventName == 'Organization1') {
            this.OtherApplicantDetails.Organization1 = event.target.value;
        }

        if (EventName == 'selectedOccupation1') {
            this.OtherApplicantDetails.Occupation1 = event.target.value;
        }

        if (EventName == 'selectedSalutationr1') {
            this.OtherApplicantDetails.salutationr1Options = event.target.value;
        }

        if (EventName == 'FirstNamer1') {
            this.OtherApplicantDetails.FirstNamer1 = event.target.value;
        }

        if (EventName == 'LastNamer1') {
            this.OtherApplicantDetails.LastNamer1 = event.target.value;
        }

        if (EventName == 'DateofBirth1') {
            this.OtherApplicantDetails.DateofBirth1 = event.target.value;

            //this.BookingFormDetails.DateOfBirth = event.target.value;

            // finding the age with DateOfBirth field;
            let d1 = new Date(event.target.value);
            let d2 = new Date();

            let varAge = d2.getYear() - d1.getYear();
            //console.log( varAge );

            if (d1.getUTCMonth() < d2.getUTCMonth()) {
                -varAge;

            } else if (d1.getUTCMonth() === d2.getUTCMonth()) {
                if (d1.getUTCDate() < d2.getUTCDate())
                    -varAge;
            }
            this.OtherApplicantDetails.age1 = varAge;


        }

        // if (EventName == 'age1') {
        //     this.OtherApplicantDetails.age1 = event.target.value;

        // }

        if (EventName == 'MaritalStatus1') {
            this.OtherApplicantDetails.MaritalStatus1 = event.target.value;
        }

        if (EventName == 'AnniversaryDate1') {
            this.OtherApplicantDetails.AnniversaryDate1 = event.target.value;
        }

        if (EventName == 'Mobile1') {
            this.OtherApplicantDetails.Mobile1 = event.target.value;
        }

        if (EventName == 'Email1') {
            this.OtherApplicantDetails.Email1 = event.target.value;
        }

        if (EventName == 'PassportNo1') {
            this.OtherApplicantDetails.PassportNo1 = event.target.value;
        }

        if (EventName == 'Validtill1') {
            this.OtherApplicantDetails.Validtill1 = event.target.value;
        }

        if (EventName == 'PanNo1') {
            this.OtherApplicantDetails.PanNo1 = event.target.value;
        }

        if (EventName == 'AadharNo1') {

            const input = event.target.value;
            event.target.value = input.replace(/[^0-9\s]/g, '');

            if (event.target.value.length >= 12) {
                this.OtherApplicentAadharcardvalidation = false;
            } else {
                this.OtherApplicentAadharcardvalidation = true;
            }


            //this.BookingFormDetails.AadharNo = event.target.value;

            this.OtherApplicantDetails.AadharNo1 = event.target.value;
        }

    }

    handleKeyUp(event) {
        let fieldLabel = event.target.label;
        let fieldErrorMsg = "Please Enter the";
        let isrequired = event.currentTarget.required;
        if (isrequired) {
            if (event.target.value == "" || event.target.value == null) {
                event.currentTarget.setCustomValidity(fieldErrorMsg + ' ' + fieldLabel);
                event.currentTarget.reportValidity();
            } else {
                event.currentTarget.setCustomValidity("");
                event.currentTarget.reportValidity();
            }

        }
    }

    handlesaveaddOtherapplicant(event) {

        this.OtherApplicantValidation();


        if (this.OtherApplicentInputFieldValidation == false && this.OtherApplicentComboFieldValidation == false && this.OtherApplicentAadharcardvalidation == false) {
            if (this.OtherApplicantDetailsJson.length > 0) {
                this.OtherApplicantDetails.index = parseInt(this.OtherApplicantDetailsJson[this.OtherApplicantDetailsJson.length - 1].index) + parseInt(1);
            } else {
                this.OtherApplicantDetails.index = 1;
            }
            this.OtherApplicantDetailsJson.push(this.OtherApplicantDetails);
            this.OtherApplicantDetailsEmpty();
            this.hideModalBox();
            this.CheckOtherApplicentLimit();
        }



    }

    OtherApplicantValidation() {
        // Select the modal content div
        const modalContent = this.template.querySelector('.modal-content-id-1');
        let fieldErrorMsg = "Please Enter the ";
        this.OtherApplicentInputFieldValidation = false;
        this.OtherApplicentComboFieldValidation = false;

        //console.log('modalContent',modalContent);


        // Select all lightning-input elements within the modal content
        const inputElements = modalContent.querySelectorAll('lightning-input');
        if (inputElements.length === 0) {
            //console.error('No lightning-input elements found.');
            return;
        }
        inputElements.forEach(item => {
            let fieldValue = item.value;
            let fieldLabel = item.label;
            let fieldRequired = item.required;
            //console.log('hello ' + fieldValue + " _ " + fieldLabel);
            if (fieldValue === '' && fieldRequired) {
                this.OtherApplicentInputFieldValidation = true;
                item.setCustomValidity(fieldErrorMsg + ' ' + fieldLabel);
            } else {
                item.setCustomValidity("");
            }
        });
        // Call reportValidity to display validation messages
        inputElements.forEach(item => {
            item.reportValidity();
        });


        // Select all lightning-combobox elements within the modal content
        let fieldselectErrorMsge = "Please select the";
        const inputdropdownElements = modalContent.querySelectorAll('lightning-combobox');
        if (inputdropdownElements.length === 0) {
            console.error('No lightning-input elements found.');
            return;
        }
        inputdropdownElements.forEach(item => {
            let fieldValue = item.value;
            let fieldLabel = item.label;
            let fieldRequired = item.required;
            if (fieldValue === '' && fieldRequired) {
                this.OtherApplicentComboFieldValidation = true;
                item.setCustomValidity(fieldselectErrorMsge + ' ' + fieldLabel);
            } else {
                item.setCustomValidity("");
            }
        });
        // Call reportValidity to display validation messages
        inputdropdownElements.forEach(item => {
            item.reportValidity();
        });
    }

    CheckOtherApplicentLimit() {
        //console.log("this.OtherApplicantDetailsJson",this.OtherApplicantDetailsJson.length);

        if (this.OtherApplicantDetailsJson.length >= 4) {
            this.OtherApplicentLimitexceeded = true;
        } else {
            this.OtherApplicentLimitexceeded = false;
        }
    }

    EditHandler(event) {
        this.isApplicantEdit = true;
        //console.log(event.currentTarget.dataset.id);
        const IndexVal = parseInt(event.currentTarget.dataset.id) - parseInt(1);

        this.OtherApplicantDetails.index = event.currentTarget.dataset.id;
        this.OtherApplicantDetails.Id = this.OtherApplicantDetailsJson[IndexVal].Id;
        this.OtherApplicantDetails.Salutation1 = this.OtherApplicantDetailsJson[IndexVal].Salutation1;
        this.OtherApplicantDetails.FirstName1 = this.OtherApplicantDetailsJson[IndexVal].FirstName1;
        this.OtherApplicantDetails.LastName1 = this.OtherApplicantDetailsJson[IndexVal].LastName1;
        this.OtherApplicantDetails.Gender1 = this.OtherApplicantDetailsJson[IndexVal].Gender1;
        this.OtherApplicantDetails.Organization1 = this.OtherApplicantDetailsJson[IndexVal].Organization1;
        this.OtherApplicantDetails.Occupation1 = this.OtherApplicantDetailsJson[IndexVal].Occupation1;
        this.OtherApplicantDetails.salutationr1Options = this.OtherApplicantDetailsJson[IndexVal].salutationr1Options;
        this.OtherApplicantDetails.FirstNamer1 = this.OtherApplicantDetailsJson[IndexVal].FirstNamer1;
        this.OtherApplicantDetails.LastNamer1 = this.OtherApplicantDetailsJson[IndexVal].LastNamer1;
        this.OtherApplicantDetails.DateofBirth1 = this.OtherApplicantDetailsJson[IndexVal].DateofBirth1;
        this.OtherApplicantDetails.age1 = this.OtherApplicantDetailsJson[IndexVal].age1;
        this.OtherApplicantDetails.MaritalStatus1 = this.OtherApplicantDetailsJson[IndexVal].MaritalStatus1;
        this.OtherApplicantDetails.AnniversaryDate1 = this.OtherApplicantDetailsJson[IndexVal].AnniversaryDate1;
        this.OtherApplicantDetails.Mobile1 = this.OtherApplicantDetailsJson[IndexVal].Mobile1;
        this.OtherApplicantDetails.Email1 = this.OtherApplicantDetailsJson[IndexVal].Email1;
        this.OtherApplicantDetails.PassportNo1 = this.OtherApplicantDetailsJson[IndexVal].PassportNo1;
        this.OtherApplicantDetails.Validtill1 = this.OtherApplicantDetailsJson[IndexVal].Validtill1;
        this.OtherApplicantDetails.PanNo1 = this.OtherApplicantDetailsJson[IndexVal].PanNo1;
        this.OtherApplicantDetails.AadharNo1 = this.OtherApplicantDetailsJson[IndexVal].AadharNo1;
        this.showModalBox();
    }

    handleUpdateapplicant(event) {


        this.OtherApplicantValidation();


        if (this.OtherApplicentInputFieldValidation == false && this.OtherApplicentComboFieldValidation == false && this.OtherApplicentAadharcardvalidation == false) {
            // console.log(this.OtherApplicantDetails);
            let OtherApplicantDetailsarray = [];
            let Editindex = event.currentTarget.dataset.id;
            // console.log("Editindex", Editindex);
            //console.log("this.OtherApplicantDetailsJson.length", this.OtherApplicantDetailsJson.length);
            for (let i = 0; i < this.OtherApplicantDetailsJson.length; i++) {
                //console.log('forloop entry');
                let tempRecord = Object.assign({}, this.OtherApplicantDetailsJson[i]);


                // console.log(tempRecord.index + "test" + Editindex)
                if (parseInt(tempRecord.index) !== parseInt(Editindex)) {
                    // console.log("tempres");
                    OtherApplicantDetailsarray.push(tempRecord);
                } else {
                    // console.log("this.OtherApplicantDetails", JSON.stringify(this.OtherApplicantDetails));
                    OtherApplicantDetailsarray.push(this.OtherApplicantDetails);
                }
            }
            this.OtherApplicantDetailsJson = OtherApplicantDetailsarray;
            this.hideModalBox();
        }

    }


    OtherApplicantDetailsEmpty() {
        this.OtherApplicantDetails = {
            Id: "",
            index: "",
            Salutation1: "",
            FirstName1: "",
            LastName1: "",
            Gender1: "",
            Organization1: "",
            Occupation1: "",
            salutationr1Options: "",
            FirstNamer1: "",
            LastNamer1: "",
            DateofBirth1: "",
            age1: "",
            MaritalStatus1: "",
            AnniversaryDate1: "",
            Mobile1: "",
            Email1: "",
            PassportNo1: "",
            Validtill1: "",
            PanNo1: "",
            AadharNo1: "",
            applicantcount: "",
        }
    }

    PaymentScheduleDetailsEmpty() {
        this.PaymentScheduleDetails = {
            Id: "",
            Payment_Schedule_Type: "",
            Payment_Particulars: "",
            Amount: "",
            SerialNumber: "",
            Amount_In_Local_Currency: ""

        }
    }


    // @track ListofAccounts;

    AddRowHandler() {
        this.createRow();

    }


    createRow() {
        let PaymentObject = {};
        if (this.PaymentScheduleMD.length > 0) {
            PaymentObject.index = this.PaymentScheduleMD[this.PaymentScheduleMD.length - 1].index + 1;
        } else {
            PaymentObject.index = 1;
        }
        PaymentObject.Amount_In_Local_Currency = null;
        PaymentObject.Payment_Particulars = null;
        PaymentObject.Amount = null;
        this.PaymentScheduleMD.push(PaymentObject);

    }


    DeleteRowHandler(event) {
        console.log("hello");
        this.deleteRow(event.target.name);
        /* let DeletePaymentScheduleMDRec = [];
         let deletingindex = event.target.name;
         console.log(deletingindex);
         for(let i=0;i<this.PaymentScheduleMD.length;i++){
             let tempRecord = Object.assign({},this.PaymentScheduleMD[i]);
             if(tempRecord.index !== parseInt(deletingindex)){
                 DeletePaymentScheduleMDRec.push(tempRecord);
             }
         }
         for(let j=0;j<DeletePaymentScheduleMDRec.length;j++){
             DeletePaymentScheduleMDRec[j].index = j+1;
         }
         this.PaymentScheduleMD = DeletePaymentScheduleMDRec;
         this.FlexiblePaymentAmount();
         */
        this.FlexiblePaymentAmount();
    }

    deleteRow(deletingindex) {
        let DeletePaymentScheduleMDRec = [];
        //let deletingindex = deletingindex;
        for (let i = 0; i < this.PaymentScheduleMD.length; i++) {
            let tempRecord = Object.assign({}, this.PaymentScheduleMD[i]);
            if (tempRecord.index !== parseInt(deletingindex)) {
                DeletePaymentScheduleMDRec.push(tempRecord);
            }
        }
        for (let j = 0; j < DeletePaymentScheduleMDRec.length; j++) {
            DeletePaymentScheduleMDRec[j].index = j + 1;
        }

        this.PaymentScheduleMD = DeletePaymentScheduleMDRec;


    }


    handlerInputChange(event) {
        let value = event.target.value;
        let fieldName = event.target.name;
        let index = event.target.dataset.id;
        let CheckpaymentschedulePercentageam = 0;
        let islastrowDelete = false;
        let Deleterowval;
        for (let i = 0; i < this.PaymentScheduleMD.length; i++) {
            if (this.PaymentScheduleMD[i].index === parseInt(index)) {
                if (fieldName == "Amount") {
                    if (value > 100) {
                        this.PaymentScheduleMD[i][fieldName] = '';
                        this.PaymentScheduleMD[i]["Amount_In_Local_Currency"] = '';
                        alert("The agreement value should not be greater than 100.");
                    } else {
                        this.PaymentScheduleMD[i][fieldName] = value;
                        this.PaymentScheduleMD[i]["Amount_In_Local_Currency"] = this.PaymentSchedulepercentagecalculator(value);
                    }

                    //CheckpaymentschedulePercentageam = CheckpaymentschedulePercentageam+value;
                    //console.log(fieldName +' - '+ value +' = '+CheckpaymentschedulePercentageam);
                    //console.log(parseInt(CheckpaymentschedulePercentageam) + parseInt(value));
                    CheckpaymentschedulePercentageam = parseInt(CheckpaymentschedulePercentageam) + parseInt(value);
                    console.log('CheckpaymentschedulePercentageam' + "- " + i + " - " + CheckpaymentschedulePercentageam);
                    if (CheckpaymentschedulePercentageam > 100) {
                        this.PaymentScheduleMD[i][fieldName] = '';
                        this.PaymentScheduleMD[i]["Amount_In_Local_Currency"] = '';
                        alert("The Total agreement value should not be greater than 100.");
                        Deleterowval = index;
                        islastrowDelete = true;
                    } else {
                        islastrowDelete = false;
                        Deleterowval = '';
                    }

                } else {
                    this.PaymentScheduleMD[i][fieldName] = value;
                }

            }

            CheckpaymentschedulePercentageam = parseInt(CheckpaymentschedulePercentageam) + parseInt(this.PaymentScheduleMD[i].Amount);

            // console.log('Amount'+[i]+ this.PaymentScheduleMD[i].Amount);

        }

        if (islastrowDelete) {
            this.deleteRow(Deleterowval);
        }
        this.FlexiblePaymentAmount();

    }


    FlexiblePaymentAmount() {
        let PaymentScheduleTotalAmountjs = 0;
        let PaymentSchedulepercentagejs = 0;

        for (let i = 0; i < this.PaymentScheduleMD.length; i++) {
            if (this.PaymentScheduleMD[i]['Amount_In_Local_Currency'] != '' && this.PaymentScheduleMD[i]['Amount_In_Local_Currency'] != null) {
                //console.log('currency'+i+' '+this.PaymentScheduleMD[i]['Amount_In_Local_Currency']);
                PaymentScheduleTotalAmountjs = PaymentScheduleTotalAmountjs + parseFloat(this.PaymentScheduleMD[i]['Amount_In_Local_Currency']);
            }

            if (this.PaymentScheduleMD[i]['Amount'] != '' && this.PaymentScheduleMD[i]['Amount'] != null) {
                PaymentSchedulepercentagejs = PaymentSchedulepercentagejs + parseInt(this.PaymentScheduleMD[i]['Amount']);
            }


        }

        this.BookingFormDetails.PaymentScheduleTotalAmount = PaymentScheduleTotalAmountjs;
        this.BookingFormDetails.PaymentSchedulepercentage = PaymentSchedulepercentagejs;
    }


    showNotification(title, message, Variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: Variant,
        });
        this.dispatchEvent(evt);
    }



    refreshPage() {
        console.log("refreshpage");
        window.location.reload();

    }

    handleCancel() {
        this.refreshPage();
    }
    handlePreview() {

        if (this.BookingFormDetails.BookingFormId != null && this.BookingFormDetails.BookingFormId != '') {
            this.showModal = true;
            this.vfPageUrl = '/apex/BookingPDF?Id=' + this.BookingFormDetails.BookingFormId + '';
            console.log(this.vfPageUrl);
        } else {
            this.showModal = false;
        }


        // return ``;
    }

    /*
    connectedCallback() {
        console.log('Record ID in connectedCallback:', this.recordId); // Debug recordId availability
    }
    handlePreview() {
        if (this.recordId) {
            // Construct the URL to the Visualforce page
            this.vfPageUrl = `/apex/BookingPDF?id=${this.recordId}`;
            this.showModal = true;
        } else {
            console.error('Record ID is not available.');
        }
    }*/

    closeModal() {
        this.showModal = false;
    }

}