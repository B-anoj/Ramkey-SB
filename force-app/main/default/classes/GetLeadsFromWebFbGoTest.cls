@IsTest
private class GetLeadsFromWebFbGoTest {
    
    // Nested private class to mock HTTP callouts
    private class MockHttpCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Get the request body
            String requestBody = req.getBody();
            
            // Deserialize the request body to extract data
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            String lastName = (String) requestData.get('name');
            
            // Create a mock response for the HTTP callout
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"StatusCode":"Success","StatusMessage":"Lead created successfully"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    // Test createRecord method
    @isTest
    static void testCreateRecord() {
        // Create a mock request
        RestRequest request = new RestRequest();
        request.requestURI = '/getLeadsFromGoogleWebsiteFacebook/webhook/*';
        request.httpMethod = 'POST';
        
        // Set the request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'name' => 'TestLead',
                'con' => '123456333337890',
                'email' => 'test@example.com',
                'src' => 'Website', 
                'Proj' => 'Ramky One Orion', 
                'Remark' => 'Test Remark',
                'utm_source' => 'Test Utm Source',
                'utm_medium' => 'Test Utm Medium',
                'utm_camp' => 'Test Utm Campaign',
                'url' => 'http://example.com',
                'amob' => '900909090909',
                'city' => 'Hyderabad',
                'location' => 'Uppal',
                'ch' => 'Test Channel'
                };
                    request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        
        // Set the mock request
        RestContext.request = request;
        
        // Set up the mock response
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        // Set the mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        
        // Call the createRecord method
        GetLeadsFromWebFbGo.createRecord();
        
        Test.stopTest();
        
        // Verify response
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('application/json', RestContext.response.headers.get('Content-Type'));
        
        // Deserialize response body
        GetLeadsFromWebFbGo.ResponseWrapper responseWrapper = (GetLeadsFromWebFbGo.ResponseWrapper) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            GetLeadsFromWebFbGo.ResponseWrapper.class
        );
        
        // Verify response wrapper fields
        System.assertEquals('Success', responseWrapper.StatusCode);
        System.assertEquals('Lead created successfully', responseWrapper.StatusMessage);
        System.assertNotEquals(null, responseWrapper.led);
        System.assertEquals(1, responseWrapper.led.size());
        
        // Verify inserted lead
        Lead insertedLead = responseWrapper.led[0];
        System.assertNotEquals(null, insertedLead.Id);
        System.assertEquals('TestLead', insertedLead.LastName);
    }
    
    // Nested private class to mock HTTP callouts
    private class MockHttpCalloutWithError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate an error response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200); // Internal Server Error
            return res;
        }
    }
    
    // Negative test for createRecord method when HTTP callout fails
    @isTest
    static void testCreateRecordWithHttpCalloutError() {
        // Create a mock request
        RestRequest request = new RestRequest();
        request.requestURI = '/getLeadsFromGoogleWebsiteFacebook/webhook/*';
        request.httpMethod = 'POST';
        
        // Set the request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'name' => 'TestLead',
                'con' => '123456333337890',
                'email' => 'test@example.com',
                'src' => 'Website', 
                'Proj' => 'Test Project', 
                'Remark' => 'Test Remark',
                'utm_source' => 'Test Utm Source',
                'utm_medium' => 'Test Utm Medium',
                'utm_camp' => 'Test Utm Campaign', 
                'url' => 'http://example.com',
                'amob' => '900909090909',
                'city' => 'Hyderabad',
                'location' => 'Uppal',
                'ch' => 'Test Channel'
                };
                    request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        
        // Set the mock request
        RestContext.request = request;
        
        // Set up the mock response
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        // Set the mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutWithError());
        
        // Call the createRecord method
        GetLeadsFromWebFbGo.createRecord();
        
        Test.stopTest();
        
        // Verify response
        System.assertEquals(200, RestContext.response.statusCode);
    }
}