/*
 Modified by: Pundareeka S
 Modified on: 14/11/2024
 */
@IsTest
public class GetAllPhoneNumberSearchTestClass {

    @isTest
    static void testGetLeads() {
        // Create test data for Lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Phone = '1234567890',
            Status = 'Open - Not Contacted',
            Projects__c = 'Ramky One Orbit',
            LeadSource = 'Digital Campaign',
            Lead_Sub_Source__c = 'Website',
            Rating = 'Cold'
        );
        insert testLead;
        
        // Call the method being tested
        Test.startTest();
        List<String> phoneNumbers = new List<String>{'1234567890'};
        List<List<Lead>> result = GetleadPhone.getLeads(phoneNumbers);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, result.size(), 'Expected one list of leads');
        List<Lead> leads = result[0];
        System.assertEquals(1, leads.size(), 'Expected one lead');
        Lead retrievedLead = leads[0];
        System.assertEquals(testLead.Id, retrievedLead.Id, 'Lead Id should match');
        System.assertEquals('Test Lead', retrievedLead.Name, 'Lead Name should match');
        System.assertEquals(testLead.Phone, retrievedLead.Phone, 'Lead Phone should match');
    }

    @isTest
    static void testGetContacts() {
        // Create test data for Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Phone = '1234567890'
        );
        insert testContact;
        
        // Call the method being tested
        Test.startTest();
        List<String> phoneNumbers = new List<String>{'1234567890'};
        List<List<Contact>> result = GetContactPhone.getContacts(phoneNumbers);
        Test.stopTest();
        
        // Assertions
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
        // Create test data for Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '1234567890'
        );
        insert testAccount;
        
        // Call the method being tested
        Test.startTest();
        List<String> phoneNumbers = new List<String>{'1234567890'};
        List<List<Account>> result = GetAccountPhone.getAccounts(phoneNumbers);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, result.size(), 'Expected one list of accounts');
        List<Account> accounts = result[0];
        System.assertEquals(1, accounts.size(), 'Expected one account');
        Account retrievedAccount = accounts[0];
        System.assertEquals(testAccount.Id, retrievedAccount.Id, 'Account Id should match');
        System.assertEquals('Test Account', retrievedAccount.Name, 'Account Name should match');
        System.assertEquals(testAccount.Phone, retrievedAccount.Phone, 'Account Phone should match');
    }

    @isTest
    static void testGetOpportunities() {
        // Create test data for Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            Phone__c = '1234567890',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpportunity;
        
        // Call the method being tested
        Test.startTest();
        List<String> phoneNumbers = new List<String>{'1234567890'};
        List<List<Opportunity>> result = GetOpportunityPhone.getOpportunities(phoneNumbers);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, result.size(), 'Expected one list of opportunities');
        List<Opportunity> opportunities = result[0];
        System.assertEquals(1, opportunities.size(), 'Expected one opportunity');
        Opportunity retrievedOpportunity = opportunities[0];
        System.assertEquals(testOpportunity.Id, retrievedOpportunity.Id, 'Opportunity Id should match');
        System.assertEquals('Test Opportunity', retrievedOpportunity.Name, 'Opportunity Name should match');
        System.assertEquals(testOpportunity.Phone__c, retrievedOpportunity.Phone__c, 'Opportunity Phone should match');
    }
}