import { LightningElement, api, track } from 'lwc';
import getBookingApplicantDetailsById from '@salesforce/apex/BookingProjectController.getBookingApplicantDetailsById';
import getCustomerPaymentDetails from '@salesforce/apex/BookingProjectController.getCustomerPaymentDetails';
import PERSON from '@salesforce/resourceUrl/Person';
import CHEVRONBOTTOM from '@salesforce/resourceUrl/ChevronBottom';


export default class BookingDetails extends LightningElement {
    person = PERSON;
    chevronBottom = CHEVRONBOTTOM;

    @api selectedBookingId;
    @track bookings = [];
    @track paymentList = [];
    @track error;
    @track isLoading = true;
    formattedTotal = '0';
    formattedPaid = '0';
    formattedDue = '0';

    connectedCallback() {
        if (this.selectedBookingId) {
            this.fetchBookingDetails();
            this.fetchSummaryDetail();
        } else {
            console.warn('No bookingId passed to BookingDetails component.');
            this.isLoading = false;
        }

    }

    fetchBookingDetails() {
        this.isLoading = true;

        getBookingApplicantDetailsById({ bookingId: this.selectedBookingId })
            .then(result => {
                if (result) {
                    const processedApplicants = (result.applicants || []).map((applicant, index) => {
                        return {
                            ...applicant,
                            sectionKey: `applicant_${index}`,
                            isOpen: false,
                            //label: `${this.getOrdinalWord(index + 2)} Applicant`, // 2 = Second, 3 = Third, etc.
                            label: 'Co-Applicants',
                            icon: '▾'
                        };
                    });

                    const booking = {
                        ...result,
                        showBookingDetails: true,
                        showFirstApplicant: false,
                        bookingDetailsIcon: '▾',
                        firstApplicantIcon: '▾',
                        applicants: processedApplicants
                    };

                    this.bookings = [booking];
                } else {
                    this.bookings = [];
                }

                this.error = undefined;
                this.isLoading = false;
                console.log('Booking data received:', result);
            })
            .catch(error => {
                console.error('Error fetching booking details:', error);
                this.error = error;
                this.bookings = [];
                this.isLoading = false;
            });
    }
    fetchSummaryDetail() {
        if (!this.selectedBookingId) return;

        getCustomerPaymentDetails({ bookingId: this.selectedBookingId }).then(result => {
            console.log('Payment details = ', JSON.stringify(result));
            if (result) {
                this.formattedPaid = this.formatCurrency(result.amountPaid);
                this.formattedDue = this.formatCurrency(result.dueAmount);
                this.formattedTotal = this.formatCurrency(result.totalAmount);
            }
            if (result?.paymentDetails?.length) {
                this.paymentList = result.paymentDetails.map((item, i) => ({
                    srNo: i + 1,
                    Id: item.Id,
                    receipt: item.Receipt_No__c || '-',
                    description: item.Description__c || '-',
                    amount: this.formatCurrency(item.Amount__c),
                    dueDate: this.formatDate(item.Due_Date__c),
                    unpaidAmount: this.formatCurrency(item.Unpaid_Amount__c),
                    status: item.Status__c || 'Unpaid',
                    badgeClass: item.Status__c === 'Paid' ? 'badge paid' : 'badge unpaid',
                    showPayNow: item.Status__c !== 'Paid'
                }));
            }
        }).catch(error => {
            console.error('Error fetching payment summary:', error);
        });
    }
    formatCurrency(value) {
        return Number(value || 0).toLocaleString('en-IN', {
            maximumFractionDigits: 0
        });
    }

    formatDate(dateStr) {
        if (!dateStr) return '-';
        return new Date(dateStr).toLocaleDateString('en-IN');
    }

    formatCurrency(value) {
        if (isNaN(value)) return '0';
        return Number(value).toLocaleString('en-IN', {
            maximumFractionDigits: 0
        });
    }

    toggleSection(event) {
        const bookingId = event.currentTarget.dataset.id;
        const section = event.currentTarget.dataset.section;

        this.bookings = this.bookings.map(booking => {
            if (booking.bookingId === bookingId) {
                if (section === 'bookingDetails') {
                    const isOpen = !booking.showBookingDetails;
                    return {
                        ...booking,
                        showBookingDetails: isOpen,
                        bookingDetailsIcon: isOpen ? '▴' : '▾'
                    };
                }

                if (section === 'firstApplicant') {
                    const isOpen = !booking.showFirstApplicant;
                    return {
                        ...booking,
                        showFirstApplicant: isOpen,
                        firstApplicantIcon: isOpen ? '▴' : '▾'
                    };
                }

                const updatedApplicants = booking.applicants.map(applicant => {
                    if (applicant.sectionKey === section) {
                        const isOpen = !applicant.isOpen;
                        return {
                            ...applicant,
                            isOpen,
                            icon: isOpen ? '▴' : '▾'
                        };
                    }
                    return applicant;
                });

                return {
                    ...booking,
                    applicants: updatedApplicants
                };
            }

            return booking;
        });
    }

    handleBackClick() {
        this.dispatchEvent(new CustomEvent('back'));
    }

    // 🔤 Converts index to word: 2 → Second, 3 → Third, 4 → Fourth, etc.
    getOrdinalWord(n) {
        const words = [
            'First', 'Second', 'Third', 'Fourth', 'Fifth',
            'Sixth', 'Seventh', 'Eighth', 'Ninth', 'Tenth',
            'Eleventh', 'Twelfth', 'Thirteenth', 'Fourteenth', 'Fifteenth',
            'Sixteenth', 'Seventeenth', 'Eighteenth', 'Nineteenth', 'Twentieth'
        ];
        return words[n - 1] || `${n}th`;
    }

    get noBookings() {
        debugger;
        return !this.bookings || this.bookings.length === 0;
    }

}