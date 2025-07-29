public without sharing class LetsTalkMetadataController {

    public class ProjectMetadataWrapper {
        @AuraEnabled public String projectName;
        @AuraEnabled public String propertyAddress;
        @AuraEnabled public String email;
        @AuraEnabled public String crmContact;
        @AuraEnabled public String corporateAddress;
        @AuraEnabled public String contactPerson;
    }

    @AuraEnabled(cacheable=true)
    public static List<ProjectMetadataWrapper> getProjectMetadataForLoggedInUser() {
        String contactEmail = 'dhayalan2531@gmail.com'; // Replace with actual dynamic logic for logged-in user

        // Step 1: Get the Contact with Account
        Contact con = [
            SELECT Id, AccountId 
            FROM Contact 
            WHERE Email = :contactEmail 
            LIMIT 1
        ];

        if (con.AccountId == null) {
            return new List<ProjectMetadataWrapper>();
        }

        // Step 2: Fetch all related Opportunity names under the Account
        List<Opportunity> oppList = [
            SELECT Name, Projects__c 
            FROM Opportunity 
            WHERE AccountId = :con.AccountId
        ];

        Set<String> projectNames = new Set<String>();
        for (Opportunity opp : oppList) {
            if (!String.isBlank(opp.Name)) {
                projectNames.add(opp.Projects__c.trim());
            }
        }

        if (projectNames.isEmpty()) {
            return new List<ProjectMetadataWrapper>();
        }

        // Step 3: Fetch Custom Metadata Records that match project names
        List<Ramky_Projects__mdt> metaList = [
            SELECT MasterLabel, Property_Address__c, Email__c, CRM_Contact__c, Corporate_Address__c, Contact_Person__c
            FROM Ramky_Projects__mdt
            WHERE MasterLabel IN :projectNames
        ];

        // Step 4: Prepare the result
        List<ProjectMetadataWrapper> results = new List<ProjectMetadataWrapper>();
        for (Ramky_Projects__mdt m : metaList) {
            ProjectMetadataWrapper wrapper = new ProjectMetadataWrapper();
            wrapper.projectName = m.MasterLabel;
            wrapper.propertyAddress = m.Property_Address__c;
            wrapper.email = m.Email__c;
            wrapper.crmContact = m.CRM_Contact__c;
            wrapper.corporateAddress = m.Corporate_Address__c;
            wrapper.contactPerson = m.Contact_Person__c;
            results.add(wrapper);
        }

        return results;
    }
}