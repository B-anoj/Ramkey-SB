global class BatchSAPInvoiceAttachment implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            'SELECT Id, Receipt_No__c, Sales_Document__c FROM Invoice__c WHERE Sales_Document__c != null AND Receipt_No__c != null'
        );
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Invoice__c> invoices = (List<Invoice__c>) scope;
        Set<Id> invoiceIds = new Set<Id>();
        for (Invoice__c inv : invoices) {
            if (String.isNotBlank(inv.Receipt_No__c)) {
                invoiceIds.add(inv.Id);
            }
        }
        Set<Id> alreadyLinkedInvoices = new Set<Id>();
        for (ContentDocumentLink link : [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :invoiceIds
        ]) {
            alreadyLinkedInvoices.add(link.LinkedEntityId);
        }
        
        List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
        Map<Id, Id> invoiceToContentDocId = new Map<Id, Id>(); // Map to hold InvoiceId -> ContentDocumentId
        
        for (Invoice__c inv : invoices) {
            if (alreadyLinkedInvoices.contains(inv.Id)) {
                System.debug('Skipping (already has file): ' + inv.Id);
                continue;
            }
            
            try {
                String baseUrl = Label.SAPInvoiceAttachmentEndPoint;
                String queryParams = '?$DocumentNumber=\'' + inv.Receipt_No__c + '\'&DocumentType=\'INV\'';
                
                HttpRequest req = new HttpRequest();
                req.setEndpoint(baseUrl + queryParams);
                req.setMethod('GET');
                req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(Label.SAPStatementAuth)));
                
                Http http = new Http();
                HttpResponse res = http.send(req);
                
                if (res.getStatusCode() == 200 && res.getBodyAsBlob() != null && res.getBodyAsBlob().size() > 0) {
                    ContentVersion cv = new ContentVersion();
                    cv.Title = inv.Receipt_No__c;
                    cv.PathOnClient = inv.Receipt_No__c + '.pdf';
                    cv.VersionData = res.getBodyAsBlob();
                    cv.Origin = 'H';
                    cv.Description = 'SAP Invoice PDF';
                    contentVersionsToInsert.add(cv);
                    
                    // Temporary store Invoice Id in Description so we can map it later
                    cv.Description = inv.Id;
                } else {
                    System.debug('Failed to get PDF for Invoice: ' + inv.Id + ' | ' + res.getStatus());
                }
                
            } catch (Exception e) {
                System.debug('Exception for Invoice ' + inv.Id + ': ' + e.getMessage());
            }
        }
        
        if (!contentVersionsToInsert.isEmpty()) {
            try {
                insert contentVersionsToInsert;
                
                List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
                for (ContentVersion cv : contentVersionsToInsert) {
                    // Re-query the inserted ContentVersion to get ContentDocumentId
                    ContentVersion insertedCv = [
                        SELECT Id, ContentDocumentId, Description 
                        FROM ContentVersion 
                        WHERE Id = :cv.Id
                        LIMIT 1
                    ];
                    
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = insertedCv.ContentDocumentId;
                    cdl.LinkedEntityId = Id.valueOf(insertedCv.Description);
                    cdl.ShareType = 'V'; // Viewer
                    cdl.Visibility = 'AllUsers';
                    linksToInsert.add(cdl);
                }
                
                insert linksToInsert;
                System.debug('Linked files to invoices: ' + linksToInsert.size());
            } catch (Exception e) {
                System.debug('Error inserting ContentVersion or linking: ' + e.getMessage());
            }
        } else {
            System.debug('No new PDFs to insert.');
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        BatchGeneratePublicInvoiceUrl batch = new BatchGeneratePublicInvoiceUrl();
        DataBase.ExecuteBatch(batch);
        System.debug('BatchSAPInvoiceAttachment execution completed.');
    }
}