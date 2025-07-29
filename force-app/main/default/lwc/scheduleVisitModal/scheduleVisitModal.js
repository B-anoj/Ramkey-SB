import { LightningElement, track, wire, api } from 'lwc';
import getVisitPicklistOptions from '@salesforce/apex/VisitManagerController.getVisitPicklistOptions';
import scheduleVisit from '@salesforce/apex/VisitManagerController.scheduleVisit';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import schedule from '@salesforce/resourceUrl/schedule';

export default class ScheduleVisitModal extends LightningElement {
    @api useremail;

    @track selectedProperty = '';
    @track visitDate = '';
    @track visitTime = '';
    @track visitType = '';
    @track visitDetails = '';

    @track propertyOptions = [];
    @track visitTypeOptions = [];

    @track isSubmitting = false;
    @track errorMessage = '';
    @track isSuccess = false;

    schedule = schedule;

    connectedCallback() {
        this.loadPicklists();
    }

    loadPicklists() {
        const emailToUse = this.useremail || 'dhayalan2531@gmail.com';

        if (!this.useremail) {
            console.warn('⚠️ useremail not passed from parent. Using fallback.');
        }

        getVisitPicklistOptions({ email: emailToUse })
            .then((data) => {
                this.propertyOptions = data.properties?.map(prop => ({ label: prop, value: prop })) || [];
                this.visitTypeOptions = data.visitTypes?.map(type => ({ label: type, value: type })) || [];
            })
            .catch((error) => {
                console.error('❌ Error loading picklists:', error);
                this.showToast('Error', 'Failed to load picklist options.', 'error');
            });
    }

    handlePropertyChange(event) {
        this.selectedProperty = event.detail.value;
    }

    handleDateChange(event) {
        this.visitDate = event.detail.value;
    }

    handleTimeChange(event) {
        this.visitTime = event.detail.value;
    }

    handleVisitTypeChange(event) {
        this.visitType = event.detail.value;
    }

    handleDetailsChange(event) {
        this.visitDetails = event.detail.value;
    }

    get isSubmitDisabled() {
        return this.isSubmitting || !this.selectedProperty || !this.visitDate || !this.visitTime || !this.visitType;
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleSubmit() {
        this.isSubmitting = true;
        this.errorMessage = '';

        const visitPayload = {
            projectName: this.selectedProperty,
            visitDate: this.visitDate,
            visitTime: this.visitTime,
            visitType: this.visitType,
            reasonSchedule: this.visitDetails || '',
            userEmail: this.useremail || 'dhayalan2531@gmail.com'
        };

        console.log('📤 Submitting Visit:', JSON.stringify(visitPayload));

        scheduleVisit({ visitData: visitPayload })
            .then((result) => {
                console.log('✅ Visit Created with Id:', result?.Id);

                // Notify parent with the visit data
                const visit = {
                    visit_id: result?.Id,
                    projectName: this.selectedProperty,
                    bookingId: result?.Booking_Form__c,
                    unit: result?.Unit__c,
                    unitType: result?.Unit_Type__c,
                    area: result?.Area__c,
                    visit_date: this.visitDate,
                    visit_time: this.visitTime,
                    createdDate: result?.CreatedDate,
                    status: result?.Status__c,
                    crm_person: result?.CRM_Person__c
                };

                this.dispatchEvent(new CustomEvent('schedule', {
                    detail: {
                        success: true,
                        visit
                    },
                    bubbles: true,
                    composed: true
                }));

                this.isSuccess = true;

                // Close modal after short delay or immediately
                setTimeout(() => {
                    this.dispatchEvent(new CustomEvent('close'));
                }, 300);
            })
            .catch((error) => {
                console.error('❌ Scheduling Failed:', error);
                this.errorMessage = error?.body?.message || 'Unable to schedule the visit.';
                this.showToast('Error', this.errorMessage, 'error');
            })
            .finally(() => {
                this.isSubmitting = false;
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    get closeButtonClass() {
        return this.isSuccess ? 'close-icon hide' : 'close-icon';
    }

    get successClass() {
        return this.isSuccess ? 'success-mode' : '';
    }
}