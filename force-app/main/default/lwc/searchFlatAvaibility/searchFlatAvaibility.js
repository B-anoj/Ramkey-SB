// parentComponent.js
import { LightningElement, track, wire } from 'lwc';
import searchRecords from '@salesforce/apex/RecordSearchController.searchFlats';
import { publish, MessageContext } from 'lightning/messageService';
import SEARCH_RESULTS_MESSAGE from '@salesforce/messageChannel/ProductsFiltered__c';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class SearchFlatAvaibility extends LightningElement {
    @track Plant__c = '';
    @track Sublocation__c = '';
    @track Project__c = '';
    @track Towers__c = '';
    @track Base_Value__c = '';
    @track Status__c = '';
    @track searchResults = [];
    @track error;

    @wire(MessageContext)
    messageContext;

     get isNoRecordsFound() {
        return this.searchResults.length == 0 && !this.error;
    }

    get errorMessage() {
        return this.error ? this.error : 'No records found.';
    }

    locationhandlechange(event) {
        this.Plant__c = event.target.value;
    }

    sublocationhandlechange(event) {
        this.Sublocation__c = event.target.value;
    }
    projecthandlechange(event) {
        this.Project__c = event.target.value;
    }
    blockhandlechange(event) {
        this.Towers__c = event.target.value;
    }
    basevaluehandlechange(event) {
        this.Base_Value__c = event.target.value;
    }
    statushandlechange(event) {
        this.Status__c = event.target.value;
    }
    

    handleSearchClick() {
       
        if (this.validateProductList()) {
            // If validation passes, call the Apex method
            this.searchClick();
        } else {
            // If validation fails, show an error message
            this.showToast('Error', 'Required filed missing.', 'error');
        }
    }
        searchClick(){
       const baseValue = parseFloat(this.Base_Value__c);
        searchRecords({ apexlocation: this.Plant__c, apexsublocation: this.Sublocation__c , apexproject: this.Project__c, apextower: this.Towers__c, apexbasevalue: baseValue, apexstatus: this.Status__c})
            .then(result => {
                this.searchResults = result;
                this.error = undefined; // Clear any previous errors

                const message = {
                    Result: JSON.stringify(result)
                };
                 console.error('records: ', message);
                publish(this.messageContext, SEARCH_RESULTS_MESSAGE, message);
            })
            .catch(error => {
                console.error('Error searching records: ', error);
                this.error = 'An error occurred while searching records.';
                this.searchResults = []; // Clear search results on error
            });
    }

    validateProductList() {
       
         const location = this.Plant__c
        if(!location){
           return false;  
        }
       
        return true; // Validation passes
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}