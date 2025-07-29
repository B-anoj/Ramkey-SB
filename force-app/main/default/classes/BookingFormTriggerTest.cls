@isTest
public class BookingFormTriggerTest {
    @testSetup
    static void setupTestData() {
        // Insert a test Booking_Form__c record
        Booking_Form__c bookingForm = new Booking_Form__c(
            
            Valid_till__c = Date.today()
        );
        insert bookingForm;
    }

    @isTest
    static void testTriggerFinalSubmit() {
        // Get the test Booking_Form__c record
        Booking_Form__c bookingForm = [SELECT Id FROM Booking_Form__c LIMIT 1];

        // Mock the callout responses
        //Test.setMock(HttpCalloutMock.class, new BookingFormSendDataTest.MockAccessTokenResponse());
        //Test.setMock(HttpCalloutMock.class, new BookingFormSendDataTest.MockHttpResponse());

        // Update Booking_Form__c to trigger the schedulable logic
        bookingForm.Booking_Form_Status__c = 'Final submit';
        bookingForm.Is_Booking_Form_Signed__c = true;
        bookingForm.SDS_Approvel_Status__c = 'Approved';

        Test.startTest();
        update bookingForm;
        Test.stopTest();

        // Assert that the scheduled job was created
        //CronTrigger cronJob = [SELECT Id, State, CronExpression FROM CronTrigger WHERE JobName LIKE 'BookingFormSendDataJob_%' LIMIT 1];
        //System.assertNotEquals(null, cronJob, 'The scheduled job should exist.');
        //System.assertEquals('WAITING', cronJob.State, 'The job should be in WAITING state.');
    }

    @isTest
    static void testTriggerInsert() {
        // Insert a new Booking_Form__c record
        Booking_Form__c newBookingForm = new Booking_Form__c(
            
            Valid_till__c = Date.today()
        );

        Test.startTest();
        insert newBookingForm;
        Test.stopTest();

        // Assert that the scheduled job was created
        //CronTrigger cronJob = [SELECT Id, State, CronExpression FROM CronTrigger WHERE JobName LIKE 'BookingFormSendDataJob_%' LIMIT 1];
        //System.assertNotEquals(null, cronJob, 'The scheduled job should exist.');
        //System.assertEquals('WAITING', cronJob.State, 'The job should be in WAITING state.');
    }
}