import { LightningElement, track, wire, api } from 'lwc';
import getEventDetails from '@salesforce/apex/CustomerEventController.getEventDetails';
import registerCustomer from '@salesforce/apex/CustomerEventController.registerCustomer';
import bannerImage from '@salesforce/resourceUrl/eventBanner';
import NOT_RECORD_Found from '@salesforce/resourceUrl/RecordNotFound';
import EVENT_ICON from '@salesforce/resourceUrl/EventIcon';
import VISIT from '@salesforce/resourceUrl/Visit';
import CALENDAR from '@salesforce/resourceUrl/Calendar';
import CLOSE from '@salesforce/resourceUrl/close';
import registerSuccessGif from '@salesforce/resourceUrl/RegisterSuccess';

export default class CustomerEvents extends LightningElement {
    bannerImage = bannerImage;
    registerGif = registerSuccessGif;
    @track selectedEvent = null;
    @api userEmail = 'dhayalan2531@gmail.com'
    @track eventList = [];
    @track showModal = false;
    norecordfound = NOT_RECORD_Found;
    EventIcon = EVENT_ICON;
    Calendar = CALENDAR;
    Visit = VISIT;
    close = CLOSE
    @wire(getEventDetails)
    wiredEvent({ error, data }) {
        if (data) {
            this.eventList = data.map(evt => ({
                ...evt,
                errorMsg: ''
            }));
        } else if (error) {
            console.error('Error loading event data:', error);
        }
    }

    get noEventsFound() {
    debugger;
    return !this.eventList || this.eventList.length === 0;
    }

    handleRegisterClick(event) {
        const eventId = event.target.dataset.id;
        console.log('event Id =', eventId);
        registerCustomer({ eventId: eventId, userEmail: this.userEmail })
            .then((result) => {
                if (result === 'Success') {
                    this.selectedEvent = this.eventList.find(evt => evt.id === eventId);
                    this.showModal = true;
                    document.body.style.overflow = 'hidden';
                } else {
                    this.eventList = this.eventList.map(evt =>
                        evt.id === eventId ? { ...evt, errorMsg: result } : evt
                    );
                }
            })
            .catch(error => {
                const message = error?.body?.message || 'Something went wrong';
                this.eventList = this.eventList.map(evt =>
                    evt.id === eventId ? { ...evt, errorMsg: message } : evt
                );
            });

    }

    closeModal(event) {
        this.showModal = false;
        this.selectedEvent = null;
        document.body.style.overflow = '';
    }
}