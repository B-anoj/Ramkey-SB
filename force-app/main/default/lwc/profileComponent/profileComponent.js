import { LightningElement, track } from 'lwc';
import FLAG_IMAGE from '@salesforce/resourceUrl/FlagLogo';
import PROFILE_IMAGE from '@salesforce/resourceUrl/Profile';
import getCurrentUserDetails from '@salesforce/apex/profileController.getCurrentUserDetails';

export default class ProfileComponent extends LightningElement {
    flagImage = FLAG_IMAGE;
    profileImage = PROFILE_IMAGE;
    @track user = {
        FirstName: '',
        LastName: '',
        Email: '',
        Phone: '',
        Username: ''
    };

    get firstName() {
        return this.user?.FirstName ?? '';
    }
    get lastName() {
        return this.user?.LastName ?? '';
    }
    get email() {
        return this.user?.Email ?? '';
    }
    get phone() {
        return this.user?.Phone ?? '';
    }
    get username() {
        return this.user?.Username ?? '';
    }

    connectedCallback() {
        debugger;
        setTimeout(() => {
            this.loadUserData();
        }, 500);
    }

    loadUserData() {
        debugger;
        const currentUserEmail = 'dhayalan2531@gmail.com';

        getCurrentUserDetails({ email: currentUserEmail })
            .then(result => {
                if (result) {
                    this.user = { ...result };
                } else {
                    console.error('No user found for email:', currentUserEmail);
                }
            })
            .catch(error => {
                console.error('Error fetching user details', error);
            });
    }


    handleChange(event) {
        debugger;
        const field = event.target.name;
        this.user[field] = event.target.value;
    }
}