import { LightningElement, api, track } from 'lwc';
import getProjectDetails from '@salesforce/apex/DashboardController.getProjectDetails';

export default class Testing extends LightningElement {
    @api userEmail = 'dhayalan2531@gmail.com';

    @track projectList = [];
    currentIndex = 0;
    intervalId;

    connectedCallback() {
        debugger;
        this.fetchProjectDetails();
    }

    disconnectedCallback() {
        debugger;
        clearInterval(this.intervalId);
    }

    fetchProjectDetails() {
        debugger;
        getProjectDetails({ userEmail: this.userEmail })
            .then(result => {
                console.log('Project Details from Apex:', result);
                this.projectList = result.map(project => ({
                    name: project.MasterLabel,
                    image: project.imageUrl__c  
                }));
                console.log('Formatted projectList:', this.projectList);

                if (this.projectList.length > 0) {
                    this.startImageRotation();
                }
            })
            .catch(error => {
                console.error('Error fetching project details:', error);
            });
    }

    startImageRotation() {
        debugger;
        const delay = 5000;
        this.intervalId = setInterval(() => {
            if (this.projectList.length > 0) {
                this.currentIndex = (this.currentIndex + 1) % this.projectList.length;
            }
        }, delay);
    }

    get currentImage() {
        debugger;
        return this.projectList.length > 0 && this.projectList[this.currentIndex].image
            ? this.projectList[this.currentIndex].image
            : 'https://via.placeholder.com/300x200?text=No+Image';
    }

    get currentTitle() {
        debugger;
        return this.projectList.length > 0 ? this.projectList[this.currentIndex].name : 'No Project';
    }
}