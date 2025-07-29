import { LightningElement, api } from 'lwc';

export default class UnitDetails extends LightningElement {
    // API Properties for top section
    @api imageUrl;
    @api projectName;
    @api corporateAddress;
    @api phone;
    @api website;

    // Statement of Account
    @api customerName;
    @api coApplicant;
    @api dateOfStatement;
    @api unitNumber;
    @api area;
    @api aosDate;
    @api aosValue;
    @api gstPercentage;
    @api totalValueWithGst;

    // Additional Charges
    @api corpusFund;
    @api advanceMaintenance;
    @api legalCharges;
    @api modificationCharges;
    @api interestPayable;
    @api transferFee;
    @api chargesTotal;
    @api totalCost;

    // Invoice Details
    @api invoiceAmount;
    @api receivedAmount;
    @api dueAmount;
    @api interestAmount;
    @api totalDue;

    // Toggle states
    showStatement = true;
    showCharges = true;
    showInvoice = true;

    get projectNameDisplay() {
        return this.projectName || '---';
    }

    get customerNameDisplay() {
        return this.customerName || '---';
    }

    get coApplicantDisplay() {
        return this.coApplicant || '---';
    }

    get dateOfStatementDisplay() {
        return this.dateOfStatement || '---';
    }

    get unitNumberDisplay() {
        return this.unitNumber || '---';
    }

    get areaDisplay() {
        return this.area || '---';
    }

    get aosDateDisplay() {
        return this.aosDate || '---';
    }

    get aosValueDisplay() {
        return this.aosValue ? this.aosValue : '---';
    }

    get gstPercentageDisplay() {
        return this.gstPercentage ? `${this.gstPercentage}%` : '---';
    }

    get totalValueWithGstDisplay() {
        return this.totalValueWithGst ? this.totalValueWithGst : '---';
    }

    get corpusFundDisplay() {
        return this.corpusFund ? this.corpusFund : '---';
    }

    get advanceMaintenanceDisplay() {
        return this.advanceMaintenance ? this.advanceMaintenance : '---';
    }

    get legalChargesDisplay() {
        return this.legalCharges ? this.legalCharges : '---';
    }

    get modificationChargesDisplay() {
        return this.modificationCharges ? this.modificationCharges : '---';
    }

    get interestPayableDisplay() {
        return this.interestPayable ? this.interestPayable : '---';
    }

    get transferFeeDisplay() {
        return this.transferFee ? this.transferFee : '---';
    }

    get chargesTotalDisplay() {
        return this.chargesTotal ? this.chargesTotal : '---';
    }

    get totalCostDisplay() {
        return this.totalCost ? this.totalCost : '---';
    }

    get invoiceAmountDisplay() {
        return this.invoiceAmount ? this.invoiceAmount : '---';
    }

    get receivedAmountDisplay() {
        return this.receivedAmount ? this.receivedAmount : '---';
    }

    get dueAmountDisplay() {
        return this.dueAmount ? this.dueAmount : '---';
    }

    get interestAmountDisplay() {
        return this.interestAmount ? this.interestAmount : '---';
    }

    get totalDueDisplay() {
        return this.totalDue ? this.totalDue : '---';
    }

    connectedCallback() {
        console.log('Corpus fund =', JSON.stringify(this.corpusFund));
    }

    // Arrow icon direction logic
    get showStatementIcon() {
        return this.showStatement ? '⌃' : '⌄';
    }

    get showChargesIcon() {
        return this.showCharges ? '⌃' : '⌄';
    }

    get showInvoiceIcon() {
        return this.showInvoice ? '⌃' : '⌄';
    }

    // Button class binding (optional for active tab styling)
    get statementTabClass() {
        return `tab ${this.showStatement ? 'open' : ''}`;
    }

    get chargesTabClass() {
        return `tab ${this.showCharges ? 'open' : ''}`;
    }

    get invoiceTabClass() {
        return `tab ${this.showInvoice ? 'open' : ''}`;
    }

    // Toggle methods: allow only one section open at a time
    toggleStatement() {
        this.showStatement = !this.showStatement;
        if (this.showStatement) {
            this.showCharges = true;
            this.showInvoice = true;
        }
    }

    toggleCharges() {
        this.showCharges = !this.showCharges;
        if (this.showCharges) {
            this.showStatement = true;
            this.showInvoice = true;
        }
    }

    toggleInvoice() {
        this.showInvoice = !this.showInvoice;
        if (this.showInvoice) {
            this.showStatement = true;
            this.showCharges = true;
        }
    }
}