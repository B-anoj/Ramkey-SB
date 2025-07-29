@isTest
public class BookingFormRevertPdStatusTest {

    @testSetup
    static void setupTestData() {
        // Create a test Product2 record
        Product2 product = new Product2(
            Name = 'Test Product',
            Status__c = '01-Sold unit'
        );
        insert product;

        // Create a test Booking_Form__c record with 'Draft Save' status
        Booking_Form__c bookingForm = new Booking_Form__c(
           
            Booking_Form_Status__c = 'Draft Save',
            Product2__c = product.Id
        );
        insert bookingForm;

        // Create another test Booking_Form__c record with a different status
        Booking_Form__c nonDraftBookingForm = new Booking_Form__c(
           
            Booking_Form_Status__c = 'Final Submit',
            Product2__c = product.Id
        );
        insert nonDraftBookingForm;
    }

    @isTest
    static void testRevertProductStatusOnDelete() {
        // Query the test Booking_Form__c and Product2 records
        Booking_Form__c bookingForm = [SELECT Id, Product2__c FROM Booking_Form__c WHERE Booking_Form_Status__c = 'Draft Save' LIMIT 1];
        Product2 product = [SELECT Id, Status__c FROM Product2 WHERE Id = :bookingForm.Product2__c];

        // Verify initial status of the Product2 record
        System.assertEquals('01-Sold unit', product.Status__c, 'Initial Product2 status should be "01-Sold unit".');

        Test.startTest();
        delete bookingForm; // Trigger the delete logic
        Test.stopTest();

        // Verify the status of the Product2 record has been reverted
        product = [SELECT Status__c FROM Product2 WHERE Id = :product.Id];
        System.assertEquals('08-Available Unit', product.Status__c, 'Product2 status should be reverted to "08-Available unit".');
    }

    @isTest
    static void testNoRevertForNonDraftStatus() {
        // Query the test Booking_Form__c record with non-draft status
        Booking_Form__c nonDraftBookingForm = [SELECT Id, Product2__c FROM Booking_Form__c WHERE Booking_Form_Status__c = 'Final Submit' LIMIT 1];
        Product2 product = [SELECT Id, Status__c FROM Product2 WHERE Id = :nonDraftBookingForm.Product2__c];

        // Verify initial status of the Product2 record
        System.assertEquals('01-Sold unit', product.Status__c, 'Initial Product2 status should be "01-Sold unit".');

        Test.startTest();
        delete nonDraftBookingForm; // Attempt to delete non-draft booking form
        Test.stopTest();

        // Verify the status of the Product2 record remains unchanged
        product = [SELECT Status__c FROM Product2 WHERE Id = :product.Id];
        System.assertEquals('01-Sold unit', product.Status__c, 'Product2 status should remain unchanged for non-draft booking form.');
    }

    @isTest
    static void testTriggerIntegration() {
        // Query the test Booking_Form__c record with draft status
        Booking_Form__c bookingForm = [SELECT Id, Product2__c FROM Booking_Form__c WHERE Booking_Form_Status__c = 'Draft Save' LIMIT 1];

        // Enable the bypass logic for `BookingFormPreventDeleteHandler` to isolate test case
        BookingFormPreventDeleteHandler.bypassFinalSubmitCheck = true;

        Test.startTest();
        delete bookingForm; // Trigger the delete logic
        Test.stopTest();

        // Verify the Product2 status has been reverted
        Product2 product = [SELECT Status__c FROM Product2 WHERE Id = :bookingForm.Product2__c];
        System.assertEquals('08-Available Unit', product.Status__c, 'Product2 status should be reverted to "08-Available unit".');
    }
}