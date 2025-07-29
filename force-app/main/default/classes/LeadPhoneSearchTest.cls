@isTest
private class LeadPhoneSearchTest {
    @isTest
    static void testCheckPhoneExists() {
        // Test when phone number exists in Lead
        Lead testLead = new Lead(Phone = '1234567890', LastName = 'Test Lead', Company = 'Test Company');
        insert testLead;

        System.assertEquals(true, LeadPhoneSearch.checkPhoneExists('1234567890'));

        // Test when phone number exists in Account
        Account testAccount = new Account(Phone = '9876543210', Name = 'Test Account');
        insert testAccount;

        System.assertEquals(true, LeadPhoneSearch.checkPhoneExists('9876543210'));

        // Test when phone number exists in Contact
        Contact testContact = new Contact(Phone = '5678901234', LastName = 'Test Contact');
        insert testContact;

        System.assertEquals(true, LeadPhoneSearch.checkPhoneExists('5678901234'));

        // Test when phone number does not exist
        System.assertEquals(false, LeadPhoneSearch.checkPhoneExists('0000000000'));
    }

    @isTest
    static void testGetLeadDetails() {
        // Create test data
        Lead testLead = new Lead(Phone = '1234567890', LastName = 'Test Lead', LeadSource = 'Web', Company = 'Test Company');
        insert testLead;

        Account testAccount = new Account(Phone = '9876543210', Name = 'Test Account', AccountSource = 'Phone Inquiry');
        insert testAccount;

        Contact testContact = new Contact(Phone = '5678901234', LastName = 'Test Contact');
        insert testContact;

        // Test when records exist
        List<LeadPhoneSearch.RecordWrapper> records = LeadPhoneSearch.getLeadDetails('1234567890');

        System.assertEquals(1, records.size());

        // Check lead record
        LeadPhoneSearch.RecordWrapper leadRecord = records[0];
        System.assertEquals('Lead', leadRecord.type);
        System.assertEquals(testLead.Id, leadRecord.Id);
        System.assertEquals('Test Lead', leadRecord.Name);
        System.assertEquals('1234567890', leadRecord.Phone);
        System.assertEquals('Web', leadRecord.LeadSource);
        System.assertEquals(null, leadRecord.AccountSource); // Account-specific field should be null
        System.assertEquals(null, leadRecord.AccountOwner); // Account-specific field should be null
    }
}