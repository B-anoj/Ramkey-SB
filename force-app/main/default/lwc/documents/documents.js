import { LightningElement, track } from 'lwc';
import BookingForm from '@salesforce/resourceUrl/BookingForm';
import InvoiceReceipt from '@salesforce/resourceUrl/InvoiceReceipt';
import NOT_RECORD_Found from '@salesforce/resourceUrl/RecordNotFound';


export default class Documents extends LightningElement {
    @track selectedTab = 'north';
    @track showMyDocs = true;
    @track showPropertyDocs = false;
    @track selectedDocument = '';
    @track imagePreviewUrl = '';
    norecordfound = NOT_RECORD_Found;

    // Only included two for now; add more as you import them
    myDocuments = [
        { label: 'Booking Form', resourceUrl: BookingForm },
        { label: 'Invoice Copy', resourceUrl: InvoiceReceipt },
        { label: 'Receipts' },
        { label: 'Agreement of Sale' },
        { label: 'Sale Deed' },
        { label: 'Handover & Possession Letter' },
        { label: 'Sale Deed Acknowledgement' },
        { label: 'Tripartite Agreement' },
        { label: 'Builder NOC' },
        { label: 'Sanction Letter' },
        { label: 'Affidavit/Undertaking Original' }
    ];

    propertyDocuments = [
        { label: 'Property Tax Receipt' },
        { label: 'Building Approval Plan' },
        { label: 'Occupancy Certificate' },
        { label: 'Encumbrance Certificate' }
    ];

   connectedCallback() {
    this.myDocuments = this.myDocuments.map(doc => ({
        ...doc,
        className: 'doc-item',
        iconClass: 'doc-icon' // default icon class
    }));

    this.propertyDocuments = this.propertyDocuments.map(doc => ({
        ...doc,
        className: 'doc-item',
        iconClass: 'doc-icon'
    }));
}

handleDocClick(event) {
    const clickedLabel = event.currentTarget.dataset.label;
    this.selectedDocument = clickedLabel;

    this.myDocuments = this.myDocuments.map(doc => ({
        ...doc,
        className: doc.label === clickedLabel ? 'doc-item active-doc' : 'doc-item',
        iconClass: doc.label === clickedLabel ? 'doc-icon active-icon' : 'doc-icon'
    }));

    this.propertyDocuments = this.propertyDocuments.map(doc => ({
        ...doc,
        className: doc.label === clickedLabel ? 'doc-item active-doc' : 'doc-item',
        iconClass: doc.label === clickedLabel ? 'doc-icon active-icon' : 'doc-icon'
    }));

    const allDocs = [...this.myDocuments, ...this.propertyDocuments];
    const selectedDoc = allDocs.find(doc => doc.label === clickedLabel);
    this.imagePreviewUrl = selectedDoc?.resourceUrl || '';
}

    get myDocButtonClass() {
        return this.showMyDocs ? 'toggle-button active' : 'toggle-button';
    }

    get propDocButtonClass() {
        return this.showPropertyDocs ? 'toggle-button active' : 'toggle-button';
    }

    get northTabClass() {
        return this.selectedTab === 'north' ? 'tab active' : 'tab';
    }

    get karnivalTabClass() {
        return this.selectedTab === 'karnival' ? 'tab active' : 'tab';
    }

    toggleMyDocs() {
        this.showMyDocs = !this.showMyDocs;
        this.showPropertyDocs = false;
    }

    togglePropertyDocs() {
        this.showPropertyDocs = !this.showPropertyDocs;
        this.showMyDocs = false;
    }

    selectTabNorth() {
        this.selectedTab = 'north';
    }

    selectTabKarnival() {
        this.selectedTab = 'karnival';
    }

    
    get hasImagePreview() {
        return this.imagePreviewUrl !== '';
    }
}