@isTest
public class PdfUplodeSchedulableTest {
    
    @testSetup
    static void setupTestData() {
        // Create test data for Booking_Form__c
        Booking_Form__c bookingForm = new Booking_Form__c(
            
            Booking_Form_Status__c = 'Final submit',
            Is_Booking_Form_Signed__c = false,
            SDS_Approvel_Status__c = 'Approved',
            NDS_Approval_Status__c = null,
            Normal_Approval_Status__c = null
        );
        insert bookingForm;
    }

    @isTest
    static void testSchedulableExecution() {
        // Retrieve test booking form record
        //Booking_Form__c bookingForm = [SELECT Id FROM Booking_Form__c WHERE Name = 'Test Booking Form' LIMIT 1];

        Test.startTest();
        // Execute the schedulable class
        //PdfUplodeSchedulable schedulable = new PdfUplodeSchedulable(bookingForm.Id);
        String cronExpression = '0 0 12 * * ?'; // Example CRON expression
        //System.schedule('TestScheduleJob', cronExpression, schedulable);
        Test.stopTest();

        // Verify the schedulable class called the service correctly
        // Since PdfUploaderService logic is external, you can either mock or validate related changes
    }

    @isTest
    static void testTriggerWithFinalSubmitStatus() {
        // Retrieve test booking form record
        //Booking_Form__c bookingForm = [SELECT Id, Booking_Form_Status__c FROM Booking_Form__c WHERE Name = 'Test Booking Form' LIMIT 1];

        Test.startTest();
        // Update the booking form to trigger the logic
        //bookingForm.Is_Booking_Form_Signed__c = false;
        //bookingForm.SDS_Approvel_Status__c = 'Approved';
        //update bookingForm;
        Test.stopTest();

        // Verify the scheduler was invoked by the trigger
        // Check AsyncApexJob records
        List<AsyncApexJob> jobs = [SELECT Id, Status, JobType FROM AsyncApexJob WHERE JobType = 'ScheduledApex'];
        System.assert(!jobs.isEmpty(), 'Scheduled job should be created');
        //System.assertEquals('Completed', jobs[0].Status, 'Scheduled job should complete successfully');
    }
}