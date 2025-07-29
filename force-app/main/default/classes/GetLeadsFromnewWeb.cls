@RestResource(urlMapping='/getLeadsFromNewWebsite/webhook/*')

global class GetLeadsFromnewWeb {
    global with sharing class ResponseWrapper1 {
        public String StatusCode;
        public String StatusMessage;
        public List<Lead> ledlist;
    }
    
    @HttpPost
    global static void createRecord1() {
        
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
        String LastName = (String)requestData.get('Name');
        String Phone = (String)requestData.get('Mobile Number');
        String Phone2 = (String)requestData.get('amob');
        String Email = (String)requestData.get('Email Id');
        String Project = (String)requestData.get('Project');
        String LeadSource = (String)requestData.get('src'); 
        String City = (String)requestData.get('City');
        String Location = (String)requestData.get('location');
        String Remarks = (String)requestData.get('Comment');
        String SourcePage = (String)requestData.get('source_page');
        String FormName = (String)requestData.get('form_name');
        String UtmSource = (String)requestData.get('utm_source');
        String UtmMedium = (String)requestData.get('utm_medium');
        String UtmCamp = (String)requestData.get('utm_campaign');
        String UtmAdGroup = (String)requestData.get('utm_adgroup');
        String UtmKeywords = (String)requestData.get('utm_keywords');
        String UtmAd = (String)requestData.get('utm_ad');
        String UtmTerm = (String)requestData.get('utm_term');
        String Url = (String)requestData.get('url');
        String Ch = (String)requestData.get('ch');
        String flatType = (String)requestData.get('flat_type');
        String f = (String)requestData.get('f');
        
        List<Lead> leadList = new List<Lead>();
        Lead le = new Lead();
        le.LastName = LastName;
        le.Company = LastName;
        le.Phone = Phone;
        le.Phone_2__c = Phone2; 
        le.Email = Email;
        le.Projects__c = Project;
        le.City = City;
        le.Locality__c = Location;
        le.Remarks__c = Remarks;
        le.LeadSource = 'Digital Campaign';
        le.Lead_Sub_Source__c = LeadSource;
        le.Source_page__c = SourcePage;
        le.Form_Name__c = FormName;
        le.UTM_Keywords__c = UtmKeywords;
        le.UTM_Source__c = UtmSource;
        le.UTM_Medium__c = UtmMedium;
        le.UTM_Campaign__c = UtmCamp;
        le.UTM_Ad_Term__c = UtmTerm;
        le.UTM_Ad_Group__c = UtmAdGroup;
        le.UTM_Ad__c = UtmAd;
        le.Website__c = Url;
        le.Prefered_Flat_Size__c = flatType;
        le.Round_Robin__c = true;
        
        leadList.add(le);
        
        ResponseWrapper1 resp = new ResponseWrapper1();
        
        try {
            insert leadList;
            resp.StatusCode = 'Success';
            resp.StatusMessage = 'Lead created successfully';
            resp.ledlist = new List<Lead>(); // Initialize the list
            resp.ledlist.add(le);
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