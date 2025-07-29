import { LightningElement } from 'lwc';
import IncomeTaxStep from '@salesforce/resourceUrl/IncomeTaxStep';
import IncomeTaxStep2 from '@salesforce/resourceUrl/IncomeTaxStep2';
import IncomeTaxStep3 from '@salesforce/resourceUrl/IncomeTaxStep3';
import IncomeTaxStep4 from '@salesforce/resourceUrl/IncomeTaxStep4';
import IncomeTaxStep5 from '@salesforce/resourceUrl/IncomeTaxStep5';
import IncomeTaxStep6 from '@salesforce/resourceUrl/IncomeTaxStep6';
import IncomeTaxStep7 from '@salesforce/resourceUrl/IncomeTaxStep7';

export default class TdsComponent extends LightningElement {
    incomeTaxImage = IncomeTaxStep;
    incomeTaxImage2 = IncomeTaxStep2;
    incomeTaxImage3 = IncomeTaxStep3;
    incomeTaxImage4 = IncomeTaxStep4;
    incomeTaxImage5 = IncomeTaxStep5;
    incomeTaxImage6 = IncomeTaxStep6;
    incomeTaxImage7 = IncomeTaxStep7;
}