public with sharing class CloseCaseController {
    @AuraEnabled
    public static void closeCase(Id caseId) {
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Id = :caseId LIMIT 1];
        
        if (!cases.isEmpty()) {
            Case c = cases[0];
            c.Status = 'Closed'; // Make sure "Closed" is a valid status in your org
            update c;
        } else {
            throw new AuraHandledException('No Case record found with the given Id.');
        }
    }
}