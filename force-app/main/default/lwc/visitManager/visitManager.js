import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import fetchVisitDetails from '@salesforce/apex/VisitManagerController.fetchVisitDetails';
import LOGO from '@salesforce/resourceUrl/Ramky_Logo';
import LOCATION from '@salesforce/resourceUrl/Location';
import CHEVRONRIGHT from '@salesforce/resourceUrl/ChevronRight';
import NOT_RECORD_Found from '@salesforce/resourceUrl/RecordNotFound';


export default class VisitManager extends LightningElement {
    @track upcoming = [];
    @track completed = [];
    @track cancelled = [];
    @track activeTab = 'Upcoming';

    @track showVisitDetails = false;
    @track showCancelModal = false;
    @track showRescheduleModal = false;
    @track showScheduleModal = false;

    @track projectName;
    @track bookingId;
    @track unit;
    @track area;
    @track unitType;
    @track createdDate;
    @track visitDate;
    @track visitTime;
    @track crmName;
    @track status;
    @track customerId;

    @api useremail;
    logo = LOGO;
    Location = LOCATION
    ChevronRight = CHEVRONRIGHT
    selectedVisitId;
    allVisits = [];
    norecordfound = NOT_RECORD_Found;

    @track userEmail = 'dhayalan2531@gmail.com'; // fallback
    wiredVisitData;

    // Wire visit data on load and refresh
    @wire(fetchVisitDetails, { email: '$userEmail' })
    wiredFetchVisitDetails(value) {
        this.wiredVisitData = value;
        const { data, error } = value;

        if (data) {
            this.upcoming = this.processVisits(data.visits.upcoming);
            this.completed = this.processVisits(data.visits.completed);
            this.cancelled = this.processVisits(data.visits.cancelled);
            this.allVisits = [...data.visits.upcoming, ...data.visits.completed, ...data.visits.cancelled];
        } else if (error) {
            console.error('Error fetching visit details:', error);
        }
    }

    // Process visit records for display
    processVisits(visits) {
        return visits.map(v => ({
            ...v,
            visit_date: this.formatDate(v.visit_date),
            visit_time: this.formatTime(v.visit_time),
            createdDate: this.formatDate(v.createdDate),
            statusClass: this.getStatusClass(v.status)
        }));
    }

    // Format date (DD/MM/YYYY)
    formatDate(isoDate) {
        if (!isoDate) return '';
        try {
            return new Intl.DateTimeFormat('en-GB').format(new Date(isoDate));
        } catch (e) {
            console.error('Date format error:', e);
            return isoDate;
        }
    }

    // Format time (HH:MM AM/PM)
   formatTime(isoTime) {
        if (!isoTime) return '';
        try {
            const date = new Date(`1970-01-01T${isoTime}`);
            return new Intl.DateTimeFormat('en-US', {
                hour: 'numeric',
                minute: '2-digit',
                hour12: true,
                timeZone: 'UTC'
            }).format(date);
        } catch (e) {
            console.error('Time format error:', e);
            return isoTime;
        }
    }

    // Active list based on tab
    get activeVisits() {
        if (this.activeTab === 'Upcoming') return this.upcoming;
        if (this.activeTab === 'Completed') return this.completed;
        return this.cancelled;
    }

    // Tab styling
    get upcomingClass() {
        return this.activeTab === 'Upcoming' ? 'tab active' : 'tab';
    }
    get completedClass() {
        return this.activeTab === 'Completed' ? 'tab active' : 'tab';
    }
    get cancelledClass() {
        return this.activeTab === 'Cancelled' ? 'tab active' : 'tab';
    }

    showUpcoming() {
        this.activeTab = 'Upcoming';
    }
    showCompleted() {
        this.activeTab = 'Completed';
    }
    showCancelled() {
        this.activeTab = 'Cancelled';
    }

    // Status color classes
    getStatusClass(status) {
        switch (status) {
            case 'Upcoming':
            case 'Scheduled':
                return 'status scheduled';
            case 'Completed':
                return 'status completed';
            case 'Cancelled':
                return 'status cancelled';
            default:
                return 'status';
        }
    }

    // Visit detail open
    handleVisitClick(event) {
        this.selectedVisitId = event.currentTarget.dataset.id;
        const selected = this.allVisits.find(v => v.visit_id === this.selectedVisitId);
        if (selected) {
            this.projectName = selected.projectName || selected.property_name;
            this.bookingId = selected.bookingId;
            this.unit = selected.unit;
            this.unitType = selected.unitType;
            this.area = selected.area;
            this.customerId = selected.customerId;
            this.createdDate = selected.createdDate;
            this.visitDate = selected.visit_date;
            this.visitTime = this.formatTime(selected.visit_time);
            this.crmName = selected.crm_person;
            this.status = selected.status;
        }
        this.showVisitDetails = true;
    }

    handleBackToVisits() {
        this.showVisitDetails = false;
        this.selectedVisitId = null;
    }

    // Modal controls
    openCancelModal() {
        this.showCancelModal = true;
    }
    openRescheduleModal() {
        this.showRescheduleModal = true;
    }
    openScheduleModal() {
        this.showScheduleModal = true;
    }

    handleModalClose() {
        this.showCancelModal = false;
    }
    handleModalReschedule() {
        this.showRescheduleModal = false;
    }
    handleScheduleClose() {
        this.showScheduleModal = false;
    }

    // Cancel visit event
    handleVisitCancel() {
        this.showCancelModal = false;
        this.showVisitDetails = false;
        refreshApex(this.wiredVisitData);
    }

    // Reschedule visit event
    handleVisitReschedule() {
        this.showRescheduleModal = false;
        this.showVisitDetails = false;
        refreshApex(this.wiredVisitData);
    }

    // Schedule visit event
    handleVisitSchedule(event) {
        this.showScheduleModal = false;

        // Immediately add to upcoming UI
        if (event.detail?.success && event.detail.visit) {
            this.addNewVisitToList(event.detail.visit);
        }

        // Optional refresh to stay accurate
        setTimeout(() => {
            refreshApex(this.wiredVisitData);
        }, 800);
    }

    // Inject new visit to UI
    addNewVisitToList(visit) {
        const newVisit = {
            ...visit,
            visit_date: this.formatDate(visit.visit_date),
            visit_time: this.formatTime(visit.visit_time),
            createdDate: this.formatDate(visit.createdDate),
            statusClass: this.getStatusClass(visit.status)
        };

        this.upcoming = [newVisit, ...this.upcoming];
        this.allVisits = [newVisit, ...this.allVisits];
    }
}