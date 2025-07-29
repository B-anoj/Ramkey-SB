public class LeadOwnerChangeHandler {

    public static void trackOwnerChangesOnInsert(List<Lead> newLeads) {
        // Collect all OwnerIds
        Set<Id> ownerIds = new Set<Id>();
        for (Lead lead : newLeads) {
            ownerIds.add(lead.OwnerId);
        }

        // Query all the Users in a single SOQL query
        Map<Id, User> ownerMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :ownerIds]);

        // Process each Lead
        for (Lead lead : newLeads) {
            String ownerName = ownerMap.get(lead.OwnerId).Name;
            String timestamp = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
            lead.All_Lead_Owners__c = timestamp + ' - ' + ownerName;
        }
    }

    public static void trackOwnerChangesOnUpdate(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
        // Collect all OwnerIds
        Set<Id> ownerIds = new Set<Id>();
        for (Lead lead : newLeads) {
            ownerIds.add(lead.OwnerId);
        }

        // Query all the Users in a single SOQL query
        Map<Id, User> ownerMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :ownerIds]);

        // Process each Lead
        for (Lead lead : newLeads) {
            Lead oldLead = oldLeadMap.get(lead.Id);

            // Check if the owner has changed
            if (lead.OwnerId != oldLead.OwnerId) {
                String newOwnerName = ownerMap.get(lead.OwnerId).Name;
                String timestamp = DateTime.now().format('yyyy-MM-dd HH:mm:ss');

                // Append the new owner information to All_Lead_Owners__c
                if (String.isNotBlank(lead.All_Lead_Owners__c)) {
                    lead.All_Lead_Owners__c += '\n' + timestamp + ' - ' + newOwnerName;
                } else {
                    lead.All_Lead_Owners__c = timestamp + ' - ' + newOwnerName;
                }
            }
        }
    }
}

/*public class LeadOwnerChangeHandler {
 
    public static void trackOwnerChangesOnInsert(List<Lead> newLeads) {
        for (Lead lead : newLeads) {
            // Retrieve the name of the owner
            String ownerName = [SELECT Name FROM User WHERE Id = :lead.OwnerId].Name;
            String timestamp = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
            // Set the owner information to All_Lead_Owners__c
            lead.All_Lead_Owners__c = timestamp + ' - ' + ownerName;
        }
    }
 
    public static void trackOwnerChangesOnUpdate(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
        for (Lead lead : newLeads) {
            Lead oldLead = oldLeadMap.get(lead.Id);
 
            // Check if the owner has changed
            if (lead.OwnerId != oldLead.OwnerId) {
                // Retrieve the name of the new owner
                String newOwnerName = [SELECT Name FROM User WHERE Id = :lead.OwnerId].Name;
                String timestamp = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
 
                // Append the new owner information to All_Lead_Owners__c
                if (String.isNotBlank(lead.All_Lead_Owners__c)) {
                    lead.All_Lead_Owners__c += '\n' + timestamp + ' - ' + newOwnerName;
                } else {
                    lead.All_Lead_Owners__c = timestamp + ' - ' + newOwnerName;
                }
            }
        }
    }
}*/