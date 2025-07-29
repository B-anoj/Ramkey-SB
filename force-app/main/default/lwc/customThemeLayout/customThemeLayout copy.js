import { LightningElement, track, api } from 'lwc';
import LOGO from '@salesforce/resourceUrl/Ramky_Logo';
import BACKGROUND from '@salesforce/resourceUrl/DashBoardSky';
import duskImage from '@salesforce/resourceUrl/DuskView';
import DATABAR_ICON from '@salesforce/resourceUrl/DatabarVertical';
import TOWER_ICON from '@salesforce/resourceUrl/Tower';
import CHART_MULTIPLE_ICON from '@salesforce/resourceUrl/chartMultiple';
import Invoice_Img from '@salesforce/resourceUrl/Invoice';
import Document_ICON from '@salesforce/resourceUrl/Document';
import VISIT_ICON from '@salesforce/resourceUrl/Visit';
import SUPPORT_ICON from '@salesforce/resourceUrl/Support';
import EVENT_ICON from '@salesforce/resourceUrl/Event';
import REFEREARN_ICON from '@salesforce/resourceUrl/ReferEarn';
import LOGOUT_ICON from '@salesforce/resourceUrl/Logout';
import FAQ_ICON from '@salesforce/resourceUrl/Faq';
import PORTAL_LOGOUT from '@salesforce/resourceUrl/PortalLogout';



export default class CustomThemeLayout extends LightningElement {
    logoURL = LOGO;
    backSky = BACKGROUND;
    duskImage = duskImage;
    databarIcon = DATABAR_ICON;
    towerIcon = TOWER_ICON;
    chartMultipleIcon = CHART_MULTIPLE_ICON;
    invoiceimg = Invoice_Img;
    documentimg = Document_ICON;
    visitimg = VISIT_ICON;
    supportimg = SUPPORT_ICON;
    eventimg = EVENT_ICON;
    referearnimg = REFEREARN_ICON;
    faqimg = FAQ_ICON;
    logoutimg = LOGOUT_ICON;
    portalLogout = PORTAL_LOGOUT;
    @api useremail;


    get backgroundStyle() {
        return `background-image: url(${this.backSky}); background-size: cover; background-repeat: no-repeat; background-position: center; min-height: 100vh;`;
    }


    @track currentTab = 'dashboard';

    get showDashboard() {
        return this.currentTab === 'dashboard';
    }

    get showBookings() {
        return this.currentTab === 'bookings';
    }

    get showConstruction() {
        return this.currentTab === 'construction';
    }

    get showInvoices() {
        return this.currentTab === 'invoices';
    }
    get showVisits() {
        return this.currentTab === 'visits';
    }
    get showDocuments() {
        return this.currentTab === 'documents';
    }
    get showfaqComponent() {
        return this.currentTab === 'faq';
    }
    get showSupport() {
        return this.currentTab === 'support';
    }
    get showEvents() {
        return this.currentTab === 'events';
    }
    get showLetsTalk() {
        return this.currentTab === 'letstalk';
    }
    get showblogs() {
        return this.currentTab === 'blogs';
    }
    get showTds() {
        return this.currentTab === 'tds';
    }
    get showProfile() {
        return this.currentTab === 'profile';
    }

    get dashboardClass() {
        return this.currentTab === 'dashboard' ? 'active' : '';
    }

    get bookingsClass() {
        return this.currentTab === 'bookings' ? 'active' : '';
    }

    get constructionClass() {
        return this.currentTab === 'construction' ? 'active' : '';
    }

    get invoicesClass() {
        return this.currentTab === 'invoices' ? 'active' : '';
    }
    get visitsClass() {
        return this.currentTab === 'visits' ? 'active' : '';
    }
    get documentsClass() {
        return this.currentTab === 'documents' ? 'active' : '';
    }
    get faqClass() {
        return this.currentTab === 'faq' ? 'active' : '';
    }
    get supportClass() {
        return this.currentTab === 'support' ? 'active' : '';
    }
    get showEvents() {
        return this.currentTab === 'events';
    }
    get eventsClass() {
        return this.currentTab === 'events' ? 'active' : '';
    }
    get referClass() {
        return this.currentTab === 'refer' ? 'active' : '';
    }
    // 🔽 Active class for top nav
    get letsTalkClass() {
        return this.currentTab === 'letstalk' ? 'active' : '';
    }
    get blogsClass() {
        return this.currentTab === 'blogs' ? 'active' : '';
    }
    get ourStoryClass() {
        return this.currentTab === 'ourstory' ? 'active' : '';
    }
    get tdsClass() {
        return this.currentTab === 'tds' ? 'active' : '';
    }
    get profileClass() {
        return this.currentTab === 'profile' ? 'active' : '';
    }

