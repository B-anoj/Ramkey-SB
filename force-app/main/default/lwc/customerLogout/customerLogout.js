import { LightningElement, api, track } from 'lwc';
import verifiedIcon from '@salesforce/resourceUrl/verifiedIcon';
import logoAsset from '@salesforce/resourceUrl/PortalLogout';
export default class LogoutConfirmationModal extends LightningElement {
    @api showmodal = false;
    @track logo = logoAsset;
    connectedCallback() {
        console.log(this.logo);
    }
    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleLogout() {
        this.dispatchEvent(new CustomEvent('confirm'));
    }
}