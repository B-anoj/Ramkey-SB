import { LightningElement } from 'lwc';

export default class CommunitySidebar extends LightningElement {
     menuItems = [
        { label: 'Dashboard', icon: '🏠', link: '#' },
        { label: 'Bookings', icon: '📦', link: '#' },
        { label: 'Construction Updates', icon: '🏗️', link: '#' },
        { label: 'Invoices', icon: '🧾', link: '#' },
        { label: 'Documents', icon: '📄', link: '#' },
        { label: 'Visits', icon: '📍', link: '#' },
        { label: 'Support', icon: '🛠️', link: '#' },
        { label: 'Events', icon: '🎉', link: '#' },
        { label: 'Refer & Earn', icon: '👥', link: '#' },
        { label: 'FAQ’s', icon: '❓', link: '#' },
        { label: 'Logout', icon: '🚪', link: '#' }
    ];
}