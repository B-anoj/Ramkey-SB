import { LightningElement, track } from 'lwc';
import getProjectMetadataForLoggedInUser from '@salesforce/apex/LetsTalkMetadataController.getProjectMetadataForLoggedInUser';
import NOT_RECORD_Found from '@salesforce/resourceUrl/RecordNotFound';


export default class LetsTalk extends LightningElement {
    @track propertyOptions = [];
    @track selectedProperty;
    @track metadataMap = new Map();
    @track selectedData = null;
    norecordfound = NOT_RECORD_Found;
    @track error;

    connectedCallback() {
        getProjectMetadataForLoggedInUser()
            .then((result) => {
                if (result && result.length > 0) {
                    // Build picklist options and map
                    this.propertyOptions = result.map(item => ({
                        label: item.projectName,
                        value: item.projectName
                    }));

                    this.metadataMap = new Map();
                    result.forEach(item => {
                        this.metadataMap.set(item.projectName, item);
                    });

                    // Default select the first one
                    this.selectedProperty = this.propertyOptions[0].value;
                    this.selectedData = this.metadataMap.get(this.selectedProperty);
                }
            })
            .catch((error) => {
                this.error = 'Failed to load contact data: ' + error.body?.message;
                console.error(error);
            });
    }
    get telLink() {
    return this.crmPhoneNumber ? `tel:${this.crmPhoneNumber}` : '#';
}

    get mailtoLink() {
    return this.selectedData?.email ? `mailto:${this.selectedData.email}` : '#';
    }

    handlePropertyChange(event) {
        this.selectedProperty = event.detail.value;
        this.selectedData = this.metadataMap.get(this.selectedProperty);
    }

    get crmPhoneNumber() {
    if (!this.selectedData?.crmContact) return '';
    const match = this.selectedData.crmContact.match(/\+?\d[\d\s]+/);
    return match ? match[0].replace(/\s+/g, '') : '';
}
get showNoData() {
    return this.propertyOptions && this.propertyOptions.length === 0;
}
}