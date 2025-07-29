global class BatchSAPBookingDocuments implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            'SELECT Id, Sales_Document__c FROM Booking_Form__c WHERE Sales_Document__c != null'
        );
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Booking_Form__c> bookingForms = (List<Booking_Form__c>) scope;
        
        for (Booking_Form__c form : bookingForms) {
            String docId = form.Sales_Document__c;
            
            try {
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                String baseUrl = Label.SAPDocumentList;
                String queryParams = '?$DocumentNumber=\'' + docId + '\'';
                req.setEndpoint(baseUrl + queryParams);
                
                String basicAuth = 'Basic ' + EncodingUtil.base64Encode(
                    Blob.valueOf(Label.SAPStatementAuth)
                );
                req.setHeader('Authorization', basicAuth);
                
                Http http = new Http();
                HttpResponse res = http.send(req);
                
                if (res.getStatusCode() == 200) {
                    APILoggerController.fetchSAPResponse(res.getStatusCode(), res.getBody());
                    
                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    Map<String, Object> bookingListSet = (Map<String, Object>) jsonResponse.get('BookingDocumentListSet');
                    List<Object> documentList = (List<Object>) bookingListSet.get('BookingDocumentList');
                    
                    Set<String> existingKeys = new Set<String>();
                    Set<String> docTypes = new Set<String>();
                    Map<String, Document__c> newDocMap = new Map<String, Document__c>();
                    
                    for (Object docObj : documentList) {
                        Map<String, Object> docMap = (Map<String, Object>) docObj;
                        String salesDocId = (String) docMap.get('SalesDocument');
                        String fileName = (String) docMap.get('FileName');
                        String docType = (String) docMap.get('DocumentType');
                        String key = salesDocId + ':' + docType;
                        docTypes.add(docType);
                        
                        newDocMap.put(key, new Document__c(
                            Sales_Document__c = salesDocId,
                            Name = fileName,
                            Document_Type__c = docType,
                            Booking_Form__c = form.Id
                        ));
                    }
                    
                    List<Document__c> existingDocs = [
                        SELECT Id, Sales_Document__c, Document_Type__c
                        FROM Document__c
                        WHERE Sales_Document__c = :docId AND Document_Type__c IN :docTypes
                    ];
                    
                    for (Document__c existing : existingDocs) {
                        String key = existing.Sales_Document__c + ':' + existing.Document_Type__c;
                        existingKeys.add(key);
                    }
                    
                    List<Document__c> finalToInsert = new List<Document__c>();
                    for (String key : newDocMap.keySet()) {
                        if (!existingKeys.contains(key)) {
                            finalToInsert.add(newDocMap.get(key));
                        }
                    }
                    
                    if (!finalToInsert.isEmpty()) {
                        insert finalToInsert;
                        System.debug('Inserted documents: ' + finalToInsert.size());
                    } else {
                        System.debug('No new documents to insert for docId: ' + docId);
                    }
                    
                } else {
                    System.debug('Error response: ' + res.getStatus() + ' => ' + res.getBody());
                    APILoggerController.fetchSAPResponse(res.getStatusCode(), res.getBody());
                }
                
            } catch (Exception ex) {
                System.debug('Exception while calling Booking Documents API for docId ' + docId + ': ' + ex.getMessage());
                System.debug('Exception Line Number API: ' + ex.getLineNumber());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
       Database.executeBatch(new BatchSAPDocumentAttachment(), 1);
        System.debug('BatchSAPBookingDocuments finished.');
        
    }
}