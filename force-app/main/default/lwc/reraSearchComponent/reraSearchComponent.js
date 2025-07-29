import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getChannelPartnerDetails from '@salesforce/apex/ChannelPartnerController.getChannelPartnerDetails';
import saveOpportunityDetails from '@salesforce/apex/ChannelPartnerController.saveOpportunityDetails';

export default class ReraSearchComponent extends LightningElement {
    @track CPreraNumber;
    @track CPmobileNumber;
    @track CPemail;
    @track CPPersonName;
    @track OfficeAddress;
    @track CPcompanyName;
    @track showModal = false;
    recordId;  // This will hold the Opportunity record ID

    // Use wire to get the recordId from the page context
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;  // Extract the recordId from page context
            console.log('Record ID from CurrentPageReference:', this.recordId);
        }
    }

    handleInputChange(event) {
        this.reraNumber = event.target.value;
    }

    handleSearch() { 
        if (this.reraNumber) {
            getChannelPartnerDetails({ reraNumber: this.reraNumber })
                .then(result => {
                    if (result) {
                        this.reraNumber = result.Channel_Partner_RERA_Number__c;
                        this.OfficeAddress = result.Door_No__c + ', ' + result.Street1__c + ', ' + result.Street2__c + ', ' + 
                        result.City__c + ', ' + result.State__c + ', ' + result.Country__c + ', ' + result.PINCODE__c;
                        this.contactPersonName = result.Contact_Person_Name__c;
                        this.companyName = result.Company_Individual_Name__c;
                        this.phoneNumber = result.Phone_Number__c;
                        this.email = result.Email_Address__c;
                        this.showModal = true;
                    } else {
                        this.showModal = false;
                        alert('No details found for the entered RERA Number.');
                    }
                })
                .catch(error => {
                    console.error('Error fetching details:', error);
                    alert('Error fetching details');
                });
        } else {
            alert('Please enter a RERA Number');
        }
    }

    closeModal() {
        this.showModal = false;
    }

    saveDetails() { 
    // Ensure recordId is available before saving
    if (this.recordId) {
        saveOpportunityDetails({ 
            recordId: this.recordId,
            CPreraNumber: this.reraNumber,
            CPmobileNumber: this.phoneNumber,
            CPemail: this.email,
            CPcompanyName: this.companyName 
        })
        .then(() => {
            this.showModal = false;
            alert('Details saved successfully in Opportunity.');
            
            // Auto-refresh the page after saving details
            setTimeout(() => {
                location.reload();  // This reloads the page
            }, 1000); // 1 second delay to ensure the alert appears before refresh
        })
        .catch(error => {
            console.error('Error saving details:', error);

            // Extract the custom error message from the Apex exception
            let errorMessage = 'Unknown error';
            
            // Handle the error if it's an AuraHandledException
            if (error.body && error.body.message) {
                errorMessage = error.body.message;
            }

            // Show the specific error message to the user
            if (errorMessage.includes('CP Details cannot be updated')) {
                alert(errorMessage);
            } else {
                alert('Error saving details in Opportunity: ' + errorMessage);
            }
        });
    } else {
        alert('Error: No record ID found on the Opportunity page.');
    }
}

}