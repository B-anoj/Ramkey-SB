@RestResource(urlMapping='/getLeadsfrom99Acers/webhook/*')
global class CreateLeadFrom99AcersWebHook {

    global with sharing class ResponseWrapper {
        public String StatusCode;
        public String StatusMessage;
        public List<Lead> led;
    }

    @HttpPost
    global static void createRecord() {
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;

        // Convert the request body to a String
        String requestBody = body.toString();

        // Deserialize the JSON string into a map
        Map<String, Object> requestData = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        
        //To see the request in logs
        for (String key : requestData.keySet()) {
            System.debug(key + ' = ' + requestData.get(key));
        }

        // Retrieve values from the map
        String LastName = (String)requestData.get('name');
        String Phone = (String)requestData.get('phoneNo');
        String Email = (String)requestData.get('email');
        String ProjectCode = (String)requestData.get('prjcode');
        String Country = (String)requestData.get('Country');
        String City = (String)requestData.get('city');
        String Price = (String)requestData.get('price');
        String ResponseId = (String)requestData.get('responseId');
        String ResponseDate = (String)requestData.get('responsedate');
        String LeadStatus = (String)requestData.get('leadstatus');
        String Comment = (String)requestData.get('comment');
        String WebsiteName = (String)requestData.get('websiteName');

        List<Lead> leadList = new List<Lead>();
        Lead le = new Lead();
        le.LastName = LastName;
        le.Company = LastName;
        le.Phone = Phone;
        le.Email = Email;
       	le.Projects__c = ProjectCode;
        le.Country = Country;
        le.City = City;
        le.LeadSource = 'Web Portal';
        le.Lead_Sub_Source__c = '99 Acres';
        le.Prefered_Budget__c = Price;
       // le.Remarks__c = Comment;
        le.Website = WebsiteName;
        le.Round_Robin__c = true;
        leadList.add(le);

        ResponseWrapper resp = new ResponseWrapper();

        try {
            insert leadList;
            resp.StatusCode = 'Success';
            resp.StatusMessage = 'Lead created successfully';
            resp.led = new List<Lead>(); // Initialize the list
            resp.led.add(le);
            System.debug('Response :' + resp);
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            resp.StatusCode = 'Error';
            resp.StatusMessage = 'Error inserting leads: ' + e.getMessage();
        }
        String jsonResponse = JSON.serialize(resp);

        // Set the response
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonResponse);
        RestContext.response.statusCode = 200;
    }
}