/**
* @File Name : LeadController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : July 1, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | July 1, 2025 |   | Initial Version
**/
@RestResource(urlMapping='/referalDetails')
global without sharing class LeadController {
    @HttpGet()
    global static void getReferralDetails() {
        RestResponse res = RestContext.response;
        try {
            String email = RestContext.request.params.get('userEmail'); 
            
            if (String.isBlank(email)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('{"error":"Missing userEmail parameter"}');
                return;
            }
            
            List<Lead> leads = [
                SELECT Id, Name, Email, Phone, Company, Projects__c, Status, Referred_Email__c 
                FROM Lead 
                WHERE Referred_Email__c = :email
            ];
            
            List<Map<String, Object>> responseList = new List<Map<String, Object>>();
            for (Lead l : leads) {
                Map<String, Object> leadMap = new Map<String, Object>();
                leadMap.put('name', l.Name);
                leadMap.put('property_name', l.Projects__c);
                leadMap.put('email', l.Email);
                leadMap.put('phone', l.Phone);
                leadMap.put('referral_id', l.Id); 
                leadMap.put('status', 'Booked');
                responseList.add(leadMap);
            }
            Map<String, Object> finalResponse = new Map<String, Object>();
            finalResponse.put('referrals', responseList);
            finalResponse.put('project_names', LeadCategory());
            
            res.responseBody = Blob.valueOf(JSON.serialize(finalResponse));
            res.statusCode = 200;
            
        } catch (Exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error":"' + ex.getMessage() + '"}');
        }
    }
    @HttpPost
    global static void customerReferrals() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            Map<String, Object> input = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            String propertyName = (String) input.get('propertyName');
            String name = (String) input.get('LeadName');
            String phone = (String) input.get('phone');
            String email = (String) input.get('userEmail');
            String company = (String) input.get('company');
            String leadID = addReferralCustomers(propertyName, name, phone, email, company);
            Map<String, Object> response = new Map<String, Object>();
            response.put('message', 'Referral Lead created successfully =' + leadID);
            res.statusCode = 201;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            
        } catch (Exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error": "' + ex.getMessage() + '"}');
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Lead> getConvertedLeadsForAccount(String email) {
        try{
            if(email != null){
                List<Lead> leadList = [Select Id,Name, Email,Phone,Company,Projects__c,Status, Referred_Email__c, IsConverted From Lead 
                                       where Referred_Email__c =: email];
                return leadList;
            }
            else {
                System.debug('AccountId is null');
                return new List<Lead>(); 
            }
        }
        catch(Exception e){
            System.debug('Error at Line Number======> ' + e.getLineNumber() + 'Error Message=====> ' + e.getMessage());
            return new List<Lead>();
        }
    }
    @AuraEnabled
    public static String addReferralCustomers(String propertyName, String name, String phone, String email, String company) {
        String leadId;
        try {
            Lead referalLead = new Lead();
            referalLead.Projects__c = propertyName;
            referalLead.LastName = name;
            referalLead.Phone = phone;
            referalLead.Referred_Email__c = email;
            referalLead.LeadSource = 'Referrals';
            referalLead.Company = 'Ramky';
            insert referalLead;
            leadId = referalLead.Id;
            System.debug('referalLead=====>'+referalLead);
        } Catch(exception ex) {
            System.debug('Error Message =' + ex.getMessage());
        }
        return leadId;
    }
    public static Set<String> LeadCategory() {
        Set<String> categories = new Set<String>();
        Schema.DescribeSObjectResult describeResult = Lead.SObjectType.getDescribe();
        Schema.DescribeFieldResult fieldResult = describeResult.fields.getMap().get('Projects__c').getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            if (entry.isActive()) {
                categories.add(entry.getLabel());
            }
        }
        return categories;
    }
    
    @AuraEnabled(cacheable= true)
    public static Map<String, List<String>> getAllPickListVal(Map<String, String> ObjectByField){
        Map<String, List<String>> picklistValByField = new Map<String, List<String>>();
        
        for(String fieldApi : ObjectByField.keySet()){
            String objectApi = ObjectByField.get(fieldApi);
            picklistValByField.put(fieldApi, getPicklistValues(objectApi, fieldApi));
        }
        
        return picklistValByField;
    }
    
    private static List<String> getPicklistValues(String objectApi, String fieldApi){
        List<String> values = new List<String>();
        
        try {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApi);
            if(objType == null) return values;
            
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            if(!fieldMap.containsKey(fieldApi)) return values;
            
            Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldApi).getDescribe();
            for(Schema.PicklistEntry entry : fieldDesc.getPicklistValues()){
                if(entry.isActive()) values.add(entry.getLabel());
            }
        } catch(Exception ex){
            System.debug('Error: ' + ex.getMessage());
        }
        
        return values;
    }
}