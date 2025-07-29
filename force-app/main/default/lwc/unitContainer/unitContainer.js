import { LightningElement, track } from 'lwc';
import getAllowedProjectsForUser from '@salesforce/apex/UNitDetails.getAllowedProjectsForUser';

export default class UnitContainer extends LightningElement {
    @track projects = [];
    @track showUnitList = true;
    @track showUpdates = false;
    @track selectedProject = null;
    @track selectedData = null;

    connectedCallback() {
        getAllowedProjectsForUser()
            .then(data => {
                this.projects = data || [];
            })
            .catch(error => {
                console.error('Error loading projects:', error);
            });
    }

    handleViewUpdate(event) {
        const projectName = event.target.dataset.name;
        this.selectedData = this.projects.find(p => p.projectName === projectName);
        this.selectedProject = projectName;
        this.showUnitList = false;
        this.showUpdates = true;
    }

    handleDashboardClick() {
        this.showUnitList = true;
        this.showUpdates = false;
        this.selectedProject = null;
        this.selectedData = null;
    }
}