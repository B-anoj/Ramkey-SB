global class BatchSAPDocumentAttachment implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            'SELECT Id, Document_Type__c, Name, Sales_Document__c FROM Document__c WHERE Sales_Document__c != null'
        );
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Document__c> documents = (List<Document__c>) scope;
        Set<Id> docIds = new Set<Id>();
        for (Document__c doc : documents) {
            docIds.add(doc.Id);
        }
        Set<Id> alreadyLinked = new Set<Id>();
        for (ContentDocumentLink link : [
            SELECT LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :docIds
        ]) {
            alreadyLinked.add(link.LinkedEntityId);
        }
        
        List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
        Map<Id, Id> documentIdToVersionMap = new Map<Id, Id>(); 
        for (Document__c doc : documents) {
            if (alreadyLinked.contains(doc.Id)) {
                System.debug('Skipping document (already has a file): ' + doc.Id);
                continue;
            }
            
            try {
                String baseUrl = Label.SAPDocumentAttachment;
                String queryParams = '?$DocumentNumber=\'' + doc.Sales_Document__c + '\'&DocumentType=\'' + doc.Document_Type__c + '\'';
                
                HttpRequest req = new HttpRequest();
                req.setEndpoint(baseUrl + queryParams);
                req.setMethod('GET');
                req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(Label.SAPStatementAuth)));
                
                Http http = new Http();
                HttpResponse res = http.send(req);
                
                if (res.getStatusCode() == 200 && res.getBodyAsBlob() != null && res.getBodyAsBlob().size() > 0) {
                    ContentVersion cv = new ContentVersion();
                    cv.Title = doc.Name;
                    cv.PathOnClient = doc.Name.endsWith('.pdf') ? doc.Name : doc.Name + '.pdf';
                    cv.VersionData = res.getBodyAsBlob();
                    contentVersionsToInsert.add(cv);
                    documentIdToVersionMap.put(doc.Id, null); 
                    
                    System.debug('Prepared ContentVersion for: ' + doc.Id);
                } else {
                    System.debug('Failed to fetch file for docId: ' + doc.Sales_Document__c);
                    APILoggerController.fetchSAPResponse(res.getStatusCode(), res.getBody());
                }
                
            } catch (Exception e) {
                System.debug('Error processing docId: ' + doc.Id + ' → ' + e.getMessage());
                APILoggerController.fetchSAPResponse(500, e.getMessage());
            }
        }
        if (!contentVersionsToInsert.isEmpty()) {
            try {
                insert contentVersionsToInsert;
                List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
                Integer i = 0;
                for (Id docId : documentIdToVersionMap.keySet()) {
                    if (i >= contentVersionsToInsert.size()) break;
                    ContentVersion cv = contentVersionsToInsert[i];
                    documentIdToVersionMap.put(docId, cv.Id);
                    i++;
                }
                List<ContentVersion> insertedVersions = [
                    SELECT Id, ContentDocumentId
                    FROM ContentVersion
                    WHERE Id IN :documentIdToVersionMap.values()
                ];
                
                Map<Id, Id> versionToContentDocMap = new Map<Id, Id>();
                for (ContentVersion v : insertedVersions) {
                    versionToContentDocMap.put(v.Id, v.ContentDocumentId);
                }
                
                for (Id docId : documentIdToVersionMap.keySet()) {
                    Id versionId = documentIdToVersionMap.get(docId);
                    Id contentDocId = versionToContentDocMap.get(versionId);
                    if (contentDocId != null) {
                        ContentDocumentLink link = new ContentDocumentLink();
                        link.LinkedEntityId = docId;
                        link.ContentDocumentId = contentDocId;
                        link.ShareType = 'V'; 
                        link.Visibility = 'AllUsers';
                        linksToInsert.add(link);
                    }
                }
                
                if (!linksToInsert.isEmpty()) {
                    insert linksToInsert;
                    System.debug('Linked files to ' + linksToInsert.size() + ' Document__c records.');
                }
                
            } catch (Exception ex) {
                System.debug('Insert error: ' + ex.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        Database.executeBatch(new BatchGenerateDocumentPublicUrl(), 200);
        System.debug('BatchSAPDocumentAttachment execution completed.');
    }
}