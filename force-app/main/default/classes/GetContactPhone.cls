/*
 Modified by: Pundareeka S
	Modified on: 09/11/2024
 */
public class GetContactPhone { 
    @InvocableMethod(label = 'Search Contact with Phone Number')
    public static List<List<Contact>> getContacts(List<String> phoneNumbers) {
        String phoneNumberPattern = '%' + phoneNumbers[0] + '%'; 
        
        // Get all fields dynamically
        Map<String, Schema.SObjectField> contactFieldsMap = Contact.SObjectType.getDescribe().fields.getMap();
        List<String> allFields = new List<String>(contactFieldsMap.keySet());
        String fieldsString = String.join(allFields, ',');
        
        // Query with all fields, checking Phone, Phone_2__c, and Name fields
        String queryString = 'SELECT ' + fieldsString + 
                             ' FROM Contact WHERE (Phone LIKE :phoneNumberPattern ' + 
                             'OR Phone_2__c LIKE :phoneNumberPattern ' + 
                             'OR Name LIKE :phoneNumberPattern)';
        List<Contact> contacts = Database.query(queryString);
        
        return new List<List<Contact>>{contacts};
    }
}