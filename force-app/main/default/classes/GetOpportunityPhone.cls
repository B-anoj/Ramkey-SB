/*
 Created by: Pundareeka S
	Created on: 09/11/2024
 */
public class GetOpportunityPhone{ 
    @InvocableMethod(label = 'Search Opportunity with Phone Number')
    public static List<List<Opportunity>> getOpportunities(List<String> phoneNumbers) {
        String phoneNumberPattern = '%' + phoneNumbers[0] + '%'; // Assuming only one phone number is passed
        
        // Get all fields dynamically
        Map<String, Schema.SObjectField> opportunityFieldsMap = Opportunity.SObjectType.getDescribe().fields.getMap();
        List<String> allFields = new List<String>(opportunityFieldsMap.keySet());
        String fieldsString = String.join(allFields, ',');
        
        // Query with all fields, checking Phone, Phone_2__c, and Name fields
        String queryString = 'SELECT ' + fieldsString + 
                             ' FROM Opportunity WHERE (Phone__c LIKE :phoneNumberPattern ' +  
                             'OR Phone_2__c LIKE :phoneNumberPattern ' + 
                             'OR Name LIKE :phoneNumberPattern)';
        List<Opportunity> opportunities = Database.query(queryString);
        
        return new List<List<Opportunity>>{opportunities};
    }
}