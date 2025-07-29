@RestResource(urlMapping='/invoice')
global with sharing class InvoiceDataController {

    @HttpGet
    global static void getMockInvoiceData() {
        String email = RestContext.request.params.get('userEmail');

        List<Booking_Form__c> bookingData = [
            SELECT Id, Name, Project_Name__c, Opportunity__r.Account.Email__c
            FROM Booking_Form__c
            WHERE Opportunity__r.Account.Email__c = :email
        ];
        Set<String> projNames = new Set<String>();
        for (Booking_Form__c bookDetail : bookingData) {
            projNames.add(bookDetail.Project_Name__c);
        }

        Map<String, ProjectInvoiceWrapper> projectMap = new Map<String, ProjectInvoiceWrapper>();
        List<Ramky_Projects__mdt> customerProjId = [SELECT MasterLabel, Id FROM Ramky_Projects__mdt WHERE MasterLabel IN: projNames];
        List<Invoice__c> allInvoices = [
            SELECT Id, Invoice_No__c, Receipt_No__c, Amount__c, Payment_Date__c,
                   Unpaid_Amount__c, Status__c, Booking_Form__r.Project_Name__c,Document_Link__c,
                   Booking_Form__r.Name, Booking_Form__c, Booking_Form__r.Id
            FROM Invoice__c
            WHERE Booking_Form__c IN :bookingData
        ];
        Map<String, String> projectNameToIdMap = new Map<String, String>();
        for (Ramky_Projects__mdt meta : customerProjId) {
            projectNameToIdMap.put(meta.MasterLabel, meta.Id);
        }

        for (Invoice__c invoice : allInvoices) {
            String projectName = invoice.Booking_Form__r.Project_Name__c;
            String bookingId = invoice.Booking_Form__r.Name;

            if (!projectMap.containsKey(projectName)) {
                ProjectInvoiceWrapper projectWrapper = new ProjectInvoiceWrapper();
                projectWrapper.project_id = projectNameToIdMap.containsKey(projectName) ? projectNameToIdMap.get(projectName) : '';
                projectWrapper.project_name = projectName;
                projectWrapper.overdue_count = 0;
                projectWrapper.unpaid_count = 0;
                projectWrapper.details = new InvoiceDetailsWrapper();
                projectWrapper.details.project_name = projectName;
                projectWrapper.details.booking_id = bookingId;
                projectWrapper.details.filter_period = 'This month';
                projectWrapper.details.status_filters = new List<String>{'Paid', 'Overdue', 'Unpaid'};
                projectWrapper.details.payment_gateway_note = 'COMING SOON';
                projectWrapper.details.invoices = new List<InvoiceLineItemWrapper>();
                projectMap.put(projectName, projectWrapper);
            }

            ProjectInvoiceWrapper existingWrapper = projectMap.get(projectName);

            InvoiceLineItemWrapper lineItem = new InvoiceLineItemWrapper();
            lineItem.title = '30 Days from booking';
            lineItem.invoice_no = invoice.Invoice_No__c != null ? invoice.Invoice_No__c : '';
            lineItem.receipt_no = invoice.Receipt_No__c != null ? invoice.Receipt_No__c : '';
            
            lineItem.amount = invoice.Amount__c != null ? '₹' + String.valueOf(invoice.Amount__c.setScale(0)) : '₹0';
            
            lineItem.invoice_date = invoice.Payment_Date__c != null ? String.valueOf(invoice.Payment_Date__c) : '';
            lineItem.payment_date = invoice.Payment_Date__c != null ? String.valueOf(invoice.Payment_Date__c) : '';
            
            lineItem.unpaid_amount = invoice.Unpaid_Amount__c != null ? '₹' + String.valueOf(invoice.Unpaid_Amount__c.setScale(0)) : '₹0';
            
            lineItem.days_overdue = 0;
            lineItem.document_url = invoice.Document_Link__c != null ? invoice.Document_Link__c : '';
            lineItem.status = new List<String>{ invoice.Status__c != null ? invoice.Status__c : 'Unpaid' };
                
                lineItem.actions = new InvoiceActionsWrapper();
            lineItem.actions.view_invoice = true;
            lineItem.actions.view_tds = true;
            
            if (invoice.Unpaid_Amount__c != null && invoice.Unpaid_Amount__c > 0) {
                existingWrapper.unpaid_count++;
            }
            
            existingWrapper.details.invoices.add(lineItem);
        }

        InvoiceWrapper finalWrapper = new InvoiceWrapper();
        finalWrapper.invoices = projectMap.values();

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(finalWrapper));
    }

    global class InvoiceWrapper {
        public List<ProjectInvoiceWrapper> invoices;
    }

    global class ProjectInvoiceWrapper {
        public String project_id;
        public String project_name;
        public Integer overdue_count;
        public Integer unpaid_count;
        public InvoiceDetailsWrapper details;
    }

    global class InvoiceDetailsWrapper {
        public String project_name;
        public String booking_id;
        public String filter_period;
        public List<String> status_filters;
        public String payment_gateway_note;
        public List<InvoiceLineItemWrapper> invoices;
    }

    global class InvoiceLineItemWrapper {
        public String title;
        public String invoice_no;
        public String receipt_no;
        public String amount;
        public String invoice_date;
        public String payment_date;
        public String unpaid_amount;
        public String tds_submission;
        public Integer days_overdue;
        public String document_url;
        public List<String> status;
        public InvoiceActionsWrapper actions;
    }

    global class InvoiceActionsWrapper {
        public Boolean view_invoice;
        public Boolean view_tds;
    }
}