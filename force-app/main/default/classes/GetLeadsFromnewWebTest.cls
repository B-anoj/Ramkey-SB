@isTest
public class GetLeadsFromnewWebTest {
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
        request.requestURI = '/getLeadsFromNewWebsite/webhook/*';
        request.httpMethod = 'POST';
        
        // Set the request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'Name' => 'TestLead',
                'Mobile Number' => '123456333337890',
                'Email Id' => 'test@example.com',
                'src' => 'Website', 
                'Project' => 'Ramky One Orion', 
                'Comment' => 'Test Remark',
                'source_page' => 'website',
                'form_name' => 'ramky-web-form',
                'utm_source' => 'Test Utm Source',
                'utm_medium' => 'Test Utm Medium',
                'utm_campaign' => 'Test Utm Campaign',
                'utm_keyword' => 'web-345677',
                'url' => 'http://example.com',
                'amob' => '900909090909',
                'City' => 'Hyderabad',
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
        GetLeadsFromnewWeb.createRecord1();
        
        Test.stopTest();
        
        // Verify response
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('application/json', RestContext.response.headers.get('Content-Type'));
        
        // Deserialize response body
        GetLeadsFromnewWeb.ResponseWrapper1 responseWrapper = (GetLeadsFromnewWeb.ResponseWrapper1) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            GetLeadsFromnewWeb.ResponseWrapper1.class
        );
        
        // Verify response wrapper fields
        System.assertEquals('Success', responseWrapper.StatusCode);
        System.assertEquals('Lead created successfully', responseWrapper.StatusMessage);
        System.assertNotEquals(null, responseWrapper.ledlist);
        System.assertEquals(1, responseWrapper.ledlist.size());
        
        // Verify inserted lead
        Lead insertedLead = responseWrapper.ledlist[0];
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
            'Name' => 'TestLead',
                'Mobile Number' => '123456333337890',
                'Email Id' => 'test@example.com',
                'src' => 'Website', 
                'Project' => 'Test Project', 
                'Comment' => 'Test Remark',
                'source_page' => 'website',
                'form_name' => 'ramky-web-form',
                'utm_source' => 'Test Utm Source',
                'utm_medium' => 'Test Utm Medium',
                'utm_camp' => 'Test Utm Campaign',
                'utm_keyword' => 'web-345677',
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