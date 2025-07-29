@IsTest
private class GetBookingFormDocumentsTest {
    
    @IsTest
    static void testHttpGetValidBookingFormId() {
        // Setup test data
        Booking_Form__c bookingForm = new Booking_Form__c(Basic_Price__c = 6999);
        insert bookingForm;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Sample data'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion.Id LIMIT 1];
        
        ContentDocumentLink docLink = new ContentDocumentLink(
            LinkedEntityId = bookingForm.Id,
            ContentDocumentId = contentDoc.Id,
            ShareType = 'V'
        );
        insert docLink;
        
        // Simulate REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingFormDocuments/';
        req.httpMethod = 'GET';
        req.addParameter('bookingFormId', bookingForm.Id);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Call REST method
        Test.startTest();
        GetBookingFormDocuments.BookingDocumentResponse response = GetBookingFormDocuments.DocumentIds();  // Correct method call
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, response, 'Response should not be null.');
        System.assertEquals(contentDoc.Id, response.documentId[0], 'ContentDocumentId mismatch.');
        System.assertEquals(bookingForm.Id, response.BookingFormId, 'BookingFormId mismatch.'); // Verify BookingFormId is returned correctly
    }
    
    @IsTest
    static void testHttpPostValidDocumentId() {
        // Setup: Create valid ContentVersion
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Sample data'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion.Id LIMIT 1];
        
        // Simulate valid REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingFormDocuments/';
        req.httpMethod = 'POST';
        req.addParameter('documentId', contentDoc.Id);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Invoke REST method
        GetBookingFormDocuments.DocumentResponse response = GetBookingFormDocuments.GetDocument();
        System.assertNotEquals(null, response, 'Response should not be null.');
        System.assertEquals(contentVersion.Title, response.Title, 'Title mismatch.');
    }
        
    /*@IsTest
    static void testHttpGetWithInvalidBookingFormId() {
        // Simulate REST request with invalid bookingFormId
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingFormDocuments/';
        req.httpMethod = 'GET';
        req.addParameter('bookingFormId', 'InvalidId');
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        GetBookingFormDocuments.BookingDocumentResponse response = GetBookingFormDocuments.DocumentIds();
        Test.stopTest();
        
        System.assertEquals(null, response, 'Response should be null for invalid bookingFormId.');
    }*/
    
    @IsTest
    static void testHttpPostWithInvalidDocumentId() {
        // Simulate REST request with invalid documentId
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingFormDocuments/';
        req.httpMethod = 'POST';
        req.addParameter('documentId', 'InvalidId');
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        GetBookingFormDocuments.DocumentResponse response = GetBookingFormDocuments.GetDocument();
        Test.stopTest();
        
        System.assertEquals(null, response, 'Response should be null for invalid documentId.');
    }
    
    @IsTest
    static void testMissingParameters() {
        // Simulate REST request without parameters
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingFormDocuments/';
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        GetBookingFormDocuments.DocumentResponse response = null;
        try {
            response = GetBookingFormDocuments.GetDocument();
        } catch (Exception e) {
            System.assertEquals('Invalid parameters.', e.getMessage(), 'Unexpected exception message.');
        }
        Test.stopTest();
        
        System.assertEquals(null, response, 'Response should be null for missing parameters.');
    }
}