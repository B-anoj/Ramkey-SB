import { LightningElement, track, wire } from 'lwc';
import getFAQsByType from '@salesforce/apex/FAQController.getFAQsByType';
import NOT_RECORD_Found from '@salesforce/resourceUrl/RecordNotFound';

export default class FaqComponent extends LightningElement {
    @track activeTab = 'Billing';
    @track faqData = {};
    norecordfound = NOT_RECORD_Found;

    get currentFaqs() {
        return this.faqData[this.activeTab] || [];
    }

    get BillingClass() {
        return this.activeTab === 'Billing' ? 'tab active' : 'tab';
    }
    get AgreementClass() {
        return this.activeTab === 'Agreement' ? 'tab active' : 'tab';
    }
    get HomeLoanClass() {
        return this.activeTab === 'Home Loan' ? 'tab active' : 'tab';
    }
    get ConstructionClass() {
        return this.activeTab === 'Construction' ? 'tab active' : 'tab';
    }

    @wire(getFAQsByType)
    wiredFAQs({ error, data }) {
        if (data) {
            const transformedData = {};
            for (const type in data) {
                transformedData[type] = data[type].map(faq => ({
                    ...faq,
                    isOpen: false,
                    iconName: 'utility:chevronright',
                    iconClass: 'chevron-icon'
                }));
            }
            this.faqData = transformedData;
        } else if (error) {
            console.error('Error fetching FAQs:', error);
        }
    }

    handleTabClick(event) {
        const selectedTab = event.currentTarget.dataset.tab;
        this.activeTab = selectedTab;
    }

    handleToggle(event) {
        const id = event.currentTarget.dataset.id;
        const updatedFaqs = this.currentFaqs.map(faq => {
            const isOpen = faq.Id === id ? !faq.isOpen : false;
            return {
                ...faq,
                isOpen,
                iconName: 'utility:chevronright', // fixed icon
                iconClass: isOpen ? 'chevron-icon rotate' : 'chevron-icon'
            };
        });

        this.faqData = {
            ...this.faqData,
            [this.activeTab]: updatedFaqs
        };
    }
}