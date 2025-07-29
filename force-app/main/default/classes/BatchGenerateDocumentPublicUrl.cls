global class BatchGenerateDocumentPublicUrl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            FROM Document__c
            WHERE Document_Link__c = null
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Document__c> scope) {
        try {
            if (scope.isEmpty()) return;
            
            Set<Id> documentIds = new Set<Id>();
            for (Document__c doc : scope) {
                documentIds.add(doc.Id);
            }
            Map<Id, Id> documentToContentDocMap = new Map<Id, Id>();
            Set<Id> contentDocIds = new Set<Id>();
            
            for (ContentDocumentLink link : [
                SELECT LinkedEntityId, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :documentIds
            ]) {
                documentToContentDocMap.put(link.LinkedEntityId, link.ContentDocumentId);
                contentDocIds.add(link.ContentDocumentId);
            }
            
            if (contentDocIds.isEmpty()) return;
            
            Map<Id, Id> contentDocToVersionId = new Map<Id, Id>();
            for (ContentVersion ver : [
                SELECT Id, ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocIds
                AND IsLatest = true
            ]) {
                contentDocToVersionId.put(ver.ContentDocumentId, ver.Id);
            }
            List<ContentDistribution> distributionsToInsert = new List<ContentDistribution>();
            Map<Id, Id> documentToVersionId = new Map<Id, Id>(); 
            
            for (Id docId : documentToContentDocMap.keySet()) {
                Id contentDocId = documentToContentDocMap.get(docId);
                if (contentDocToVersionId.containsKey(contentDocId)) {
                    Id versionId = contentDocToVersionId.get(contentDocId);
                    ContentDistribution cd = new ContentDistribution();
                    cd.Name = 'PublicLink_' + contentDocId;
                    cd.ContentVersionId = versionId;
                    cd.PreferencesAllowViewInBrowser = true;
                    cd.PreferencesLinkLatestVersion = true;
                    cd.PreferencesNotifyOnVisit = false;
                    cd.PreferencesAllowOriginalDownload = true;
                    cd.PreferencesAllowViewInBrowser = true;
                    distributionsToInsert.add(cd);
                    documentToVersionId.put(docId, versionId);
                }
            }
            
            if (!distributionsToInsert.isEmpty()) {
                insert distributionsToInsert;
            }
            Map<Id, String> versionIdToUrl = new Map<Id, String>();
            for (ContentDistribution cd : [
                SELECT ContentVersionId, DistributionPublicUrl
                FROM ContentDistribution
                WHERE ContentVersionId IN :documentToVersionId.values()
            ]) {
                versionIdToUrl.put(cd.ContentVersionId, cd.DistributionPublicUrl);
            }
            List<Document__c> docsToUpdate = new List<Document__c>();
            for (Id docId : documentToVersionId.keySet()) {
                Id versionId = documentToVersionId.get(docId);
                if (versionIdToUrl.containsKey(versionId)) {
                    docsToUpdate.add(new Document__c(
                        Id = docId,
                        Document_Link__c = versionIdToUrl.get(versionId)
                    ));
                }
            }
            
            if (!docsToUpdate.isEmpty()) {
                update docsToUpdate;
            }
            
        } catch (Exception e) {
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        Database.executeBatch(new BatchInvoiceDetails(), 1);
        System.debug('Public URL Batch Completed Successfully');
    }
}