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
    @track contentTransformY = 0; // This will control the scroll position
    @track isAnimating = false; // To prevent rapid clicks

    // Define the full order of tabs
    tabOrder = [
        'dashboard',
        'bookings',
        'construction',
        'invoices',
        'documents',
        'visits',
        'support',
        'events',
        'refer', 
        'faq',  
        'letstalk', 
        'blogs',    
        'tds',      
        'profile',
          
    ];
    pageGapVh = 10;
    get isDashboardRendered() { return true; }
    get isBookingsRendered() { return true; }
    get isConstructionRendered() { return true; }
    get isInvoicesRendered() { return true; }
    get isDocumentsRendered() { return true; }
    get isVisitsRendered() { return true; }
    
    get isSupportRendered() { return true; } 
    get isEventsRendered() { return true; }
    get isReferRendered() { return true; }
    get isFaqComponentRendered() { return true; }
    get isLetsTalkRendered() { return true; }
    get isBlogsRendered() { return true; }
    get isTdsRendered() { return true; }
    get isProfileRendered() { return true; }
    
    

    // Getters for sidebar active classes (remain mostly the same)
    get dashboardClass() { return this.currentTab === 'dashboard' ? 'active' : ''; }
    get bookingsClass() { return this.currentTab === 'bookings' ? 'active' : ''; }
    get constructionClass() { return this.currentTab === 'construction' ? 'active' : ''; }
    get invoicesClass() { return this.currentTab === 'invoices' ? 'active' : ''; }
    get visitsClass() { return this.currentTab === 'visits' ? 'active' : ''; }
    get documentsClass() { return this.currentTab === 'documents' ? 'active' : ''; }
    
    get supportClass() { return this.currentTab === 'support' ? 'active' : ''; }
    get eventsClass() { return this.currentTab === 'events' ? 'active' : ''; }
    get referClass() { return this.currentTab === 'refer' ? 'active' : ''; }
    get faqClass() { return this.currentTab === 'faq' ? 'active' : ''; }
    get letsTalkClass() { return this.currentTab === 'letstalk' ? 'active' : ''; }
    get blogsClass() { return this.currentTab === 'blogs' ? 'active' : ''; }
    get tdsClass() { return this.currentTab === 'tds' ? 'active' : ''; }
    get profileClass() { return this.currentTab === 'profile' ? 'active' : ''; }
    

    // This style binds to the content-wrapper and controls its position
    get contentWrapperStyle() {
        return `transform: translateY(${this.contentTransformY}vh); transition: transform 0.8s ease-in-out;`;
    }

    handleSelect(event) {
        if (this.isAnimating) {
            return; // Prevent further actions if animation is in progress
        }

        const nextTab = event.currentTarget.dataset.tab;
        if (this.currentTab === nextTab) {
            return; // Already on this tab
        }

        const currentIndex = this.tabOrder.indexOf(this.currentTab);
        const nextIndex = this.tabOrder.indexOf(nextTab);

        if (nextIndex === -1) {
            console.error('Selected tab not found in tabOrder:', nextTab);
            return;
        }

        this.isAnimating = true;

       
        this.contentTransformY = -(nextIndex * (90 + this.pageGapVh));
        this.currentTab = nextTab; 

        
        setTimeout(() => {
            this.isAnimating = false;
        }, 800); 
    }

    
    handleTopNavClick(event) {
        event.preventDefault();
        this.handleSelect(event);
    }
    handleTopblogClick(event) {
        event.preventDefault();
        this.handleSelect(event);
    }
    handleTotdsClick(event) {
        event.preventDefault();
        this.handleSelect(event);
    }
    handleToProfileClick(event) {
        event.preventDefault();
        this.handleSelect(event);
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
       
        console.log('Logging out...');
        this.showHome = false; 
       
        window.location.href = '/s/login'; // Example redirect
    }

    @track isSidebarCollapsed = false;

    get sidebarArrowIcon() {
        return this.isSidebarCollapsed ? '»' : '«';
    }

    get showMenuLabels() {
        return !this.isSidebarCollapsed;
    }

    get sidebarClass() {
        return `sidebar ${this.isSidebarCollapsed ? 'collapsed' : ''}`;
    }

    toggleSidebar() {
        this.isSidebarCollapsed = !this.isSidebarCollapsed;
    }
}