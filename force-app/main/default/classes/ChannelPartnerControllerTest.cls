@isTest
public class ChannelPartnerControllerTest {

    @isTest
    static void testGetChannelPartnerDetails() {
        // Step 1: Setup Test Data
        Channel_Partner_Details__c cpDetail = new Channel_Partner_Details__c(
            Company_Individual_Name__c = 'Test Company',
            //Contact_Person_Name__c = 'John Doe',
            Email_Address__c = 'john.doe@example.com',
            Phone_Number__c = '9876543210',
            Channel_Partner_RERA_Number__c = 'RERA123',
            City__c = 'Mumbai',
            Country__c = 'India',
            Door_No__c = '101',
            PINCODE__c = '400001',
            State__c = 'Maharashtra',
            Street1__c = 'Main Street',
            Street2__c = 'Building 5'
        );
        insert cpDetail;

        // Step 2: Test the getChannelPartnerDetails method
        Test.startTest();
        Channel_Partner_Details__c result = ChannelPartnerController.getChannelPartnerDetails('RERA123');
        Test.stopTest();

        // Step 3: Validate the results
        System.assertNotEquals(null, result, 'Channel Partner details should not be null');
        System.assertEquals('Test Company', result.Company_Individual_Name__c, 'Company name should match');
        //System.assertEquals('John Doe', result.Contact_Person_Name__c, 'Contact person name should match');
        System.assertEquals('john.doe@example.com', result.Email_Address__c, 'Email address should match');
    }

    @isTest
    static void testGetChannelPartnerDetails_NoResults() {
        // Step 1: Test when no results are found for the given RERA number
        Test.startTest();
        Channel_Partner_Details__c result = ChannelPartnerController.getChannelPartnerDetails('RERA999');
        Test.stopTest();

        // Step 2: Validate that no result is returned
        System.assertEquals(null, result, 'No Channel Partner details should be found');
    }

    @isTest
    static void testSaveOpportunityDetails() {
        // Step 1: Setup Test Data for Opportunity with a valid Site_Visit_Done_Date__c
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Site_Visit_Done_Date__c = Date.today().addDays(-30), // Set Site Visit date 30 days ago
            Bypass_LPPDays__c = false
        );
        insert opp;

        // Step 2: Setup Channel Partner Details
        Channel_Partner_Details__c cpDetail = new Channel_Partner_Details__c(
            
            Company_Individual_Name__c = 'John Doe',
            Email_Address__c = 'john.doe@example.com',
            Phone_Number__c = '9876543210',
            Channel_Partner_RERA_Number__c = 'RERA123',
            City__c = 'Mumbai',
            Country__c = 'India',
            Door_No__c = '101',
            PINCODE__c = '400001',
            State__c = 'Maharashtra',
            Street1__c = 'Main Street',
            Street2__c = 'Building 5'
        );
        insert cpDetail;

        // Step 3: Test saveOpportunityDetails method
        Test.startTest();
        ChannelPartnerController.saveOpportunityDetails(opp.Id, 'RERA123', '9876543210', 'john.doe@example.com', 'John Doe');
        Test.stopTest();

        // Step 4: Retrieve the Opportunity to verify the update
        Opportunity updatedOpp = [SELECT CP_Mobile_Number__c, Email_Address__c, Company_Individual_Name__c, RERA_Registration_Number__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];

        // Step 5: Validate that the Opportunity fields have been updated
        System.assertEquals('9876543210', updatedOpp.CP_Mobile_Number__c, 'CP Mobile Number should be updated');
        System.assertEquals('john.doe@example.com', updatedOpp.Email_Address__c, 'CP Email Address should be updated');
        System.assertEquals('John Doe', updatedOpp.Company_Individual_Name__c, 'CP Contact Person Name should be updated');
        System.assertEquals('RERA123', updatedOpp.RERA_Registration_Number__c, 'CP RERA Registration Number should be updated');
    }
}