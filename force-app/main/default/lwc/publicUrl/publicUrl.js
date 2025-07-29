import { LightningElement, api } from 'lwc';

export default class PdfViewer extends LightningElement {
    @api pdfUrl ='https://ramky-estates-and-farms--utildev.sandbox.my.salesforce.com/sfc/p/In000000LPZb/a/In000000CeCm/KGZoN_e_6soARprSmd9KGlIl0UKQJJgjjsjqQHIOnSw';

    get fullUrl() {
        return this.pdfUrl;
    }
}