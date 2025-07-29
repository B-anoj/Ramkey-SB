import { LightningElement, track } from 'lwc';
import getProjectNamesWithDocuments from '@salesforce/apex/DocumentController.getProjectNamesWithDocuments';
import NOT_RECORD_Found from '@salesforce/resourceUrl/RecordNotFound';


export default class ProjectDocumentTabs extends LightningElement {
    @track projects = [];
    @track selectedProject = '';
    @track selectedDocuments = [];
    @track selectedPropertyDocuments = [];
    @track selectedPreviewUrl = '';
     norecordfound = NOT_RECORD_Found;

    connectedCallback() {
        this.loadProjects();
    }

    loadProjects() {
        getProjectNamesWithDocuments()
            .then(data => {
                if (data && data.length > 0) {
                    this.selectedProject = data[0].projectName;

                    this.projects = data.map(proj => ({
                        ...proj,
                        className: proj.projectName === this.selectedProject ? 'tab selected' : 'tab'
                    }));

                    const first = data[0];
                    this.selectedDocuments = first.documents.map(doc => ({ ...doc, className: '' }));
                    this.selectedPropertyDocuments = first.propertyDocuments.map(doc => ({ ...doc, className: '' }));
                }
            })
            .catch(error => {
                console.error('Error loading project documents: ', error);
            });
    }

    handleTabClick(event) {
        const projName = event.currentTarget.dataset.project;
        this.selectedProject = projName;

        this.projects = this.projects.map(proj => ({
            ...proj,
            className: proj.projectName === projName ? 'tab selected' : 'tab'
        }));

        const selectedProj = this.projects.find(p => p.projectName === projName);
        if (selectedProj) {
            this.selectedDocuments = selectedProj.documents.map(doc => ({ ...doc, className: '' }));
            this.selectedPropertyDocuments = selectedProj.propertyDocuments.map(doc => ({ ...doc, className: '' }));
            this.selectedPreviewUrl = '';
        }
    }

    handleDocumentClick(event) {
        const docName = event.currentTarget.dataset.doc;
        const type = event.currentTarget.dataset.type;

        const docList = type === 'property' ? this.selectedPropertyDocuments : this.selectedDocuments;

        const updatedDocs = docList.map(doc => {
            const isSelected = doc.name === docName;
            if (isSelected) this.selectedPreviewUrl = doc.documentLink;
            return { ...doc, className: isSelected ? 'active' : '' };
        });

        if (type === 'property') {
            this.selectedPropertyDocuments = updatedDocs;
        } else {
            this.selectedDocuments = updatedDocs;
        }
    }

    get hasProjects() {
        return this.projects && this.projects.length > 0;
    }
}