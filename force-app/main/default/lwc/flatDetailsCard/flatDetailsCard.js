import { LightningElement, wire ,track } from 'lwc';

// Lightning Message Service and a message channel
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, MessageContext } from 'lightning/messageService';
import FLAT_SELECTED_MESSAGE from '@salesforce/messageChannel/ProductSelected__c';
import MY_STATIC_RESOURCE_IMAGE from '@salesforce/resourceUrl/Ramky_Logo';
// Utils to extract field values
import { getFieldValue } from 'lightning/uiRecordApi';

// Flats_Detail__c Schema
import FLATDETAILS_OBJECT from '@salesforce/schema/Product2';
import NAME_FIELD from '@salesforce/schema/Product2.Name';
import LOCATINO from '@salesforce/schema/Product2.Location__c';
import PROJECT from '@salesforce/schema/Product2.Project__c';
import FLATSTATUS from '@salesforce/schema/Product2.Status__c';
import TOWER from '@salesforce/schema/Product2.Towers__c';
import BASEPRICE from '@salesforce/schema/Product2.Facing__c';
import PROTYPE from '@salesforce/schema/Product2.Type__c';


/**
 * Component to display details of a Flats_Detail__c.
 */
export default class FlatDetailsCard extends NavigationMixin(LightningElement) {
    // Exposing fields to make them available in the template
    location= LOCATINO;
    project= PROJECT;
    flatstatus= FLATSTATUS;
    tower= TOWER;
    face= BASEPRICE;
    protype=PROTYPE;
    // Id of Flats_Detail__c to display
    recordId;
    @track krush;
    // Flats_Detail fields displayed with specific format
       Name;
       @track error;

       get isNoRecordsFound() {
          return this.recordId== null && !this.error;
      }
  
      get errorMessage() {
          return this.error ? this.error : MY_STATIC_RESOURCE_IMAGE;
      }

    /** Load context for Lightning Messaging Service */
    @wire(MessageContext) messageContext;

    /** Subscription for FlatSelected Lightning message */
    flatSelectionSubscription;

    connectedCallback() {
        // Subscribe to FlatSelected message
        this.flatSelectionSubscription = subscribe(
            this.messageContext,
            FLAT_SELECTED_MESSAGE,
            (message) => this.handleProductSelected(message.flatId)
        );
    }

    handleRecordLoaded(event) {
        const { records } = event.detail;
        const recordData = records[this.recordId];
        this.Name = getFieldValue(recordData, NAME_FIELD);
       
    }

    /**
     * Handler for when a Flat is selected. When `this.recordId` changes, the
     * lightning-record-view-form component will detect the change and provision new data.
     */
    handleProductSelected(flatId) {
        this.recordId = flatId;
        this.krush= flatId;
    }

    handleNavigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: FLATDETAILS_OBJECT.objectApiName,
                actionName: 'view'
            }
        });
    }
    handleGeneratePDF() {
        if (!this.krush) {
            console.error('No search results to process.');
            return;
        } 
           // Construct the URL with the searchResults parameter
           const vfPageUrl ='/apex/flatRecordPDF?recordIds=' + this.krush;
    
           // Open the VF page in a new window
           window.open(vfPageUrl, '_blank');
       }
}