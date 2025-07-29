import { LightningElement, api, track } from 'lwc';
import getProjectDetails from '@salesforce/apex/DashboardController.getProjectDetails';
import getGroupedUpdatesByProject1 from '@salesforce/apex/DashboardController.getLastSixMonthsData1';
import ChartJS from '@salesforce/resourceUrl/chart';
import { loadScript } from 'lightning/platformResourceLoader';
import ICONS from '@salesforce/resourceUrl/DashboardImages';
import getBankingPartners from '@salesforce/apex/DashboardController.getBankingPartners';



export default class SyncedImageChart extends LightningElement {
    @api userEmail = 'dhayalan2531@gmail.com';

    @track projectList = [];
    @track currentProjectName = '';
    currentIndex = 0;
    intervalId;
    chartJsInitialized = false;
    chart;
    groupedUpdates = {};
     @track bankingPartners = [];
     @track handleChange = false;
    booningpartnersIcon = ICONS + '/DashboardImages/Images/BookingPartners.jpg';
     tdsIcon = ICONS + '/DashboardImages/Images/TDS.jpg';

    // connectedCallback() {
    //     this.loadInitialData();
    // }

    // disconnectedCallback() {
    //     clearInterval(this.intervalId);
    // }

      get isBankingPartners() {
        debugger;
        return this.activeSection === 'Banking Partners';
    }

    // loadInitialData() {
    //     Promise.all([
    //         getProjectDetails({ userEmail: this.userEmail }),
    //         getGroupedUpdatesByProject1()
    //     ])
    //     .then(([projectResult, chartData]) => {
    //         this.groupedUpdates = chartData;

    //         this.projectList = projectResult.map(proj => ({
    //             name: proj.MasterLabel,
    //             image: proj.imageUrl__c
    //         }));

    //         if (this.projectList.length > 0) {
    //             this.loadChartJs();
    //             this.startImageRotation();
    //         }
    //     })
    //     .catch(error => {
    //         console.error('Error loading initial data:', error);
    //     });
    // }

    // loadChartJs() {
    //     if (this.chartJsInitialized) return;
    //     loadScript(this, ChartJS)
    //         .then(() => {
    //             this.chartJsInitialized = true;
    //             this.renderChartForCurrentProject();
    //         })
    //         .catch(error => {
    //             console.error('Chart.js loading failed:', error);
    //         });
    // }

    // startImageRotation() {
    //     this.intervalId = setInterval(() => {
    //         if (this.projectList.length > 0) {
    //             this.currentIndex = (this.currentIndex + 1) % this.projectList.length;
    //             this.renderChartForCurrentProject();
    //         }
    //     }, 5000);
    // }

    // get currentImage() {
    //     const current = this.projectList[this.currentIndex];
    //     return current && current.image ? current.image : 'https://via.placeholder.com/300x200?text=No+Image';
    // }

    // get currentTitle() {
    //     const current = this.projectList[this.currentIndex];
    //     return current ? current.name : 'No Project';
    // }

    // renderChartForCurrentProject() {
    //     if (!this.chartJsInitialized) return;

    //     const current = this.projectList[this.currentIndex];
    //     if (!current) return;

    //     const updates = this.groupedUpdates[current.name];
    //     this.currentProjectName = current.name;

    //     if (!updates || updates.length === 0) {
    //         this.destroyChart();
    //         return;
    //     }

    //     const labels = updates.map(item =>
    //         new Date(item.Update_Month__c).toLocaleString('default', { month: 'short', year: '2-digit' })
    //     );
    //     const dataValues = updates.map(item => item.Percent__c);
    //     const scatterData = dataValues.map((y, x) => (x === 3 ? { x, y } : null));
    //     const backgroundColors = dataValues.map(() => '#1E90FF');

    //     const canvas = this.template.querySelector('canvas');
    //     if (!canvas) return;
    //     const ctx = canvas.getContext('2d');

    //     this.destroyChart();

    //     this.chart = new window.Chart(ctx, {
    //         type: 'bar',
    //         data: {
    //             labels,
    //             datasets: [
    //                 {
    //                     label: '',
    //                     data: dataValues,
    //                     backgroundColor: backgroundColors,
    //                     borderRadius: 5
    //                 },
    //                 {
    //                     label: '',
    //                     type: 'scatter',
    //                     data: scatterData,
    //                     pointBackgroundColor: '#FF7F0E',
    //                     pointBorderColor: '#FF7F0E',
    //                     pointRadius: 6,
    //                     showLine: false
    //                 }
    //             ]
    //         },
    //         options: {
    //             responsive: true,
    //             maintainAspectRatio: false,
    //             plugins: {
    //                 legend: { display: false },
    //                 tooltip: { enabled: false }
    //             },
    //             scales: {
    //                 y: {
    //                     beginAtZero: true,
    //                     ticks: {
    //                         callback: value => `${value}%`
    //                     },
    //                     grid: {
    //                         color: '#e0e0e0'
    //                     }
    //                 },
    //                 x: {
    //                     grid: { display: false }
    //                 }
    //             }
    //         }
    //     });
    // }

    // destroyChart() {
    //     if (this.chart) {
    //         this.chart.destroy();
    //         this.chart = null;
    //     }
    // }


        handleCardClick(event) {
        debugger;
        const label = event.currentTarget.dataset.label;
        this.handleChange = true;
        this.activeSection = label;
        console.log('Clicked label:', label);

        if (label === 'Banking Partners') {
            this.loadBankingPartners();
        } else if (label === 'Services') {
            this.loadServices();
        }
    }

    loadBankingPartners() {
        debugger;
        getBankingPartners()
            .then(result => {
                this.bankingPartners = result;
            })
            .catch(error => {
                console.error('Error loading banking partners:', error);
            });
    }

        goBack() {
        debugger;
        this.handleChange = false;
        this.activeSection = '';
    }

}