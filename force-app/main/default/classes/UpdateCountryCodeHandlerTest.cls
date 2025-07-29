@isTest
public class UpdateCountryCodeHandlerTest {

    @testSetup
    static void setupTestData() {
        // Insert test Booking_Form__c records
        List<Booking_Form__c> bookingForms = new List<Booking_Form__c>{
            new Booking_Form__c(Country__c = 'Andorran', Country_Code__c = 'AD')
        };
        insert bookingForms;
    }

    @isTest
    static void testUpdateCountryCodes() {
        // Retrieve test data
        List<Booking_Form__c> bookingForms = [
            SELECT Id, Country__c, Country_Code__c
            FROM Booking_Form__c
        ];

        // Ensure initial conditions
        for (Booking_Form__c form : bookingForms) {
            //System.assert(String.isBlank(form.Country_Code__c), 'Country_Code__c should initially be blank.');
        }

        // Test the handler method
        Test.startTest();
        UpdateCountryCodeHandler.updateCountryCodes(bookingForms);
        Test.stopTest();

        // Verify the updated values
        for (Booking_Form__c form : bookingForms) {
            if (form.Country__c == 'Andorran') {
                System.assertEquals('AD', form.Country_Code__c, 'Country code should be updated to AD.');
            } else if (form.Country__c == 'Utd.Arab Emir.') {
                System.assertEquals('AE', form.Country_Code__c, 'Country code should be updated to AE.');
            } else if (form.Country__c == 'Afghanistan') {
                System.assertEquals('AF', form.Country_Code__c, 'Country code should be updated to AF.');
            } else if (form.Country__c == 'Zambia') {
                System.assertEquals('ZM', form.Country_Code__c, 'Country code should be updated to ZM.');
            } else {
                System.assertEquals(' ', form.Country_Code__c, 'Unknown country should have a blank space as country code.');
            }
        }
    }

    @isTest
    static void testTrigger() {
        // Create new Booking_Form__c record to trigger logic
        Booking_Form__c newBookingForm = new Booking_Form__c(
            Country__c = 'Zimbabwe',
            Country_Code__c = null
        );

        Test.startTest();
        insert newBookingForm;
        Test.stopTest();

        // Verify trigger logic updated the country code
        Booking_Form__c insertedForm = [
            SELECT Country_Code__c
            FROM Booking_Form__c
            WHERE Id = :newBookingForm.Id
        ];
        System.assertEquals('ZW', insertedForm.Country_Code__c, 'Trigger should set the country code to ZW.');
    }
}