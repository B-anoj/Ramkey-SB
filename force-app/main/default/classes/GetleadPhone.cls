/*
 Modified by: Pundareeka S
	Modified on: 09/11/2024
 */
public without sharing class GetleadPhone { 
    @InvocableMethod(label = 'Search Leads with Phone Number')
    public static List<List<Lead>> getLeads(List<String> phoneNumbers) {   
        String phoneNumberPattern = '%' + phoneNumbers[0] + '%';  
        
        // Get all fields dynamically
        Map<String, Schema.SObjectField> leadFieldsMap = Lead.SObjectType.getDescribe().fields.getMap();
        String allFields = String.join(new List<String>(leadFieldsMap.keySet()), ',');
        
        // Query with all fields, checking Phone, Phone_2__c, and Name fields
        String queryString = 'SELECT ' + allFields + 
                             ' FROM Lead WHERE (Phone LIKE :phoneNumberPattern ' + 
                             'OR Phone_2__c LIKE :phoneNumberPattern ' + 
                             'OR Name LIKE :phoneNumberPattern)';
        List<Lead> leads = Database.query(queryString);
        
        return new List<List<Lead>>{leads};
    }
}