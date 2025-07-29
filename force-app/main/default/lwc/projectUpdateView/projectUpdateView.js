import { LightningElement, api, track, wire } from 'lwc';
import getUpdatesByProject from '@salesforce/apex/ConstructionUpdateController.getUpdatesByProject';
import CHEVRONUP_WHITE from '@salesforce/resourceUrl/ChevronUpWhite';
import NOT_RECORD_Found from '@salesforce/resourceUrl/RecordNotFound';

export default class ProjectUpdateView extends LightningElement {
    ChevronUpWhite = CHEVRONUP_WHITE

    @api projectName;
    @track updates = [];
    norecordfound = NOT_RECORD_Found;
    @track error;

    @wire(getUpdatesByProject, { projectName: '$projectName' })
    wiredUpdates({ data, error }) {
        if (data) {
            this.error = null;
            this.updates = data.map(item => ({
                ...item,
                isOpen: false,
                iconName: 'utility:chevronright', 
                imageUrls: item.imageUrls || [],
                videoUrls: item.videoUrls || [],
                otherDocuments: item.otherDocuments || []
            }));
        } else if (error) {
            this.error = error.body ? error.body.message : error.message;
            this.updates = [];
        }
    }

    // toggleMonth(event) {
    //     const selectedMonth = event.currentTarget.dataset.month;
    //     this.updates = this.updates.map(item => ({
    //         ...item,
    //         isOpen: item.month === selectedMonth ? !item.isOpen : false,
    //         arrowSymbol: item.month === selectedMonth && !item.isOpen ? '▾' : '▸'
    //     }));
    // }

    toggleMonth(event) {
    debugger;
    const selectedMonth = event.currentTarget.dataset.month;
    this.updates = this.updates.map(item => ({
        ...item,
        isOpen: item.month === selectedMonth ? !item.isOpen : false,
        iconName: item.month === selectedMonth
            ? (!item.isOpen ? 'utility:chevrondown' : 'utility:chevronright')
            : 'utility:chevronright'
    }));
  }


    handleImgError(event) {
        event.target.src = 'https://via.placeholder.com/100?text=Image+Not+Found';
    }
}