import { LightningElement, api, track } from 'lwc';
import cancelVisit from '@salesforce/apex/VisitManagerController.cancelVisit';
import scheduleIcon from '@salesforce/resourceUrl/schedule'; // ✅ Import image

export default class CancelVisitModal extends LightningElement {
    @api property;
    @api address;
    @api unitType;
    @api location;
    @api visitId; // ✅ Required to pass to Apex

    @track reason = '';
    @track showSuccess = false;

    schedule = scheduleIcon; // ✅ Bind to template

    get isButtonDisabled() {
        return this.reason.trim() === '';
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleReasonChange(event) {
        this.reason = event.target.value;
    }

    async handleSubmit() {
        try {
            await cancelVisit({
                visitData: {
                    visitId: this.visitId,
                    reasonSchedule: this.reason
                }
            });
            this.showSuccess = true; // ✅ Show success popup
        } catch (error) {
            console.error('❌ Cancel Visit Error:', error);
        }
    }
}