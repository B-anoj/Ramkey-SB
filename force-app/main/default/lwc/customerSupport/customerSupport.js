import { LightningElement, wire, api, track } from 'lwc';
import BACKGROUND from '@salesforce/resourceUrl/CaseSuccess';
import MESSAGELOGO from '@salesforce/resourceUrl/MessageLog';
import NOT_RECORD_Found from '@salesforce/resourceUrl/RecordNotFound';
import getSupportDetails from '@salesforce/apex/CustomerSupportController.getSupportDetails';
import customerCaseImport from '@salesforce/apex/CustomerSupportController.customerCaseImport';
import supportRating from '@salesforce/apex/CustomerSupportController.supportRating';
import getRatingForCase from '@salesforce/apex/CustomerSupportController.getRatingForCase';
import reopenCase from '@salesforce/apex/CustomerSupportController.reopenCase';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import CATEGORY_FIELD from '@salesforce/schema/Case.Type';
import PLUS from '@salesforce/resourceUrl/Plus';
import CLOSE from '@salesforce/resourceUrl/close';
import CHEVRONBOTTOM from '@salesforce/resourceUrl/ChevronBottom';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SupportTable extends LightningElement {

    @track useremail = 'dhayalan2531@gmail.com';
    @track caseList = [];
    @api showForm = false;
    showSuccess = false;
    selectedCategory = '';
    categoryOptions = [];
    otherText = '';
    description = '';
    @track logo = BACKGROUND;
    @track rating = 0;
    @track feedback = '';
    @track isSubmitDisabled = true;
    @track isLoading = false;
    wiredCaseResult;
    norecordfound = NOT_RECORD_Found;
    messagelogo = MESSAGELOGO;
    Plus = PLUS
    close = CLOSE
    ChevronBottom = CHEVRONBOTTOM
    @track showSuccessModal = false;
    @track selectedCaseId = '';
    @track selectedRating = 0;
    @track feedback = '';
    @track showThankYouModal = false;
    @track cases = [];
    starArray = [1, 2, 3, 4, 5]; // ⭐ This is the fix

    getStarClass(index, rating) {
        return index < rating ? 'star filled' : 'star';
    }



    @wire(getSupportDetails, { email: '$useremail' })
    wiredCases(result) {
        debugger;
        this.wiredCaseResult = result;

        const { data, error } = result;
        if (data) {
            this.caseList = data.map((item, index) => ({
                ...item,
                serialNumber: index + 1,
                formattedDate: new Date(item.CreatedDate).toLocaleDateString('en-US'),
                statusClass: item.Status === 'Closed' ? 'badge completed' : 'badge pending',
                isCompleted: item.Status === 'Closed'
            }));
            console.log(' Case Details =', JSON.stringify(this.caseList));
            this.fetchRatings();
        } else if (error) {
            console.error('Error fetching support cases:', error);
        }
    }

    fetchRatings() {
        debugger;
        const closedCases = this.caseList.filter(cs => cs.Status === 'Closed');

        const ratingPromises = closedCases.map(cs =>
            getRatingForCase({ caseId: cs.Id })
                .then(rating => {
                    const parsed = parseInt(rating, 10);
                    cs.rating = isNaN(parsed) ? 0 : parsed;
                    cs.showRating = !!rating;
                    cs.showRateButton = !rating;

                    cs.starClasses = this.starArray.map((_, i) => ({
                        key: `${cs.Id}-${i}`,
                        class: i < cs.rating ? 'star filled' : 'star'
                    }));
                })
                .catch(error => {
                    console.error(`Failed to fetch rating for case ${cs.Id}`, error);
                })
        );

        Promise.all(ratingPromises).then(() => {
            this.caseList = [...this.caseList]; // refresh reactivity
        });
    }


    get noDataFound() {
        debugger;
        return this.caseList.length === 0;
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    contactInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$contactInfo.data.defaultRecordTypeId',
        fieldApiName: CATEGORY_FIELD
    })
    resourceourceValues;


    // get showOtherInput() {
    //     return this.selectedCategory === 'Other';
    // }



    handleCategoryChange(event) {
        debugger;
        this.selectedCategory = event.detail.value;
        console.log('SELECTED CATEGORY =', this.selectedCategory);
    }

    handleOtherInput(event) {
        debugger;
        this.otherText = event.detail.value;
    }

    handleDescriptionChange(event) {
        debugger;
        this.description = event.detail.value;

        if (!this.description || this.description.trim() === '') {
            this.isSubmitDisabled = true;
        } else {
            this.isSubmitDisabled = false;
        }
    }


    submitCase() {
        debugger;
        this.isLoading = true;
        console.log('Type =', this.selectedCategory);
        console.log('Subject =', this.otherText);
        console.log('Description =', this.description);
        customerCaseImport({ csCategory: this.selectedCategory, csSubject: this.otherText, csDescription: this.description, userEmail: this.useremail }).then(result => {
            setTimeout(() => {
                this.showForm = false;
                this.showSuccess = true;
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Support case submitted successfully!',
                        variant: 'success'
                    })
                );
                refreshApex(this.wiredCaseResult);
            }, 800);
            console.log('Result =', result);
        }).catch(error => {
            console.error('Error submitting case:', error);
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to submit case. Please try again.',
                    variant: 'error'
                })
            );
        });
    }

    closeModal() {
        this.showForm = false;
        this.showSuccess = false;
        this.selectedCategory = '';
        this.otherText = '';
        this.description = '';
        this.isSubmitDisabled = true;
        // Optionally dispatch event to parent to refresh
    }
    handleCreateCase() {
        debugger;
        this.selectedCategory = '';
        this.otherText = '';
        this.description = '';
        this.isSubmitDisabled = true;
        this.showForm = true;
    }
    showRateModal = false;
    showStartModal = false;
    handleRate(event) {
        debugger;
        this.selectedCaseId = event.currentTarget.dataset.caseId;
        this.rating = 0;
        this.selectedRating = 0;
        this.feedback = '';
        this.showRateModal = true;
    }
    handleClose() {
        this.showRateModal = false;
    }
    handleContinue() {
        this.showRateModal = false;
        this.showStartModal = true;

    }
    get showFeedbackBox() {
        return this.rating > 0 && this.rating <= 3;
    }
    comments;
    handleComments(event) {
        this.comments = event.target.value;
    }

    get stars() {
        return Array(5)
            .fill(0)
            .map((_, i) => ({
                class: i < this.rating ? 'star filled' : 'star'
            }));
    }
    handleInput(event) {
        debugger;
        this.feedback = event.target.value;
    }
    // handleStarClick(event) {
    //     this.rating = parseInt(event.currentTarget.dataset.index, 10) + 1;
    // }

    handleStarClick(event) {
        debugger;
        const clickedRating = parseInt(event.currentTarget.dataset.index, 10) + 1;
        this.rating = clickedRating;
        this.selectedRating = clickedRating; // <-- add this line
    }

    handleCloseRating() {
        this.showRateModal = false;
        this.showStartModal = false;
    }

    closeSuccessModal() {
        debugger;
        this.showSuccessModal = false;
    }

    handleSubmit() {
        debugger;

        if (this.selectedRating > 0 && this.selectedCaseId) {
            supportRating({
                caseId: this.selectedCaseId,
                rating: this.selectedRating,
                comments: this.comments
            })
                .then((result) => {
                    if (result) {
                        console.log('Apex result:', result);

                        this.showRateModal = false;
                        this.showStartModal = false;
                        this.showThankYouModal = true;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Thank You!',
                                message: 'Your feedback was submitted successfully.',
                                variant: 'success'
                            })
                        );
                        this.selectedRating = 0;
                        this.selectedCaseId = '';

                        this.fetchRatings();

                        setTimeout(() => {
                            refreshApex(this.wiredCaseResult);
                            console.log('Refreshed ratings');
                        }, 800);
                    }
                })
                .catch(error => {
                    console.error('Error submitting feedback:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Feedback submission failed.',
                            variant: 'error'
                        })
                    );
                });
        } else {
            // ⚠️ Show error message or toast if validation fails
            console.warn('Rating or Case ID missing');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Incomplete Submission',
                    message: 'Please select a rating before submitting.',
                    variant: 'warning'
                })
            );
        }
    }

    closeThankYouModal() {
        debugger;
        this.showThankYouModal = false;
    }


    handleRaiseAgain(event) {
        debugger;
        const caseId = this.selectedCaseId;

        if (caseId) {
            reopenCase({ caseId })
                .then((result) => {
                    if (result === 'success') {
                        this.showRateModal = false;
                        //this.showThankYouModal = true;
                        this.showSuccess = true;
                        this.showForm = false;
                        this.isLoading = false;
                        refreshApex(this.wiredCaseResult);
                        this.fetchRatings();
                         this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Case has been reopened. You can raise your request again.',
                            variant: 'success'
                        })
                        );
                    } else {
                        console.error('Unexpected result from Apex:', result);
                    }
                })
                .catch(error => {
                    console.error('Error reopening case:', error);
                });
        } else {
            console.warn('No Case ID provided.');
        }
    }


}