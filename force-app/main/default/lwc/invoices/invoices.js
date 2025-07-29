import { LightningElement, track, api } from 'lwc';
import getInvoices from '@salesforce/apex/InvoiceController.getInvoices';
import ViewIcon from '@salesforce/resourceUrl/BookingDocumentsView';
import DownloadIcon from '@salesforce/resourceUrl/DownloadImage';
import NOT_RECORD_Found from '@salesforce/resourceUrl/RecordNotFound';

import { NavigationMixin } from "lightning/navigation";

export default class InvoicesTable extends NavigationMixin(LightningElement) {
    @track invoiceData = [];
    @track showDocModal = false;
    @track selectedDoc = { url: '', name: '' };

    viewIcon = ViewIcon;
    downloadIcon = DownloadIcon;
    norecordfound = NOT_RECORD_Found;


    @api userEmail = 'dhayalan2531@gmail.com';

    connectedCallback() {
        this.fetchInvoices();
    }

    get pdfHeight() {
        return this.heightInRem + 'rem';
    }
    get url() {
        return '/sfc/servlet.shepherd/document/download/' + this.fileId;
    }
    get noData() {
    debugger;
    return this.invoiceData.length === 0;
   }

    fetchInvoices() {
        debugger;
        getInvoices()
            .then(result => {
                if (Array.isArray(result)) {
                    this.invoiceData = result.map((record, index) => {
                        const inv = record.invoice;
                        const publicUrl = record.documentLink; // <-- from Apex wrapper
                        const fileName = record.fileName;

                        return {
                            Id: inv.Id,
                            srNo: index + 1,
                            Name: inv.Name || '-',
                            Receipt_No__c: inv.Receipt_No__c || '-',
                            Description__c: inv.Description__c || '-',
                            CreatedDate: inv.CreatedDate || '',
                            formattedDate: this.formatDate(inv.CreatedDate),
                            Amount__c: this.formatAmount(inv.Amount__c),
                            Status__c: inv.Status__c || 'Pending',
                            // TDS_Submission__c: publicUrl ? 'Uploaded' : 'Not Uploaded',
                            TDS_Submission__c: inv.Description__c ? `Uploaded: ${inv.Description__c}` : 'Upload',
                            TDS_File_Url__c: publicUrl, // for view
                            TDS_Status__c: inv.TDS_Status__c || 'Pending',
                            tdsClass: this.getStatusClass(inv.TDS_Status__c),
                            Preview_File_Url__c: publicUrl, // for modal or window.open
                            Download_File_Url__c: publicUrl, // for download
                            TDS_Submission__c: inv.Description__c || 'Invoice Document'
                        };
                    });
                }
            })
            .catch(error => {
                console.error('Error fetching invoices:', error);
            });
    }



    handleViewDoc(event) {
        debugger;
        const url = event.currentTarget.dataset.url;
        const name = event.currentTarget.dataset.name || 'Invoice Preview';
        this.selectedDoc = { url, name };
        this.showDocModal = true;

        // // Open public link in new tab
        // if (url) {
        //     window.open(url, '_blank');
        // } else {
        //     console.warn('No URL provided for viewing document.');
        // }
    }

    publicUrl;
    navigateToFilePreview(event) {
        this.publicUrl = event.currentTarget.dataset.url;
        console.log('Preview URL =' + this.publicUrl);
        this.showDocModal = true;
    }

    handleDownloadDoc(event) {
        this.publicUrl = event.currentTarget.dataset.url;
        const description = event.currentTarget.dataset.description || 'Invoice';

        if (this.publicUrl) {
            const link = document.createElement('a');
            link.href = this.publicUrl;
            link.download = `${description}.pdf`;
            link.target = '_blank';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        } else {
            console.error('Missing public URL for download');
        }
    }



    closeModal() {
        debugger;
        this.selectedDoc = {};
        this.showDocModal = false;
    }

    getStatusClass(status) {
        switch ((status || '').toLowerCase()) {
            case 'approved':
                return 'status approved';
            case 'not approved':
                return 'status not-approved';
            case 'overdue':
                return 'status overdue';
            default:
                return 'status';
        }
    }

    formatDate(dateStr) {
        if (!dateStr) return '-';
        const dt = new Date(dateStr);
        return dt.toLocaleDateString('en-IN', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric'
        });
    }

    formatAmount(amt) {
        return new Intl.NumberFormat('en-IN').format(amt || 0);
    }
}