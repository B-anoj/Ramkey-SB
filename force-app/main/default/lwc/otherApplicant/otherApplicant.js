import { LightningElement } from 'lwc';

export default class OtherApplicant extends LightningElement {


    handleSave() {
        // Implement your save logic here
        console.log('Save button clicked');
    }

    // Handle Cancel button click
    handleCancel() {
        // Implement your cancel logic here
        console.log('Cancel button clicked');
    }
}