public without sharing class InvoiceController {

    public class InvoiceWithFiles {
        @AuraEnabled public Invoice__c invoice;
        @AuraEnabled public String documentLink; 
        @AuraEnabled public String fileName;    
    }

    @AuraEnabled(cacheable=true)
    public static List<InvoiceWithFiles> getInvoices() {
        List<InvoiceWithFiles> result = new List<InvoiceWithFiles>();

        try {
            List<Invoice__c> invoices = [
                SELECT Id, Name, Receipt_No__c, Status__c, TDS_Status__c,
                       Amount__c, Description__c, CreatedDate, Document_Link__c
                FROM Invoice__c
                ORDER BY CreatedDate ASC
            ];

            for (Invoice__c inv : invoices) {
                InvoiceWithFiles wrapper = new InvoiceWithFiles();
                wrapper.invoice = inv;
                wrapper.documentLink = inv.Document_Link__c;
                if (inv.Document_Link__c != null && inv.Document_Link__c.contains('/')) {
                    String[] parts = inv.Document_Link__c.split('/');
                    wrapper.fileName = parts.isEmpty() ? 'Invoice Document' : parts[parts.size() - 1];
                } else {
                    wrapper.fileName = 'Invoice Document';
                }
                result.add(wrapper);
            }

        } catch (Exception e) {
            System.debug('Error at LineNumber====>' + e.getLineNumber() + ' Message===>' + e.getMessage());
        }

        return result;
    }
}