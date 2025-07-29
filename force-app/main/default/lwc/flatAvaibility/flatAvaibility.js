import { LightningElement,api, wire, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import FLAT_SELECTED_MESSAGE from '@salesforce/messageChannel/ProductSelected__c';
import SEARCH_RESULTS_MESSAGE from '@salesforce/messageChannel/ProductsFiltered__c';
import MY_STATIC_RESOURCE_IMAGE from '@salesforce/resourceUrl/Ramky_Logo';


 export default class FlatAvaibility extends NavigationMixin(LightningElement) {

      displayDigitsAfterHyphen(name) {
        const hyphenIndex = name.indexOf('-'); // Find the index of the hyphen
        if (hyphenIndex !== -1 && hyphenIndex + 5 <= name.length) { // Ensure hyphen is found and there are at least 5 characters after it
            return name.substr(hyphenIndex + 1, 4); // Extract the 4 characters after the hyphen
        } else {
            return ''; // Return empty string if hyphen or characters after it are not found
        }
    }
    // ... (other properties and methods)
  @api records;
  @track searchResults;

   /** Load context for Lightning Messaging Service */
   @wire(MessageContext)
   messageContext;
   @track error;

    
   
   get isNoRecordsFound() {
    return !this.searchResults || this.searchResults.length == 0;
}

get totalRecordsCount() {
        return this.searchResults ? this.searchResults.length : 0;
    }
get errorMessage() {
    return this.error ? this.error : MY_STATIC_RESOURCE_IMAGE;
}
   connectedCallback() {
    // Subscribe to the message channel
    subscribe(this.messageContext, SEARCH_RESULTS_MESSAGE, (message) => {
        this.searchResults = JSON.parse(message.Result);
    });
   
}


   handleFlatSelected(event) {
    const flatId = event.currentTarget.dataset.blockId;

       // Published FlatSelected message
       publish(this.messageContext, FLAT_SELECTED_MESSAGE, {
           flatId: flatId
       });
   } 


   handleGeneratePDFAndSendEmail() {
    if (!this.searchResults || this.searchResults.length === 0) {
        console.error('No search results to process.');
        return;
    } 
       // Convert searchResults to a JSON string and encodeURIComponent to handle special characters
       const recordIdsToSend = this.searchResults.map(record => record.flat.Id);

       // Construct the URL with the searchResults parameter
       const vfPageUrl = `/apex/FlatdetailsPDF?recordIds=${recordIdsToSend.join(',')}`;

       // Create a hidden iframe
    const iframe = document.createElement('iframe');
    iframe.style.display = 'none';
    document.body.appendChild(iframe);

    // Set the iframe source to the PDF URL
    iframe.src = vfPageUrl;
   }

  
}