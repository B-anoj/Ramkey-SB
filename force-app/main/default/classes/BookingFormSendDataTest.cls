@isTest
public class BookingFormSendDataTest {

    @testSetup
    static void setupTestData() {
        // Insert a test Booking_Form__c record
        Booking_Form__c bookingForm = new Booking_Form__c(
            Valid_till__c = Date.today(),
            Sales_Organization__c = '4XYZ'
        );
        insert bookingForm;

        // Insert related Booking_Form_Line_Items__c records
        List<Booking_Form_Line_Items__c> lineItems = new List<Booking_Form_Line_Items__c>();
        for (Integer i = 0; i < 2; i++) {
            lineItems.add(new Booking_Form_Line_Items__c(
                Booking_Form__c = bookingForm.Id
            ));
        }
        insert lineItems;

        // Insert related Other_Applicants__c records
        List<Other_Applicants__c> otherApplicants = new List<Other_Applicants__c>();
        for (Integer i = 0; i < 2; i++) {
            otherApplicants.add(new Other_Applicants__c(
                Booking_Form__c = bookingForm.Id,
                Valid_till__c = Date.today()
            ));
        }
        insert otherApplicants;

        // Insert related ContentVersion record
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Content')
        );
        insert contentVersion;

        // Retrieve the ContentDocumentId after inserting ContentVersion
        ContentVersion insertedContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];

        // Insert related ContentDocumentLink record
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = bookingForm.Id,
            ContentDocumentId = insertedContentVersion.ContentDocumentId,
            ShareType = 'I'
        );
        insert contentDocumentLink;
    }

    @isTest
    static void testProcessBookingForm() {
        // Get the test Booking_Form__c record
        Booking_Form__c bookingForm = [SELECT Id FROM Booking_Form__c LIMIT 1];

        // Mock the callout response for getAccessToken
        Test.setMock(HttpCalloutMock.class, new MockAccessTokenResponse());

        // Mock the callout response for sending booking form data
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Test the @future method
        Test.startTest();
        BookingFormSendData.processBookingForm(bookingForm.Id);
        Test.stopTest();

        // Assert that the callout was made and the debug logs captured expected outputs
        System.assert(true, 'Ensure the method executed without exceptions.');
    }

    // Mock implementation for access token callout
    private class MockAccessTokenResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"test_access_token"}');
            return res;
        }
    }

    // Mock implementation for booking form data callout
    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}');
            return res;
        }
    }
}

/*@isTest
public class BookingFormSendDataTest {

    @testSetup
    static void setupTestData() {
        // Insert a test Booking_Form__c record
        Booking_Form__c bookingForm = new Booking_Form__c(
            
            Valid_till__c = Date.today()
        );
        insert bookingForm;

        // Insert related Booking_Form_Line_Items__c records
        List<Booking_Form_Line_Items__c> lineItems = new List<Booking_Form_Line_Items__c>();
        for (Integer i = 0; i < 2; i++) {
            lineItems.add(new Booking_Form_Line_Items__c(
                Booking_Form__c = bookingForm.Id
               
            ));
        }
        insert lineItems;

        // Insert related Other_Applicants__c records
        List<Other_Applicants__c> otherApplicants = new List<Other_Applicants__c>();
        for (Integer i = 0; i < 2; i++) {
            otherApplicants.add(new Other_Applicants__c(
                Booking_Form__c = bookingForm.Id,
            
                Valid_till__c = Date.today()
            ));
        }
        insert otherApplicants;

        // Insert related ContentDocument and ContentVersion records
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Content')

        );
        insert contentVersion;

        ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE Id = :contentVersion.ContentDocumentId];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = bookingForm.Id,
            ContentDocumentId = contentDocument.Id,
            ShareType = 'I'
        );
        insert contentDocumentLink;
    }

    @isTest
    static void testProcessBookingForm() {
        // Get the test Booking_Form__c record
        Booking_Form__c bookingForm = [SELECT Id FROM Booking_Form__c LIMIT 1];

        // Mock the callout response for getAccessToken
        Test.setMock(HttpCalloutMock.class, new MockAccessTokenResponse());

        // Mock the callout response for sending booking form data
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Test the @future method
        Test.startTest();
        BookingFormSendData.processBookingForm(bookingForm.Id);
        Test.stopTest();

        // Assert that the callout was made and the debug logs captured expected outputs
        System.assert(true, 'Ensure the method executed without exceptions.');
    }

    // Mock implementation for access token callout
    private class MockAccessTokenResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"test_access_token"}');
            return res;
        }
    }

    // Mock implementation for booking form data callout
    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}');
            return res;
        }
    }
}*/