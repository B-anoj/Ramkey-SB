@RestResource(urlMapping='/getLeadsFromChatbot/webhook/*')
global class GetLeadsFromChatbot {
    
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
        String Phone = (String)requestData.get('Mob');
        String Email = (String)requestData.get('Email');
        String Project = (String)requestData.get('Project');
        String LeadSource = (String)requestData.get('Src'); 
        String City = (String)requestData.get('City');
        String Location = (String)requestData.get('Location');
        String Remarks = (String)requestData.get('Remark');
        String UtmSource = (String)requestData.get('Utm_Source');
        String UtmMedium = (String)requestData.get('Utm_Medium');
        String UtmCamp = (String)requestData.get('Utm_Camp');
        String UtmKeyword = (String)requestData.get('utm_keyword');
        String UtmAd = (String)requestData.get('utm_ad');
        String Url = (String)requestData.get('url');
        String Channel = (String)requestData.get('Channel');
        String ISD = (String)requestData.get('ISD');
        String UniqueId = (String)requestData.get('UniqueId');
        String AdsetId = (String)requestData.get('Adset_ID');
        String AdsetName = (String)requestData.get('Adset_Name');
        String FormName = (String)requestData.get('Fbform_Name');
        
        List<Lead> leadList = new List<Lead>();
        Lead le = new Lead();
        le.LastName = LastName;
        le.Company = LastName;
        le.Phone = Phone;
        le.Email = Email;
        le.Projects__c = Project;
        le.LeadSource = LeadSource;
        le.City = City;
        le.State = Location;
        le.Chatbot_Details__c = Remarks;
        le.LeadSource = 'Digital Campaign';
        le.Lead_Sub_Source__c = 'Chatbot';
        le.UTM_Source__c = UtmSource;
        le.UTM_Medium__c = UtmMedium;
        le.UTM_Campaign__c = UtmCamp;
        le.UTM_Ad__c = UtmAd;
        le.UTM_Keywords__c = UtmKeyword;
        le.Round_Robin__c = true;
        le.Chatbot_Url__c = Url;
        le.Form_Name__c = FormName;
        
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