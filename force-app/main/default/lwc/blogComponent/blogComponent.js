import { LightningElement, wire, track } from 'lwc';
import getBlogPosts from '@salesforce/apex/BlogController.getBlogPosts';
import RamKey_Image from '@salesforce/resourceUrl/RamketImg';
import NOT_RECORD_Found from '@salesforce/resourceUrl/RecordNotFound';


export default class BlogComponent extends LightningElement {
    @track blogs;
    @track selectedBlog = null;
    ramkeyimg = RamKey_Image;
    norecordfound = NOT_RECORD_Found;

    @wire(getBlogPosts)
    wiredBlogs({ error, data }) {
        debugger;
        if (data) {
            this.blogs = data.map(blog => {
                const rawUrl = blog.ImageUrl__c || '';

                // Remove <p> tags and decode HTML entities like &amp;
                const strippedUrl = rawUrl.replace(/<\/?[^>]+(>|$)/g, '');
                const decodedUrl = this.decodeHtmlEntities(strippedUrl);

                return {
                    ...blog,
                    ImageUrl__c: decodedUrl,
                    formattedDate: new Date(blog.CreatedDate).toLocaleDateString('en-GB', {
                        day: '2-digit', month: 'long', year: 'numeric'
                    })
                };
            });
        } else if (error) {
            console.error('Error fetching blog posts:', error);
        }
    }

    decodeHtmlEntities(str) {
        debugger;
        const txt = document.createElement('textarea');
        txt.innerHTML = str;
        return txt.value;
    }

    handleReadMore(event) {
        debugger;
        const blogId = event.target.dataset.id;
        const blog = this.blogs.find(b => b.Id === blogId);

        this.selectedBlog = blog;

        // Wait for DOM to render before injecting rich HTML
        setTimeout(() => {
            const container = this.template.querySelector('.full-description');
            if (container) {
                container.innerHTML = blog.Description__c;
            }
        }, 0);
    }

    handleBack() {
        debugger;
        this.selectedBlog = null;
    }
}