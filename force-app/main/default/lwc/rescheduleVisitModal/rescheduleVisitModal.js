import { LightningElement, api, track } from 'lwc';
import rescheduleVisit from '@salesforce/apex/VisitManagerController.rescheduleVisit';
import scheduleIcon from '@salesforce/resourceUrl/schedule';
import CLOSE from '@salesforce/resourceUrl/close';

export default class RescheduleVisitModal extends LightningElement {
    @api property;
    @api type;
    @api address;
    @api location;
    @api visitId; // passed from parent

    @track visitDate = '';
    @track visitTime = '';
    @track reason = '';
    @track visitDetails = '';
    @track showSuccess = false;

    schedule = scheduleIcon;
    close = CLOSE

    reasonOptions = [
        { label: 'Personal reasons', value: 'Personal reasons' },
        { label: 'Health emergency', value: 'Health emergency' },
        { label: 'Scheduling conflict', value: 'Scheduling conflict' },
        { label: 'Other', value: 'Other' }
    ];

    get isButtonDisabled() {
        return !(this.visitDate && this.visitTime && this.reason.trim());
    }

    handleDateChange(event) {
        this.visitDate = event.target.value;
    }

    handleTimeChange(event) {
        this.visitTime = event.target.value;
    }

    handleReasonChange(event) {
        this.reason = event.target.value;
    }

    handleDetailsChange(event) {
        this.visitDetails = event.target.value;
    }

    async handleSubmit() {
        if (this.isButtonDisabled) {
            return;
        }

        try {
            await rescheduleVisit({
                visitData: {
                    visitId: this.visitId,
                    reason: this.reason,
                    details: this.visitDetails,
                    newDate: this.visitDate,
                    newTime: this.visitTime
                }
            });

            this.showSuccess = true;

            // Dispatch event to refresh parent data
            this.dispatchEvent(new CustomEvent('cancelvisit', {
                detail: { visitId: this.visitId }
            }));

            // Auto-close modal after 3 seconds
            setTimeout(() => {
                this.handleClose();
            }, 3000);

        } catch (error) {
            console.error('❌ Error rescheduling visit:', error);
        }
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}