    handleSelect(event) {
        debugger;
        this.currentTab = event.currentTarget.dataset.tab;
    }
    // 🔽 For top nav clicks (like Let's Talk)
    handleTopNavClick(event) {
        event.preventDefault();
        this.currentTab = event.currentTarget.dataset.tab;
    }
    handleTopblogClick(event) {
        event.preventDefault();
        this.currentTab = event.currentTarget.dataset.tab;
    }
    handleTotdsClick(event) {
        event.preventDefault();
        this.currentTab = event.currentTarget.dataset.tab;
    }
    handleToProfileClick(event) {
        event.preventDefault();
        this.currentTab = event.currentTarget.dataset.tab;
    }
    showLogout = false;
    showHome = true;
    handleLogOut() {
        this.showLogout = true;
    }
    handleCancel() {
        this.showLogout = false;
    }
    handleLogout() {
        this.showHome = false;
    }
    @track isSidebarCollapsed = false;

    get sidebarArrowIcon() {
        return this.isSidebarCollapsed ? '»' : '«';
    }

    get showMenuLabels() {
        return !this.isSidebarCollapsed;
    }

    /*get sidebarClass() {
        return this.isSidebarCollapsed ? 'sidebar collapsed' : 'sidebar';
    }*/

    toggleSidebar() {
        this.isSidebarCollapsed = !this.isSidebarCollapsed;
    }
    get sidebarClass() {
        return `sidebar ${this.isSidebarCollapsed ? 'collapsed' : ''}`;
    }

    // @api
    // childmethod(val) {
    //     console.log('vall-->', val);
    //     debugger;
    //     this.currentTab = '';
    //     this.currentTab = 'bookings';
    // }

    // page scroll

    tabOrder = [
    'dashboard',
    'bookings',
    'construction',
    'invoices',
    'documents',
    'visits',
    'support',
    'events',
    'faq',
    'refer',
    'blogs',
    'tds',
    'profile'
];

// handleSelect(event) {
//     const nextTab = event.currentTarget.dataset.tab;
//     if (this.currentTab === nextTab) {
//         return;
//     }

//     const container = this.template.querySelector('.main-content');
//     if (!container) {
//         this.currentTab = nextTab;
//         return;
//     }

//     const currentIndex = this.tabOrder.indexOf(this.currentTab);
//     const nextIndex = this.tabOrder.indexOf(nextTab);
//     const isForward = nextIndex > currentIndex;

    
//     container.classList.remove('slide-out-up', 'slide-out-down', 'slide-in-up', 'slide-in-down');

    
//     container.classList.add(isForward ? 'slide-out-up' : 'slide-out-down');

//     setTimeout(() => {
//         this.currentTab = nextTab;

        
//         container.classList.remove('slide-out-up', 'slide-out-down');

        
//         container.classList.add(isForward ? 'slide-in-up' : 'slide-in-down');

        
//         setTimeout(() => {
//             container.classList.remove('slide-in-up', 'slide-in-down');
//         }, 800);
//     }, 800);
// }

handleSelect(event) {
    const nextTab = event.currentTarget.dataset.tab;
    if (this.currentTab === nextTab) {
        return;
    }

    const container = this.template.querySelector('.main-content');
    if (!container) {
        this.currentTab = nextTab;
        return;
    }

    const currentIndex = this.tabOrder.indexOf(this.currentTab);
    const nextIndex = this.tabOrder.indexOf(nextTab);
    const isForward = nextIndex > currentIndex;

    // Clean any existing classes
    container.classList.remove(
        'slide-out-up',
        'slide-out-down',
        'slide-in-up',
        'slide-in-down'
    );

    // Start slide-out
    container.classList.add(isForward ? 'slide-out-up' : 'slide-out-down');

    // Wait for the frame to apply slide-out class
    requestAnimationFrame(() => {
        // Swap the content
        this.currentTab = nextTab;

        // Remove slide-out and start slide-in immediately
        container.classList.remove(
            'slide-out-up',
            'slide-out-down'
        );
        container.classList.add(isForward ? 'slide-in-up' : 'slide-in-down');

        // Clean up slide-in class after animation duration
        setTimeout(() => {
            container.classList.remove('slide-in-up', 'slide-in-down');
        }, 800);
    });
}








};