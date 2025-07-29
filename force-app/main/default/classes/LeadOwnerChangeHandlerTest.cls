@isTest
public class LeadOwnerChangeHandlerTest {
 
    @testSetup

    static void setup() {

        // Create test users with unique usernames

        User user1 = new User(

            Username = 'testuser1_' + DateTime.now().getTime() + '@test.com',

            LastName = 'Test',

            FirstName = 'User1',

            Email = 'testuser1@test.com',

            Alias = 'tuser1',

            TimeZoneSidKey = 'America/Los_Angeles',

            LocaleSidKey = 'en_US',

            EmailEncodingKey = 'UTF-8',

            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,

            LanguageLocaleKey = 'en_US'

        );

        insert user1;

        User user2 = new User(

            Username = 'testuser2_' + DateTime.now().getTime() + '@test.com',

            LastName = 'Test',

            FirstName = 'User2',

            Email = 'testuser2@test.com',

            Alias = 'tuser2',

            TimeZoneSidKey = 'America/Los_Angeles',

            LocaleSidKey = 'en_US',

            EmailEncodingKey = 'UTF-8',

            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,

            LanguageLocaleKey = 'en_US'

        );

        insert user2;

    }
 
    @isTest

    static void testTrackOwnerChangesOnInsert() {

        // Retrieve test user

        User user1 = [SELECT Id, FirstName FROM User WHERE Username LIKE 'testuser1_%@test.com' LIMIT 1];
 
        // Create test leads

        Lead lead1 = new Lead(

            LastName = 'Test',

            Company = 'TestCompany',

            OwnerId = user1.Id

        );
 
        Test.startTest();

        // Insert lead

        insert lead1;
 
        // Retrieve the inserted lead

        Lead insertedLead = [SELECT Id, All_Lead_Owners__c FROM Lead WHERE Id = :lead1.Id LIMIT 1];
 
        // Verify All_Lead_Owners__c is set correctly

        System.assertNotEquals(null, insertedLead.All_Lead_Owners__c);

        System.assert(insertedLead.All_Lead_Owners__c.contains(user1.FirstName));

        Test.stopTest();

    }
 
    @isTest

    static void testTrackOwnerChangesOnUpdate() {

        // Retrieve test users

        User user1 = [SELECT Id, FirstName FROM User WHERE Username LIKE 'testuser1_%@test.com' LIMIT 1];

        User user2 = [SELECT Id, FirstName FROM User WHERE Username LIKE 'testuser2_%@test.com' LIMIT 1];
 
        // Create and insert test lead

        Lead lead = new Lead(

            LastName = 'Test',

            Company = 'TestCompany',

            OwnerId = user1.Id

        );

        insert lead;
 
        // Verify initial owner in All_Lead_Owners__c after insert

        Lead insertedLead = [SELECT Id, All_Lead_Owners__c FROM Lead WHERE Id = :lead.Id LIMIT 1];

        System.assertNotEquals(null, insertedLead.All_Lead_Owners__c);

        System.assert(insertedLead.All_Lead_Owners__c.contains(user1.FirstName));
 
        // Update the lead's owner

        lead.OwnerId = user2.Id;

        Test.startTest();

        update lead;
 
        // Retrieve the updated lead

        Lead updatedLead = [SELECT Id, All_Lead_Owners__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
 
        // Verify All_Lead_Owners__c is updated correctly

        System.assertNotEquals(null, updatedLead.All_Lead_Owners__c);

        System.assert(updatedLead.All_Lead_Owners__c.contains(user1.FirstName));

        System.assert(updatedLead.All_Lead_Owners__c.contains(user2.FirstName));

        Test.stopTest();

    }

}