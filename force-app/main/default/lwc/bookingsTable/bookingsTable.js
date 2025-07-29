import { LightningElement, api, track } from 'lwc';
import getBookingForms from '@salesforce/apex/BookingProjectController.getBookingApplicantDetails';
import BookingDocumentsView from '@salesforce/resourceUrl/BookingDocumentsView';
import DownloadImage from '@salesforce/resourceUrl/DownloadImage';
import NOT_RECORD_Found from '@salesforce/resourceUrl/RecordNotFound';


export default class BookingsTable extends LightningElement {
    @track bookingData = [];
    @track showBookingList = true;
    @track showDetails = false;
    @track expandedRows = new Set();
    @track selectedBookingId = '';
    @track selectedDoc = null;
    @track showDocModal = false;
    norecordfound = NOT_RECORD_Found;


    @api userEmail = 'dhayalan2531@gmail.com';

    bookingDocumentsViewIcon = BookingDocumentsView;
    downloadIcon = DownloadImage;

    connectedCallback() {
        this.fetchBookingData();
    }

    fetchBookingData() {
        getBookingForms({ userEmail: this.userEmail })
            .then(result => {
                if (Array.isArray(result)) {
                    this.bookingData = result.map((record, index) => {
                        const bookingId = record.id || '';
                        const docItems = Array.isArray(record.documents) ? record.documents.map(doc => ({
                            displayName: doc.documentName || 'Unnamed',  
                            viewUrl: doc.viewUrl,
                            downloadUrl: doc.downloadUrl
                        })) : [];

                        return {
                            id: record.id,
                            srNo: index + 1,
                            description: record.projectName || '',
                            unitNumber: record.unit || '',
                            area: record.AreainSqft ? `${record.AreainSqft} sq. ft.` : '-',
                           // customerId: `${record.firstName || ''} ${record.lastName || ''}`.trim(),
                           customerId: record.name,
                            type: record.unitType || '',
                            date: record.bookingDate
                                ? new Date(record.bookingDate).toLocaleDateString('en-IN', {
                                    day: '2-digit',
                                    month: '2-digit',
                                    year: 'numeric'
                                })
                                : '-',
                            expandedKey: bookingId + '-expanded',
                            documentItems: docItems
                        };
                    });
                }
            })
            .catch(error => {
                console.error('Error fetching booking data:', error);
            });
    }

   get noBookingData() {
    debugger;
    return this.bookingData.length === 0;
   }


    handleDetails(event) {
        this.selectedBookingId = event.target.dataset.id;
        this.showBookingList = false;
        this.showDetails = true;
        console.log('SELECTED Booking Id =', JSON.stringify(this.selectedBookingId));
    }

    handleBack() {
        this.showDetails = false;
        this.showBookingList = true;
        this.selectedBookingId = '';
    }

    toggleMore(event) {
        const bookingId = event.target.dataset.id;
        if (this.expandedRows.has(bookingId)) {
            this.expandedRows.delete(bookingId);
        } else {
            this.expandedRows.add(bookingId);
        }
        this.expandedRows = new Set(this.expandedRows); // Refresh
    }

    get computedBookingData() {
        return this.bookingData.map(booking => ({
            ...booking,
            toggleLabel: this.expandedRows.has(booking.id) ? 'View less' : 'View more',
            isExpanded: this.expandedRows.has(booking.id)
        }));
    }

    handleViewDoc(event) {
        const url = event.target.dataset.url;
        const name = event.target.dataset.name;
        this.selectedDoc = { name, url };
        this.showDocModal = true;
    }

    handleDownloadDoc(event) {
        const url = event.target.dataset.url;
        console.log('Url is:', url);
        if (url) {

            // Open in new tab to trigger download (Experience Cloud safe)
            window.open(url, '_blank');

        } else {
            console.error('Missing download URL');
        }
    }

    closeModal() {
        this.selectedDoc = null;
        this.showDocModal = false;
    }
}