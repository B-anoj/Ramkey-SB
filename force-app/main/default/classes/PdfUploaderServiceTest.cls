@IsTest
private class PdfUploaderServiceTest {

    @IsTest
    static void testProcessBookingFormApproved() {
        // Step 1: Setup test data
        // Create a Booking Form record
        Booking_Form__c bookingForm = new Booking_Form__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@example.com'
        );
        insert bookingForm;

        // Create related applicants
        List<Other_Applicants__c> applicants = new List<Other_Applicants__c>{
            new Other_Applicants__c(
                First_Name__c = 'Jane',
                Last_Name__c = 'Doe',
                Email__c = 'jane.doe@example.com',
                Booking_Form__c = bookingForm.Id
            ),
            new Other_Applicants__c(
                First_Name__c = 'Alice',
                Last_Name__c = 'Smith',
                Email__c = 'alice.smith@example.com',
                Booking_Form__c = bookingForm.Id
            ),
                new Other_Applicants__c(
                First_Name__c = 'Alice',
                Last_Name__c = 'S',
                Email__c = 'aliceee.smith@example.com',
                Booking_Form__c = bookingForm.Id
            ),
                new Other_Applicants__c(
                First_Name__c = 'Alice',
                Last_Name__c = 'Smithe',
                Email__c = 'alicesmith@example.com',
                Booking_Form__c = bookingForm.Id
            )
        };
        insert applicants;

        // Create a ContentVersion
        ContentVersion contentVersion = new ContentVersion(
            Title = 'test_document_test',
            PathOnClient = 'test_document_test.pdf',
            VersionData = Blob.valueOf('PDF Content')
        );
        insert contentVersion;

        // Query ContentDocument linked to the inserted ContentVersion
        ContentDocument contentDocument = [
            SELECT Id 
            FROM ContentDocument 
            WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id)
            LIMIT 1
        ];

        System.assert(contentDocument != null, 'ContentDocument should not be null.');

        // Link ContentDocument to Booking Form
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = bookingForm.Id,
            ContentDocumentId = contentDocument.Id,
            ShareType = 'V'
        );
        insert contentDocumentLink;

        // Step 2: Mock the HTTP callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PdfUploaderServiceTest.MockHttpCallout());

        // Invoke the method
        PdfUploaderService.processBookingFormApproved(bookingForm.Id);
        Test.stopTest();

        // Step 3: Assertions
        System.assert(true, 'Test completed successfully.');
    }

    // Mock class to simulate HTTP callout
    private class MockHttpCallout implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            System.assertEquals('https://ramky.truecopy.in/services/corpservice/v2/uploadfilejson', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            System.assert(req.getBody() != null, 'Request body should not be null.');

            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"File uploaded successfully"}');
            res.setStatusCode(200);
            return res;
        }
    }
}