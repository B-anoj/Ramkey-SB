/*
 Modified by: Pundareeka S
	Modified on: 09/11/2024
 */
public class GetAccountPhone {
    @InvocableMethod(label = 'Search Accounts with Phone Number')
    public static List<List<Account>> getAccounts(List<String> phoneNumbers) {
        String phoneNumberPattern = '%' + phoneNumbers[0] + '%'; 

        // Get all fields dynamically
        Map<String, Schema.SObjectField> accountFieldsMap = Account.SObjectType.getDescribe().fields.getMap();
        List<String> allFields = new List<String>(accountFieldsMap.keySet());
        String fieldsString = String.join(allFields, ',');

        // Query with all fields, checking Phone, Phone_2__c, and Name fields
        String queryString = 'SELECT ' + fieldsString + 
                             ' FROM Account WHERE (Phone LIKE :phoneNumberPattern ' + 
                             'OR Phone_2__c LIKE :phoneNumberPattern ' + 
                             'OR Name LIKE :phoneNumberPattern)';
        List<Account> accounts = Database.query(queryString);

        return new List<List<Account>>{accounts};
    }
}