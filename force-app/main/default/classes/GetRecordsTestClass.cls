@IsTest
public class GetRecordsTestClass {

     @isTest
    static void testGetLeads() {
        // Create test data
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Phone = '1234567890' // Set a phone number for testing
        );
        insert testLead;
        
        // Call the method being tested
        Test.startTest();
        List<String> phoneNumbers = new List<String>{'1234567890'};
        List<List<Lead>> result = GetleadPhone.getLeads(phoneNumbers);
        Test.stopTest();
        
        // Assert that the result contains expected data
        System.assertEquals(1, result.size(), 'Expected one list of leads');
        List<Lead> leads = result[0];
        System.assertEquals(1, leads.size(), 'Expected one lead');
        Lead retrievedLead = leads[0];
        System.assertEquals(testLead.Id, retrievedLead.Id, 'Lead Id should match');
        System.assertEquals('Test Lead', retrievedLead.Name, 'Lead Name should match');
        System.assertEquals(testLead.Projects__c, retrievedLead.Projects__c, 'Lead Projects should match');
        System.assertEquals(testLead.Phone, retrievedLead.Phone, 'Lead Phone should match');
        System.assertEquals('Open- Not Contacted', retrievedLead.Status, 'Lead Status should match');
        
    }
    
    
    @isTest
    static void testGetContacts() {
        // Create test data
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Phone = '1234567890' // Set a phone number for testing
        );
        insert testContact;
        
        // Call the method being tested
        Test.startTest();
        List<String> phoneNumbers = new List<String>{'1234567890'};
        List<List<Contact>> result = GetContactPhone.getContacts(phoneNumbers);
        Test.stopTest();
        
        // Assert that the result contains expected data
        System.assertEquals(1, result.size(), 'Expected one list of contacts');
        List<Contact> contacts = result[0];
        System.assertEquals(1, contacts.size(), 'Expected one contact');
        Contact retrievedContact = contacts[0];
        System.assertEquals(testContact.Id, retrievedContact.Id, 'Contact Id should match');
        System.assertEquals('Test Contact', retrievedContact.Name, 'Contact Name should match');
        System.assertEquals(testContact.Phone, retrievedContact.Phone, 'Contact Phone should match');
        
    }
    
    @isTest
    static void testGetAccounts() {
        // Create test data
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '1234567890' // Set a phone number for testing
        );
        insert testAccount;
        
        // Call the method being tested
        Test.startTest();
        List<String> phoneNumbers = new List<String>{'1234567890'};
        List<List<Account>> result = GetAccountPhone.getAccounts(phoneNumbers);
        Test.stopTest();
        
        // Assert that the result contains expected data
        System.assertEquals(1, result.size(), 'Expected one list of accounts');
        List<Account> accounts = result[0];
        System.assertEquals(1, accounts.size(), 'Expected one account');
        Account retrievedAccount = accounts[0];
        System.assertEquals(testAccount.Id, retrievedAccount.Id, 'Account Id should match');
        System.assertEquals('Test Account', retrievedAccount.Name, 'Account Name should match');
        System.assertEquals(testAccount.Phone, retrievedAccount.Phone, 'Account Phone should match');
      
    }
}