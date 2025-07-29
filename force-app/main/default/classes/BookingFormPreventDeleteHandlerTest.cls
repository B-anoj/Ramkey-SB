@isTest
public class BookingFormPreventDeleteHandlerTest {

    @testSetup
    static void setupTestData() {
        // Insert a test Booking_Form__c record
        Booking_Form__c bookingForm = new Booking_Form__c(
            
            Booking_Form_Status__c = 'Final Submit',
            SDS_Approvel_Status__c = 'Approved',
            NDS_Approval_Status__c = 'Approved',
            Normal_Approval_Status__c = 'Approved'
        );
        insert bookingForm;
    }

    /*@isTest
    static void testPreventDeleteWithoutBypass() {
        // Query the test Booking_Form__c record
        Booking_Form__c bookingForm = [SELECT Id FROM Booking_Form__c LIMIT 1];

        Test.startTest();
        try {
            delete bookingForm;
            System.assert(false, 'Delete should have thrown an exception.');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains('You cannot delete this Booking Form because it has been finalized and approved.'), 
                          'Expected delete restriction message.');
        }
        Test.stopTest();
    }*/

    @isTest
    static void testAllowDeleteWithBypass() {
        // Query the test Booking_Form__c record
        Booking_Form__c bookingForm = [SELECT Id FROM Booking_Form__c LIMIT 1];

        // Enable bypass mode
        BookingFormPreventDeleteHandler.bypassFinalSubmitCheck = true;

        Test.startTest();
        try {
            delete bookingForm; // Should succeed without exception
            System.assert(true, 'Delete should succeed when bypass is enabled.');
        } catch (DmlException ex) {
            System.assert(false, 'Delete should not throw an exception when bypass is enabled.');
        }
        Test.stopTest();
    }

    @isTest
    static void testPreventDeleteForNonSystemAdmin() {
        // Query the test Booking_Form__c record
        Booking_Form__c bookingForm = [SELECT Id FROM Booking_Form__c LIMIT 1];

        // Mock the user as a non-System Administrator
        User user = [SELECT Id FROM User WHERE Profile.Name != 'System Administrator' LIMIT 1];
        System.runAs(user) {
            Test.startTest();
            try {
                delete bookingForm;
                System.assert(false, 'Delete should have thrown an exception for non-admin.');
            } catch (DmlException ex) {
                System.assert(ex.getMessage().contains('You cannot delete this Booking Form because it has been finalized and approved.'), 
                              'Expected delete restriction message for non-admin user.');
            }
            Test.stopTest();
        }
    }
}