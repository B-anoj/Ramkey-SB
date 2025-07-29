import { LightningElement, api } from 'lwc';
import Ramky_One_Astra from '@salesforce/resourceUrl/Ramky_One_Astra';
import NOT_RECORD_Found from '@salesforce/resourceUrl/RecordNotFound';

export default class ConstructionCard extends LightningElement {
    @api title;
    @api description;
    @api projectName;
    @api project; // Expects full project object from Apex
    imageUrl = Ramky_One_Astra;
    norecordfound = NOT_RECORD_Found;

    handleClick() {
        this.dispatchEvent(new CustomEvent('viewupdates', {
            detail: { projectName: this.projectName }
        }));
    }

    get imageUrl() {
    switch (this.project?.projectName) {
        case 'Ramky One Astra':
            return Ramky_One_Astra;
        case 'Ramky One Orion':
            return Ramky_One_Orion;
        
        default:
            return ''; // fallback
    }
    }
}