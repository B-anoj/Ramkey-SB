public class SobjectLoadAssignmentHelper {
    Public Static Map<Id,Assignment_Group__c> rv_MapOfAGIdByAG = new Map<Id,Assignment_Group__c>();
    Public Static Map<Id,List<Assignment_Group_Member__c>> rv_MapOfAGIDByASMList = new Map<Id,List<Assignment_Group_Member__c>>();
    
    Public static void ExecuteSobjectOwnerAssignment(List<Sobject> sObjectList,String GroupId,Id queueId){
        Integer lastAllocatedId = 0;
        rv_MapOfAGIdByAG = SobjectLoadAssignmentUtility.GetassigmentGroup();
        SobjectLoadAssignment.GetAssignMentGroupMemberAndAssignmentGroup();
        Map<id,List<Assignment_Group_Member__c>> assignmentGroupMembers = SobjectLoadAssignmentUtility.assignmentGroupMembers();
        if (assignmentGroupMembers.containsKey(GroupId) && assignmentGroupMembers.get(GroupId) != null && SobjectLoadAssignment.rv_MapOfAGIDByASMList.containsKey(GroupId) && SobjectLoadAssignment.rv_MapOfAGIDByASMList.get(GroupId) != null) {
            if (assignmentGroupMembers.get(GroupId).size() == SobjectLoadAssignment.rv_MapOfAGIDByASMList.get(GroupId)[0].Last_Allocated_RRID__c) {
                lastAllocatedId = 1;
            } else {
                if (rv_MapOfAGIdByAG.containsKey(GroupId) && rv_MapOfAGIdByAG.get(GroupId) != null) {
                    Integer lastAllocatedRRId = rv_MapOfAGIdByAG.get(GroupId).Last_Allocated_RRid__c != null 
                        ? (Integer) rv_MapOfAGIdByAG.get(GroupId).Last_Allocated_RRid__c + 1
                        : 1;
                    lastAllocatedId = lastAllocatedRRId;
                } else {
                    lastAllocatedId = 1; 
                }
            }
        } else {
            lastAllocatedId = 1; 
        }
        List<Assignment_Group_Member__c> groupMembers = SobjectLoadAssignment.rv_MapOfAGIDByASMList.get(GroupId);
        Integer totalMembers;
        if(groupMembers!= null){
            totalMembers  = groupMembers.size();
        }
        
        Map<Id,Integer> caseCounts = SobjectLoadAssignmentUtility.getCaseCount(GroupId);
        Integer totalCaseCount = 0;
        for (Integer count : caseCounts.values()) {
            totalCaseCount += count;
        }
        System.debug('Display Total Case Count:'+totalCaseCount);
        Set<Integer> numbers = new Set<Integer>();
        System.debug('Display Queue Ids:'+SobjectLoadAssignment.rv_MapOfAGIDByASMList.get(GroupId));
        if(SobjectLoadAssignment.rv_MapOfAGIDByASMList.get(GroupId) != null){
            
            for(Assignment_Group_Member__c agm:SobjectLoadAssignment.rv_MapOfAGIDByASMList.get(GroupId)){
                numbers.add((Integer)agm.Assignment_Id__c);  
                
            }
            System.debug('Numbers:'+numbers);
            Integer lastRId = lastAllocatedId -1;
            System.debug('lastRId:'+lastRId);
            if((Integer)rv_MapOfAGIdByAG.get(GroupId).Max_Sobject_Assignment_Count__c > totalCaseCount){
                System.debug('Show Max_Sobject_Assignment_Count__c'+ (Integer)rv_MapOfAGIdByAG.get(GroupId).Max_Sobject_Assignment_Count__c);
                System.debug('Display sObjectList:'+sObjectList);
                for(Sobject objectRec : sObjectList){
                    
                    if (!numbers.contains(lastAllocatedId)) {
                        Integer nextAllocatedId = null;
                        for (Integer number1 : numbers) {
                            if (number1 > lastAllocatedId) {
                                nextAllocatedId = number1;
                                break;
                            }
                        }
                        if (nextAllocatedId == null) {
                            lastAllocatedId = 1;
                            if(!numbers.contains(lastAllocatedId)){  
                                List<Integer> sortedNumbers = new List<Integer>(numbers);
                                sortedNumbers.sort();
                                for (Integer number1 : sortedNumbers) {
                                    if (number1 > 1) {
                                        lastAllocatedId = number1;
                                        break;
                                    }
                                }
                            }
                        } else {
                            lastAllocatedId = nextAllocatedId;
                        }
                        System.debug('Allocated Ids:'+lastAllocatedId);
                    }
                    for(Assignment_Group_Member__c agm : SobjectLoadAssignment.rv_MapOfAGIDByASMList.get(GroupId)){
                        if(caseCounts.get(agm.Id) == null){
                            caseCounts.put(agm.Id, 0);
                            System.debug('Show Case Counts:'+caseCounts);
                        }
                        if(lastAllocatedId == agm.Assignment_Id__c){
                            if(agm.Max_Sobject_Assignment_Count__c > caseCounts.get(agm.Id) && !agm.Out_Of_Office__c && agm.Active__c == true){
                                objectRec.put('OwnerId',agm.Group_Member__c) ;
                                //objectRec.put('Pre_Sales_Team_Member__c',agm.Group_Member__c);
                                objectRec.put('AGM_Related_to__c',agm.Id);
                                objectRec.put('AG_Related_to__c',agm.Assignment_Group__c);
                                objectRec.put('Is_User_Assigned__c',true);
                                objectRec.put('Status','Assigned');
                                //objectRec.put('Lead_Assigned_Date_Time__c', Datetime.now());
                                totalCaseCount +=1;
                                caseCounts.put(agm.Id, caseCounts.get(agm.Id) + 1);
                                lastRId = lastAllocatedId;
                                lastAllocatedId = (assignmentGroupMembers.get(GroupId).size() == lastAllocatedId) ? 1 : lastAllocatedId + 1;
                                break;
                            }else{
                                if (assignmentGroupMembers.containsKey(GroupId) && assignmentGroupMembers.get(GroupId) != null) {
                                    lastAllocatedId = (assignmentGroupMembers.get(GroupId).size() == lastAllocatedId) ? 1 : lastAllocatedId + 1;
                                } else {
                                    lastAllocatedId = 1; 
                                }
                            } 
                            System.debug('Last Allocated Ids:'+lastAllocatedId);
                        }
                    }
                }
                Assignment_Group__c ov_AGTobeUpdated = new Assignment_Group__c();
                ov_AGTobeUpdated.Id = rv_MapOfAGIdByAG.get(GroupId).Id ;
                ov_AGTobeUpdated.Last_Allocated_RRid__c = (lastRId == 0) ? 1 : lastRId;  
                Database.SaveResult agUpdateResult = Database.update(ov_AGTobeUpdated, false);
                Database.SaveResult[] sObjectUpdateResults = Database.update(sObjectList, false);
                
                if (!agUpdateResult.isSuccess()) {
                    for (Database.Error err : agUpdateResult.getErrors()) {
                        System.debug('Assignment Group update failed: ' + err.getMessage());
                    }
                }  
                // Collect successful case Ids
                List<Id> updatedCaseIds = new List<Id>();
                for (Integer i = 0; i < sObjectUpdateResults.size(); i++) {
                    if (!sObjectUpdateResults[i].isSuccess()) {
                        for (Database.Error err : sObjectUpdateResults[i].getErrors()) {
                            System.debug('SObject update failed: ' + err.getMessage());
                        }
                    } else {
                        updatedCaseIds.add((Id)sObjectList[i].get('Id'));
                    }
                }
                
                // Query updated cases with required fields
                List<Case> updatedCases = [SELECT Id, CaseNumber, Subject, Priority, Status, Description, OwnerId FROM Case WHERE Id IN :updatedCaseIds];
                
                // Map of user Ids to emails
                Set<Id> ownerIds = new Set<Id>();
                for (Case c : updatedCases) {
                    if (c.OwnerId != null) {
                        ownerIds.add(c.OwnerId);
                    }
                }
                
                // Query user emails
                Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :ownerIds]);
                
                List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
                
                for (Case c : updatedCases) {
                    if (userMap.containsKey(c.OwnerId) && userMap.get(c.OwnerId).Email != null) {
                        String subject = 'New Case Assigned: ' + c.CaseNumber;
                        String body = 'Hello,\n\nA new case has been assigned to you.\n\n' +
                            'Case Number: ' + c.CaseNumber + '\n' +
                            'Subject: ' + c.Subject + '\n' +
                            'Priority: ' + c.Priority + '\n' +
                            'Status: ' + c.Status + '\n' +
                            'Description: ' + c.Description + '\n\n' +
                            'Please take necessary action.';
                        
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(new String[] { userMap.get(c.OwnerId).Email });
                        email.setSubject(subject);
                        email.setPlainTextBody(body);
                        
                        emailsToSend.add(email);
                    }
                }
                
                if (!emailsToSend.isEmpty()) {
                    Messaging.sendEmail(emailsToSend);
                }
                
            }
        }
    }
}