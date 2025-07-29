import { LightningElement, api, wire, track } from 'lwc';
import FLAG_IMAGE from '@salesforce/resourceUrl/FlagLogo';
import MESSAGE_LOGO from '@salesforce/resourceUrl/MessageLogo';
import NOT_RECORD_Found from '@salesforce/resourceUrl/RecordNotFound';
import getConvertedLeadsForAccount from '@salesforce/apex/LeadController.getConvertedLeadsForAccount';
import getPicklistValuesDynamically from '@salesforce/apex/LeadController.getAllPickListVal';
import addReferralCustomers from '@salesforce/apex/LeadController.addReferralCustomers';
import CLOSE from '@salesforce/resourceUrl/close';
import { refreshApex } from '@salesforce/apex';

export default class ConvertedLeadsForAccount extends LightningElement {
    flagImage = FLAG_IMAGE;
    messageLogo = MESSAGE_LOGO;
    norecordfound = NOT_RECORD_Found;
    @api userEmail = 'dhayalan2531@gmail.com';
    convertedLeads = [];
    showModal = false;
    close = CLOSE

    selectedProperty = '';
    friendName = '';
    friendPhone = '';
    @track propertyOptions = [];
    @track showSuccessModal = false;
    @track isLoading = false;
    @track wiredLeadsResult;
    @track showPhoneError = false;

    objByField = {

        Projects__c: 'Lead'
    };

    @wire(getConvertedLeadsForAccount, { email: '$userEmail' })
    wiredLeads(result) {
        this.wiredLeadsResult = result; // Save for refresh
        const { data, error } = result;

        if (data) {
            this.convertedLeads = data.map((record, index) => ({
                ...record,
                serialNumber: index + 1,
                statusClass: record.IsConverted ? 'pill booked' : 'pill not-booked',
                Status: record.IsConverted ? 'Booked' : 'Not Booked'
            }));
        } else if (error) {
            console.error('Error fetching converted leads:', error);
        }
    }


    get isSendDisabled() {
        debugger;
        return (
            !this.selectedProperty ||
            !this.friendName ||
            !this.friendPhone
        );
    }
    get noData() {
        debugger;
        return this.convertedLeads.length === 0;
    }

    handleReferClick() {
        debugger;
        this.showModal = true;
    }
    connectedCallback() {
        debugger;
        this.getAllPicklistValues();
    }
    getAllPicklistValues() {
        getPicklistValuesDynamically({ ObjectByField: this.objByField })
            .then(result => {
                if (result && result['Projects__c']) {
                    this.propertyOptions = this.mapToLabelValuePair(result['Projects__c']);
                }
            })
            .catch(error => {
                console.error('Error fetching picklist values', error);
            });
    }

    mapToLabelValuePair(picklistArray) {
        return picklistArray.map(value => ({
            label: value,
            value: value
        }));
    }

    closeModal() {
        debugger;
        this.showModal = false;
    }

    handlePropertyChange(event) {
        debugger;
        this.selectedProperty = event.target.value;
        console.log('Property' + this.selectedProperty);
    }

    handleNameChange(event) {
        debugger;
        this.friendName = event.target.value.trim();
    }

    handlePhoneChange(event) {
        debugger;
        this.friendPhone = event.target.value.trim();
        this.friendPhone = input;
        this.showPhoneError = !(input.length === 10 && /^\d{10}$/.test(input));
    }

    sendInvite() {
        debugger
        this.showPhoneError = !(this.friendPhone.length === 10 && /^\d{10}$/.test(this.friendPhone));
        if (this.showPhoneError || !this.selectedProperty || !this.friendName) {
            return;
        }

        this.isLoading = true;

        addReferralCustomers({
            propertyName: this.selectedProperty,
            name: this.friendName,
            phone: this.friendPhone,
            email: this.userEmail,
            company: null
        })
            .then(result => {
                this.showSuccessModal = true;
                this.showModal = false;
                this.resetFields(); // optional
                refreshApex(this.wiredLeadsResult);
            })
            .catch(error => {
                console.error('Error submitting referral:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }


    closeSuccessModal() {
        debugger;
        this.showSuccessModal = false;
    }

    resetFields() {
        debugger;
        this.selectedProperty = '';
        this.friendName = '';
        this.friendPhone = '';
    }


}