public without sharing class CaseTriggerHeper {
    static CaseTriggerHeper handlerInstance;
    public static CaseTriggerHeper getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new CaseTriggerHeper();
        return handlerInstance;
    }
    public void onBeforeInsert(List<Case> newrecords){
        System.debug('newrecords==>'+newrecords);
        if(!newRecords.isEmpty()){
            Group que = [select id,Name from Group where Name ='caseAssignmentQueue'];
            for(Case cs : newRecords){
                if(cs.Origin == 'Phone' || cs.Origin == 'Web'){
                    
                    // cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Support').getRecordTypeId();
                    cs.Status = 'New';
                    cs.OwnerId    =que.id;
                    cs.Is_User_Assigned__c = false;
                }else{
                    // cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QA Support').getRecordTypeId();
                    cs.OwnerId     =que.id;
                    cs.Is_User_Assigned__c = false;
                }
            }
        }
    }
}