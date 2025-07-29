import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkPhoneExists from '@salesforce/apex/LeadPhoneSearch.checkPhoneExists';
import GetLeadDetails from '@salesforce/apex/LeadPhoneSearch.getLeadDetails';

export default class LeadSearchComponent extends LightningElement {
    @track phoneNumber;
    @track showModal = false;
    @track records = [];
    @track leadRecords = [];
    @track accountRecords = [];
    @track contactRecords = [];


    handlePhoneNumberChange(event) {
        this.phoneNumber = event.target.value;
        console.log('Phone Number:', this.phoneNumber); // Add console log
    }

    checkExistingRecords() {
        if (!this.phoneNumber) {
            this.showToast('Error', 'Please enter a phone number.', 'error');
            return;
        }

        checkPhoneExists({ phoneNumber: this.phoneNumber })
            .then(result => {
                console.log('Phone Exists Result:', result); // Add console log
                if (result) {
                    this.retrieveRecords();
                } else {
                    this.showToast('Info', 'No records found with this phone number.', 'info');
                }
            })
            .catch(error => {
                console.error('Error checking existing records:', error);
                this.showToast('Error', 'An error occurred while checking existing records.', 'error');
            });
    }

    retrieveRecords() {
        GetLeadDetails({ phoneNumber: this.phoneNumber })
            .then(result => {
                console.log('Retrieve Records Result:', result); // Add console log
                if (result && result.length > 0) {
                    // Filter out duplicates and segregate records
                    this.leadRecords = result.filter(record => record.type === 'Lead');
                    this.accountRecords = result.filter(record => record.type === 'Account');
                    this.contactRecords = result.filter(record => record.type === 'Contact');
                    //this.records = result;
                    this.showModal = true; // Show modal after retrieving records
                } else {
                    this.showToast('Info', 'No records found for the given phone number.', 'info');
                }
            })
            .catch(error => {
                console.error('Error retrieving records:', error);
                this.showToast('Error', 'An error occurred while retrieving records.', 'error');
            });
    }

    closeModal() {
        this.showModal = false;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }}