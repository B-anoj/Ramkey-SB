import { LightningElement, api, wire } from 'lwc';
import closeCase from '@salesforce/apex/CloseCaseController.closeCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CloseCaseButton extends LightningElement {
    @api recordId; // Case ID

    handleCloseCase() {
        closeCase({ caseId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Case status updated to Closed.',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}