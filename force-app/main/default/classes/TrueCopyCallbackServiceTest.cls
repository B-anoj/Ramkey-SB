@IsTest
private class TrueCopyCallbackServiceTest {
    @IsTest
    static void testHandleCallbackSigned() {
        // Create test data
        Booking_Form__c bookingForm = new Booking_Form__c(
            	Last_Name__c = 'Test Booking Form',
             Email__c='testingG11@gmail.com',
            Is_Booking_Form_Signed__c = false
        );
        insert bookingForm;

        // Mock RestContext request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.params.put('uuid', 'some_uuid_ID_' + bookingForm.Id);
        req.params.put('status', 'SIGNED');
        req.params.put('cs', 'testCS');
        RestContext.request = req;
        RestContext.response = res;

        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        TrueCopyCallbackService.handleCallback();
        Test.stopTest();

        // Verify the response
        System.assertEquals('File successfully saved.', RestContext.response.responseBody.toString(), 'File save message mismatch.');
        System.assertEquals(200, RestContext.response.statusCode, 'Status code mismatch.');

        // Verify booking form updates
        Booking_Form__c updatedBookingForm = [SELECT Is_Booking_Form_Signed__c FROM Booking_Form__c WHERE Id = :bookingForm.Id];
        System.assertEquals(true, updatedBookingForm.Is_Booking_Form_Signed__c, 'Booking form should be marked as signed.');
    }

   @IsTest
    static void testHandleCallbackRejected() {
        // Create a test user to assign as the owner of the Booking_Form__c record
        User testUser = [SELECT Id, Email FROM User WHERE IsActive = true LIMIT 1];
        System.assertNotEquals(null, testUser.Email, 'Test user must have a valid email.');

        // Create test data with the owner assigned
        Booking_Form__c bookingForm = new Booking_Form__c(
            Last_Name__c = 'Test Booking Form',
            Is_Booking_Form_Signed__c = true,
            OwnerId = testUser.Id
        );
        insert bookingForm;

        // Mock RestContext request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.params.put('uuid', 'some_uuid_ID_' + bookingForm.Id);
        req.params.put('status', 'REJECTED');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TrueCopyCallbackService.handleCallback();
        Test.stopTest();

        // Verify the response
       // System.assertEquals(200, RestContext.response.statusCode, 'Status code mismatch.');

        // Verify booking form updates
        Booking_Form__c updatedBookingForm = [SELECT Booking_Form_Status__c, Is_Booking_Form_Signed__c FROM Booking_Form__c WHERE Id = :bookingForm.Id];
        System.assertEquals('Draft Save', updatedBookingForm.Booking_Form_Status__c, 'Booking form status mismatch.');
        System.assertEquals(false, updatedBookingForm.Is_Booking_Form_Signed__c, 'Booking form signed status mismatch.');

        // Verify email is sent (you can verify this indirectly by ensuring no exceptions are thrown)
        System.debug('Test completed successfully.');
    }

    // Mock HTTP callout response (same as in the previous code)
 /*   private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('Sample PDF content in base64');
            res.setHeader('Content-Type', 'application/pdf');
            return res;
        }
    } */

    @IsTest
    static void testHandleCallbackOtherStatus() {
        // Create test data
        Booking_Form__c bookingForm = new Booking_Form__c(
            	Last_Name__c = 'Test Booking Form',
              Email__c='testingG11@gmail.com',
            Is_Booking_Form_Signed__c = false
        );
        insert bookingForm;

        // Mock RestContext request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.params.put('uuid', 'some_uuid_ID_' + bookingForm.Id);
        req.params.put('status', 'PENDING'); // Status other than SIGNED or REJECTED
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TrueCopyCallbackService.handleCallback();
        Test.stopTest();

        // Verify the response
        System.assertEquals('Callback received but not SIGNED.', RestContext.response.responseBody.toString(), 'Response message mismatch.');
        System.assertEquals(200, RestContext.response.statusCode, 'Status code mismatch.');
    }

    // Mock HTTP callout response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('Sample PDF content in base64');
            res.setHeader('Content-Type', 'application/pdf');
            return res;
        }
    }
}