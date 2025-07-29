import { LightningElement, api, track } from 'lwc';
import getLastSixMonthsData1 from '@salesforce/apex/DashboardController.getLastSixMonthsData1';
import getBankingPartners from '@salesforce/apex/DashboardController.getBankingPartners';
import getServices from '@salesforce/apex/DashboardController.getService';
import getProjectDetails from '@salesforce/apex/DashboardController.getProjectDetails';

import duskImage from '@salesforce/resourceUrl/DuskView';
import Chart from '@salesforce/resourceUrl/chart';
import { loadScript } from 'lightning/platformResourceLoader';
import ICONS from '@salesforce/resourceUrl/DashboardImages';
import CONTACT_ICON from '@salesforce/resourceUrl/ContactImg';
import CHEVRONRIGHT from '@salesforce/resourceUrl/ChevronRight';

export default class Dashboard extends LightningElement {
    // Date fields
    currentDay;
    currentMonthYear;
    dayLabel;

    // Resource Images
    duskImage = duskImage;
    bookingIcon = ICONS + '/DashboardImages/Images/Bookings.jpg';
    paymentIcon = ICONS + '/DashboardImages/Images/Payments.jpg';
    unitIcon = ICONS + '/DashboardImages/Images/Units.jpg';
    referIcon = ICONS + '/DashboardImages/Images/Refer.jpg';
    supportIcon = ICONS + '/DashboardImages/Images/Support.jpg';
    documentsIcon = ICONS + '/DashboardImages/Images/Documents.jpg';
    tdsIcon = ICONS + '/DashboardImages/Images/TDS.jpg';
    booningpartnersIcon = ICONS + '/DashboardImages/Images/BookingPartners.jpg';
    calenderIcon = ICONS + '/DashboardImages/Images/Calender.jpg';
    faqsIcon = ICONS + '/DashboardImages/Images/Faqs.jpg';
    handoverIcon = ICONS + '/DashboardImages/Images/Handover.jpg';
    servicesIcon = ICONS + '/DashboardImages/Images/Services.jpg';
    contactIcon = CONTACT_ICON;

    @api userEmail = 'dhayalan2531@gmail.com';

    @track projectList = [];
    @track bankingPartners = [];
    @track services = [];
    @track handleChange = false;
    @track activeSection = '';
    ChevronRight = CHEVRONRIGHT

    chart;
    chartJsInitialized = false;
    groupedUpdates = {};
    currentProjectName = '';
    currentIndex = 0;
    intervalId;
    @track hasProjects = false;

    connectedCallback() {
        debugger;
        const today = new Date();
        this.currentDay = today.getDate();
        this.currentMonthYear = today.toLocaleString('default', { month: 'long', year: 'numeric' });
        this.dayLabel = `Today, ${today.toLocaleString('default', { weekday: 'long' })}`;
        this.loadInitialData();
    }

    renderedCallback() {
        debugger;
        if (this.chartJsInitialized) return;

        loadScript(this, Chart)
            .then(() => {
                this.chartJsInitialized = true;
                this.renderChartForCurrentProject();
            })
            .catch(error => {
                console.error('Error loading Chart.js:', error);
            });
    }

    disconnectedCallback() {
        debugger;
        clearInterval(this.intervalId);
    }

    // loadInitialData() {
    //     debugger;
    //     Promise.all([
    //         getProjectDetails({ userEmail: this.userEmail }),
    //         getLastSixMonthsData1()
    //     ])
    //         .then(([projectResult, chartData]) => {
    //             this.groupedUpdates = chartData;

    //             this.projectList = projectResult.map(proj => ({
    //                 name: proj.MasterLabel,
    //                 image: proj.imageUrl__c
    //             }));

    //             if (this.projectList.length > 0) {
    //                 this.startImageRotation();
    //                 this.renderChartForCurrentProject();
    //             }
    //         })
    //         .catch(error => {
    //             console.error('Error loading initial data:', error);
    //         });
    // }


    loadInitialData() {
        debugger;
        Promise.all([
            getProjectDetails({ userEmail: this.userEmail }),
            getLastSixMonthsData1()
        ])
            .then(([projectResult, chartData]) => {
                this.groupedUpdates = chartData;

                this.projectList = projectResult.map(proj => ({
                    name: proj.MasterLabel,
                    image: proj.imageUrl__c
                }));

                this.hasProjects = this.projectList.length > 0;
                console.error(' this.hasProjects', this.hasProjects);

                if (this.hasProjects) {
                    console.error('hasProjects', this.hasProjects);
                    this.currentIndex = 0;
                    this.startImageRotation();
                    this.renderChartForCurrentProject();
                }
            })
            .catch(error => {
                console.error('Error loading initial data:', error);
                this.hasProjects = false;
            });
    }


    startImageRotation() {
        debugger;
        this.intervalId = setInterval(() => {
            this.currentIndex = (this.currentIndex + 1) % this.projectList.length;
            this.renderChartForCurrentProject();
        }, 4000);
    }

