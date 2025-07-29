import { LightningElement, track } from 'lwc';
import getMatchingBookingSummaries from '@salesforce/apex/UNitDetails.getMatchingBookingSummaries';

import RamkyOneHarmony from '@salesforce/resourceUrl/Ramky_One_Harmony';
import RamkyOneAstra from '@salesforce/resourceUrl/Ramky_One_Astra';
import RamkyNextown from '@salesforce/resourceUrl/Ramky_Nextown';
import RamkyOneLumina from '@salesforce/resourceUrl/Ramky_One_Lumina';
import RamkyOneOdyssey from '@salesforce/resourceUrl/Ramky_One_Odyssey';
import RamkyOneOrion from '@salesforce/resourceUrl/Ramky_One_Orion';
import DefaultProjectImage from '@salesforce/resourceUrl/RamkyEstateLogo';

// ✅ Mapping metadata label (staticResourceName__c) to actual resource imports
const resourceMap = {
    'Ramky_One_Harmony': RamkyOneHarmony,
    'Ramky_One_Astra': RamkyOneAstra,
    'Ramky_Nextown': RamkyNextown,
    'Ramky_One_Lumina': RamkyOneLumina,
    'Ramky_One_Odyssey': RamkyOneOdyssey,
    'Ramky_One_Orion': RamkyOneOrion
};

export default class UnitDetails extends LightningElement {
    @track projects = [];
    @track selectedProject = null;
    @track selectedData = null;

    @track showUnitList = true;
    @track showUpdates = false;
    @track isUnitDetails = false;

    connectedCallback() {
        this.fetchProjects();
    }

    fetchProjects() {
        getMatchingBookingSummaries()
            .then((data) => {
                if (data && data.length > 0) {
                    this.projects = data.map(project => {
                        const key = project.imageUrl?.trim();
                        return {
                            ...project,
                            imageUrl: resourceMap[key] || DefaultProjectImage
                        };
                    });
                } else {
                    this.projects = [];
                }
            })
            .catch((error) => {
                console.error('Error fetching booking summaries:', error);
            });
    }

    handleViewUpdate(event) {
        const projectName = event.currentTarget.dataset.name;
        if (projectName) {
            this.selectedProject = projectName;
            this.selectedData = this.projects.find(
                project => project.projectName === projectName
            );

            this.showDashboard = false;
            this.showUpdates = true;
            this.showUnitList = false;

            // 🔔 Notify parent for breadcrumb change
            const breadcrumbEvent = new CustomEvent('breadcrumbchange', {
                detail: {
                    level: 'detail',
                    projectName: this.selectedData.projectName
                }
            });
            this.dispatchEvent(breadcrumbEvent);
        }
    }

    handleBackClick() {
        this.showDashboard = false;
        this.showUpdates = false;
        this.showUnitList = true;

        // 🔔 Notify parent for breadcrumb change
        const breadcrumbEvent = new CustomEvent('breadcrumbchange', {
            detail: {
                level: 'list'
            }
        });
        this.dispatchEvent(breadcrumbEvent);
    }

    handleDashboardClick() {
        this.showUpdates = false;
        this.showUnitList = true;
    }

    handleNavigateToUnitDetails() {
        this.isUnitDetails = true;
    }

    goBack = () => {
        this.isUnitDetails = false;
    };
}