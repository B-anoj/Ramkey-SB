trigger LeadFromGoogleTrigger on Lead (After insert) {
 
    // A map to hold unique records by Phone and Projects combination
    Map<String, Lead> uniqueRecordsMap = new Map<String, Lead>();
    List<Lead> duplicateRecords = new List<Lead>();
        Set<Id> duplicateRecordIds = new Set<Id>();
   

    // Collect unique Phone and Projects combinations for new records where LeadSource is 'Google'
    for (Lead newLead : Trigger.new) {
        if (newLead.Lead_Sub_Source__c =='Google') {
            String key = newLead.Phone + '-' + newLead.Projects__c;
         
            if (!uniqueRecordsMap.containsKey(key)) {
                uniqueRecordsMap.put(key, newLead);
            }
           else { 
              duplicateRecords.add(newLead);
            }
        }
    }   
     System.debug('data'+ duplicateRecords);
     System.debug('Unipuedata'+ uniqueRecordsMap);
      for (Lead duplicateLead : duplicateRecords) {
            duplicateRecordIds.add(duplicateLead.Id);
        }
   System.debug('data'+ duplicateRecordIds);
    if (!duplicateRecordIds.isEmpty()) {
            delete [SELECT Id FROM Lead WHERE Id IN :duplicateRecordIds];
        }
}