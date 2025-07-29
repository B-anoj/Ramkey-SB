import { LightningElement, api, track } from 'lwc';
import uploadFile from '@salesforce/apex/PdfFileUploadController.uploadFile';

export default class PdfFileUpload extends LightningElement {
    @api recordId;
    @track filesToUpload = [];
    @track isDone = false; 

    handleFileChange(event) {
        const files = Array.from(event.target.files);
        files.forEach(file => {
            if (file.type === 'application/pdf') {
                const reader = new FileReader();
                reader.onload = () => {
                    // Store each file as an object with name, type, and content
                    this.filesToUpload.push({
                        fileName: file.name,
                        fileType: file.type,
                        fileContent: reader.result.split(',')[1]
                    });
                    this.filesToUpload = [...this.filesToUpload]; // Trigger UI update
                };
                reader.readAsDataURL(file);
            } else {
                alert('Only PDF files are allowed.');
            }
        });
    }

    removeFile(event) {
        const index = event.target.dataset.id;
        this.filesToUpload.splice(index, 1);
        this.filesToUpload = [...this.filesToUpload]; // Refresh the UI by creating a new array reference
    }

    handleUpload() {
        if (this.filesToUpload.length > 0) {
            this.isDone = true; // Disable the button during upload
            Promise.all(this.filesToUpload.map(file =>
                uploadFile({
                    recordId: this.recordId,
                    fileName: file.fileName,
                    fileContent: file.fileContent
                })
            ))
            .then(() => {
                alert('Files uploaded successfully');
                this.filesToUpload = []; // Clear the list after successful upload
                this.isDone = false; // Re-enable the button after upload
                location.reload();
            })
            .catch(error => {
                console.error('File upload failed:', error);
                alert('File upload failed');
                this.isDone = false; // Re-enable the button if an error occurs
            });
        } else {
            alert('Please select at least one PDF file to upload.');
        }
    }
}