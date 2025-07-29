import { LightningElement, track } from 'lwc';
import getProjectMetadata from '@salesforce/apex/HandoverChecklistController.getProjectMetadataForLoggedInUser';
import updateHandoverLineItems from '@salesforce/apex/HandoverChecklistController.updateHandoverLineItems';
import RamkyOneAstra from '@salesforce/resourceUrl/Ramky_One_Astra';

export default class HandoverChecklist extends LightningElement {
    @track projectOptions = [];
    @track selectedProjectName = '';
    @track selectedProject = null;
    @track tabList = [];
    @track activeChecklist = [];
    @track noChecklistData = false;

    rawProjects = [];
    sortedHandoverData = [];

    connectedCallback() {
        this.loadProjectMetadata();
    }

    async loadProjectMetadata() {
        try {
            const result = await getProjectMetadata();
            if (!Array.isArray(result) || result.length === 0) return;

            this.rawProjects = result;
            this.projectOptions = result.map(proj => ({
                label: proj.projectName,
                value: proj.projectName
            }));

            this.selectedProjectName = this.projectOptions[0].value;
            this.handleProjectChange({ detail: { value: this.selectedProjectName } });
        } catch (error) {
            console.error('Error loading project metadata', error);
        }
    }

    handleProjectChange(event) {
        const value = event.detail.value;
        this.selectedProjectName = value;
        this.selectedProject = this.rawProjects.find(p => p.projectName === value);

        if (!this.selectedProject) {
            this.tabList = [];
            this.activeChecklist = [];
            this.noChecklistData = true;
            return;
        }

        this.setupTabsAndChecklist();
    }

    setupTabsAndChecklist() {
        const handovers = this.selectedProject.handoverData || [];
        if (!handovers.length) {
            this.tabList = [];
            this.activeChecklist = [];
            this.noChecklistData = true;
            return;
        }

        this.noChecklistData = false;
        const desiredOrder = ['Type A', 'Type B', 'Type C', 'Type D'];
        const sortedHandovers = desiredOrder.map(type => handovers.find(h => h.actionType === type)).filter(h => h);

        this.sortedHandoverData = sortedHandovers;
        this.tabList = sortedHandovers.map((grp, idx) => ({
            name: grp.actionType,
            label: grp.actionType,
            class: idx === 0 ? 'tab active' : 'tab'
        }));

        this.activateChecklistTab(this.tabList[0].name);
    }

    activateChecklistTab(type) {
        const grp = this.sortedHandoverData.find(g => g.actionType === type);
        if (!grp || !grp.items) {
            this.activeChecklist = [];
            this.noChecklistData = true;
            return;
        }

        this.noChecklistData = false;
        this.activeChecklist = grp.items.map((itm, idx) => ({
            id: itm.id,
            serial: idx + 1,
            activity: itm.activity,
            description: itm.description,
            name: `action_${idx}`,
            actionYes: itm.action === 'Yes',
            actionNo: itm.action === 'No',
            remarks: itm.remarks || ''
        }));
    }

    handleTabClick(evt) {
        const selected = evt.currentTarget.dataset.type;
        this.tabList = this.tabList.map(tab => ({
            ...tab,
            class: tab.name === selected ? 'tab active' : 'tab'
        }));
        this.activateChecklistTab(selected);
    }

    handleActionChange(evt) {
        const idx = parseInt(evt.target.dataset.index, 10);
        const val = evt.target.value;
        this.activeChecklist[idx].actionYes = val === 'Yes';
        this.activeChecklist[idx].actionNo = val === 'No';
    }

    handleRemarkChange(evt) {
        const idx = parseInt(evt.target.dataset.index, 10);
        this.activeChecklist[idx].remarks = evt.target.value;
    }

    get resolvedImageUrl() {
        return this.selectedProject?.imageUrl ? this.selectedProject.imageUrl : RamkyOneAstra;
    }

    async handleSubmit() {
        const payload = this.activeChecklist.map(item => ({
            id: item.id,
            description: item.description,
            action: item.actionYes ? 'Yes' : item.actionNo ? 'No' : '',
            remarks: item.remarks,
            activity: item.activity
        }));

        try {
            await updateHandoverLineItems({ updatedItems: payload });
            alert('Checklist updated successfully.');
        } catch (error) {
            console.error('Error updating checklist:', error);
            alert('Failed to update checklist.');
        }
    }
}