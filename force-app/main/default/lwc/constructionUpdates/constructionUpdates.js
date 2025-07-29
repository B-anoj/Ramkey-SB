import { LightningElement, track, api,wire } from 'lwc';
import PROJECT_BANNER from '@salesforce/resourceUrl/UpcomingProjects';
import getAllowedProjectsForUser from '@salesforce/apex/ConstructionUpdateController.getAllowedProjectsForUser';
import getUpcomingProjects from '@salesforce/apex/ConstructionUpdateController.getUpcomingProjects';
import VISIT_ICON from '@salesforce/resourceUrl/Visit';
import GRADIENT_SHAPE from '@salesforce/resourceUrl/gradientShape';
import NOT_RECORD_Found from '@salesforce/resourceUrl/RecordNotFound';

export default class ConstructionUpdates extends LightningElement {
    // Project banner background
    projectBanner = PROJECT_BANNER;
    gradientShape = GRADIENT_SHAPE;
      visitimg = VISIT_ICON;
    @api useremail;
    // State variables
    @track projects = [];
    @track showUpdates = false;
    @track selectedProject = null;
    @track selectedData = null;

    @track upcomingProjectList = [];
    @track showProjectsGrid = false;
    @track error;
    norecordfound = NOT_RECORD_Found;

    // Background style for banner
    get backgroundStyle() {
        return `background-image: url(${this.projectBanner}); background-size: cover; background-position: center;`;
    }

    get hasUpcomingProjects() {
        debugger;
    return this.upcomingProjectList && this.upcomingProjectList.length > 0;
  }

 @wire(getUpcomingProjects)
    wiredProjects({ data, error }) {
        debugger;
        if (data) {
            console.log('data====>',data);
            this.upcomingProjectList = data.map(p => ({
                ...p,
                Project_Image_Url__c: this.stripHtmlTags(p.Project_Image_Url__c),
                showFullDesc: false
            }));
            console.log('this.upcomingProjectList====>',this.upcomingProjectList);
        } else if (error) {
            console.error('Error fetching upcoming projects:', error);
        }
    }
    stripHtmlTags(htmlString) {
    debugger;
    const div = document.createElement("div");
    div.innerHTML = htmlString;
    return div.textContent || div.innerText || "";
}

  handleReadMore(event) {
    const id = event.target.dataset.id;
    this.upcomingProjectList = this.upcomingProjectList.map(p => ({
        ...p,
        showFullDesc: p.Id === id // only clicked one expands
    }));
}

handleReadLess(event) {
    const id = event.target.dataset.id;
    this.upcomingProjectList = this.upcomingProjectList.map(p =>
        p.Id === id ? { ...p, showFullDesc: false } : p
    );
}

    handleViewProjects() {
    debugger;
    this.showProjectsGrid = true;
   }

    // Fetch allowed projects on load
    connectedCallback() {
        getAllowedProjectsForUser({userEmail : this.userEmail})
            .then(data => {
                this.projects = data;
            })
            .catch(error => {
                console.error('Error fetching projects:', error);
            });
    }
    handleBackClick() {
    this.showProjectsGrid = false;
    this.showUpdates = false;
    this.selectedProject = null;
    this.selectedData = null;
}

    // Handle project card click
    handleViewUpdate(event) {
        const projectName = event.detail.projectName;
        this.selectedProject = projectName;
        this.selectedData = this.projects.find(p => p.projectName === projectName);
        this.showUpdates = true;
    }

    // Optional: Handle back button
    handleBack() {
        this.showUpdates = false;
        this.selectedProject = null;
        this.selectedData = null;
    }
}