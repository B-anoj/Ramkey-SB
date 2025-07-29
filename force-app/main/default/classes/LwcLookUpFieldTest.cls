@isTest
public class LwcLookUpFieldTest {

    @isTest
    static void testFetchLookupData() {
        // Insert a sample Account (or any other object) for testing
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Test the fetchLookupData method
        Test.startTest();
        List<sObject> result = LwcLookUpField.fetchLookupData('Test', 'Account');
        Test.stopTest();

        // Assert that the result contains the test data
        System.assertNotEquals(0, result.size());
    }

    @isTest
    static void testFetchDefaultRecord() {
        // Insert a sample Account for testing
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Test the fetchDefaultRecord method
        Test.startTest();
        sObject result = LwcLookUpField.fetchDefaultRecord(testAccount.Id, 'Account');
        Test.stopTest();

        // Assert that the result matches the inserted account
        System.assertNotEquals(null, result);
        System.assertEquals(testAccount.Id, result.Id);
    }
}