    get currentImage() {
        debugger;
        // return this.projectList.length > 0 ? this.projectList[this.currentIndex].image : '';
        const project = this.projectList[this.currentIndex];
        return project && project.image ? project.image : null;
    }

    get currentTitle() {
        debugger;
        return this.projectList.length > 0 ? this.projectList[this.currentIndex].name : '';
    }

    renderChartForCurrentProject() {
        debugger;
        if (!this.chartJsInitialized) return;

        const current = this.projectList[this.currentIndex];
        if (!current) return;

        const updates = this.groupedUpdates[current.name];
        this.currentProjectName = current.name;

        if (!updates || updates.length === 0) {
            this.destroyChart();
            return;
        }

        const updatesSorted = [...updates].sort((a, b) => {
            return new Date(a.Update_Month__c) - new Date(b.Update_Month__c);
        });
        const labels = updatesSorted.map(item =>
            new Date(item.Update_Month__c).toLocaleString('default', { month: 'short', year: '2-digit' })
        );
        const dataValues = updatesSorted.map(item => Number(item.Percent__c));
        // let scatterData = [];

        // if (labels.length > 0 && dataValues.length > 0) {
        //     scatterData.push({
        //         x: labels.length - 1,
        //         y: dataValues[dataValues.length - 1]
        //     });
        // }
        console.log('Project:', current.name);
        console.log('Labels:', labels);
        console.log('Data:', dataValues);
        // console.log('Yellow Dot:', scatterData);

        const backgroundColors = dataValues.map(() => '#1E90FF');
        const canvas = this.template.querySelector('canvas');
        if (!canvas) return;
        const ctx = canvas.getContext('2d');

        this.destroyChart();

        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels,
                datasets: [
                    {
                        label: '',
                        data: dataValues,
                        backgroundColor: backgroundColors,
                        borderRadius: 5
                    },
                    // {
                    //     label: '',
                    //     type: 'scatter',
                    //     data: scatterData,
                    //      pointBackgroundColor: '#FF7F0E',
                    //     pointBorderColor: '#FF7F0E',
                    //     pointRadius: 6,
                    //     showLine: false
                    // }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: { enabled: false }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: value => `${value}%`
                        },
                        grid: {
                            color: '#e0e0e0'
                        }
                    },
                    x: {
                        grid: { display: false }
                    }
                }
            }
        });
    }

    destroyChart() {
        debugger;
        if (this.chart) {
            this.chart.destroy();
            this.chart = null;
        }
    }

    handleCardClick(event) {
        debugger;
        const label = event.currentTarget.dataset.label;
        console.log('check method', label);
        this.handleChange = true;
        this.activeSection = label;
        console.log('Clicked label:', label);

        if (label === 'Banking Partners') {
            this.loadBankingPartners();
        } else if (label === 'Services') {
            this.loadServices();
        }
    }

    // connectedCallback() {
    //     setTimeout(() => {
    //         this.loadBankingPartners();
    //     }, 800);
    // }


    loadBankingPartners() {
        debugger;
        console.log('check method2');
        getBankingPartners()
            .then(result => {
                console.log('result', result);
                if (result) {
                    this.bankingPartners = result;
                    console.log(' this.bankingPartners', this.bankingPartners);
                }
            })
            .catch(error => {
                console.error('Error loading banking partners:', error);
            });
    }

    loadServices() {
        debugger;
        getServices()
            .then(result => {
                this.services = result.map(srv => {
                    const addressParts = [
                        srv.Address__Street__s,
                        srv.Address__City__s,
                        srv.Address__StateCode__s,
                        srv.Address__PostalCode__s,
                        srv.Address__CountryCode__s
                    ];
                    const fullAddress = addressParts.filter(part => part && part.trim()).join(', ');
                    return { ...srv, fullAddress };
                });
            })
            .catch(error => {
                console.error('Error loading services:', error);
            });
    }

    get isBankingPartners() {
        debugger;
        return this.activeSection === 'Banking Partners';
    }
    get isServices() {
        debugger;
        return this.activeSection === 'Services';
    }
    get isBookings() {
        debugger;
        return this.activeSection === 'Bookings';
    }
    get isPayments() {
        debugger;
        return this.activeSection === 'Payments';
    }
    get isUnitDetails() {
        debugger;
        return this.activeSection === 'Unit Details';
    }
    get isReferEarn() {
        debugger;
        return this.activeSection === 'Refer & Earn';
    }
    get isSupport() {
        debugger;
        return this.activeSection === 'Support';
    }
    get isDocuments() {
        debugger;
        return this.activeSection === 'Documents';
    }
    get isTds() {
        debugger;
        return this.activeSection === 'TDS';
    }
    get isFaqs() {
        debugger;
        return this.activeSection === 'Faqs';
    }
    get isHandover() {
        debugger;
        return this.activeSection === 'Handover';
    }

    goBack() {
        debugger;
        this.handleChange = false;
        this.activeSection = '';
    }
}