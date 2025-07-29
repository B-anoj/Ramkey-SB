@RestResource(urlMapping='/services')
Global without sharing class CustomerSupportController {
    
    @HttpGet
    global static void getSupportDetail() {
        RestResponse res = RestContext.response;
        try {
            String email = RestContext.request.params.get('userEmail');
            SupportWrapper result = buildSupportDetails(email);
            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap.put('caseCategories', caseCategory());
            responseMap.put('supportDetails', result);
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            res.statusCode = 200;
            res.addHeader('Content-Type', 'application/json');
        } catch (Exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(
                new Map<String, String>{ 'error' => ex.getMessage() }
            ));
        }
    }
    
    @HttpPost
    global static String importSupportDetails() {
        String response = '';
        try {
            String body = RestContext.request.requestBody.toString();
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(body);
            
            String caseId = (String) requestData.get('CaseId');
            String rating = (String) requestData.get('rating');
            String comments = (String) requestData.get('comment');
            String supportCategory = (String) requestData.get('supportCategory');
            String supportSubject = (String) requestData.get('supportSubject'); 
            String supportDescription = (String) requestData.get('supportDescription'); 
            String email = (String) requestData.get('userEmail');
            
            if (String.isNotBlank(caseId) && String.isNotBlank(rating)) {
                response = supportRating(caseId, rating, comments);
            } else if (String.isNotBlank(supportCategory) || String.isNotBlank(supportSubject)) {
                response = customerSupport(supportCategory, supportSubject, supportDescription, email);
            } else {
                response = 'Insufficient input. Please provide either CaseId and rating or support details.';
            }
        } catch(Exception ex) {
            System.debug('Error in importSupportDetails: ' + ex.getMessage());
            response = 'Error: ' + ex.getMessage();
        }
        return response;
    }
    
    public static SupportWrapper buildSupportDetails(String email) {
        SupportWrapper support = new SupportWrapper();
        List<Case> caseList = [
            SELECT Id, Subject, CaseNumber, CreatedDate, Type, Status, Description,
            (SELECT Id, Star_Rating__c FROM Support_FeedBacks__r)
            FROM Case
            WHERE Contact.Email = :email
            ORDER BY CreatedDate DESC
        ];
        List<ComplaintWrapper> complaints = new List<ComplaintWrapper>();
        for (Case cs : caseList) {
            if (cs.Support_FeedBacks__r != null && !cs.Support_FeedBacks__r.isEmpty()) {
                for (Support_FeedBack__c feedBack : cs.Support_FeedBacks__r) {
                    ComplaintWrapper cw = new ComplaintWrapper();
                    cw.id = cs.Id;
                    cw.type = cs.Type != null ? cs.Type : '';
                    cw.status = cs.Status != null ? cs.Status : '';
                    cw.description = cs.Description != null ? cs.Description : '';
                    cw.created_date = String.valueOf(cs.CreatedDate.date());
                    cw.rating_option = cs.Status != null && cs.Status.toLowerCase() == 'closed';
                    cw.rating_given = (feedBack.Star_Rating__c != null) ? Decimal.valueOf(feedBack.Star_Rating__c) : 0;
                    complaints.add(cw);
                }
            } else {
                ComplaintWrapper cw = new ComplaintWrapper();
                cw.id = cs.Id;
                cw.type = cs.Type != null ? cs.Type : '';
                cw.status = cs.Status != null ? cs.Status : '';
                cw.description = cs.Description != null ? cs.Description : '';
                cw.created_date = String.valueOf(cs.CreatedDate.date());
                cw.rating_option = cs.Status != null && cs.Status.toLowerCase() == 'closed';
                cw.rating_given = 0; 
                complaints.add(cw);
            }
        }
        
        support.complaints = complaints;
        return support;
    }

    public static Set<String> caseCategory() {
        Set<String> categories = new Set<String>();
        Schema.DescribeSObjectResult describeResult = Case.SObjectType.getDescribe();
        Schema.DescribeFieldResult fieldResult = describeResult.fields.getMap().get('Type').getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            if (entry.isActive()) {
                categories.add(entry.getLabel());
            }
        }
        return categories;
    }

    global class SupportWrapper {
        public List<ComplaintWrapper> complaints;
    }
    
    global class ComplaintWrapper {
        public String id;
        public String type;
        public String status;
        public String description; 
        public String created_date;
        public Boolean rating_option;
        public Decimal rating_given;
    }
    
    @AuraEnabled(cacheable=true)
    global static List<Case> getSupportDetails(String email) {
        try {
            if (email == null || email == '') {
                return new list<case>();
            }
            return [
                SELECT Id, Subject, CaseNumber, CreatedDate, Type, Status, Description
                FROM Case
                WHERE Contact.Email = :email
                ORDER BY CreatedDate DESC
            ];
        } catch (Exception ex) {
            throw new AuraHandledException('Error: ' + ex.getMessage());
        }
    }
    
     @AuraEnabled
    public static String supportRating(String caseId, String rating, String comments) {
        String successMessage = '';
        try {
            Support_FeedBack__c ratingCustomer = new Support_FeedBack__c();
            ratingCustomer.Case__c = caseId;
            ratingCustomer.Star_Rating__c = rating;
            ratingCustomer.Comments__c = comments;
            insert ratingCustomer;
            successMessage = 'Rating submitted successfully';
        } catch (Exception ex) {
            System.debug('Error Message ===> ' + ex.getMessage()+ 'Error at LineNumber'+ex.getLineNUmber());
            successMessage = 'Failed to submit rating';
        }
        return successMessage;
    }
    
    
    public static String customerSupport(String supportCategory, String supportSubject, String supportDescription, String email) {
        String successMessage = '';
        try {
            Contact matchedAcc = [SELECT Id, AccountId, Email FROM Contact WHERE Email =:email LIMIT 1];
            
            Case supportCs = new Case();
            supportCs.Origin = 'Phone';
            supportCs.Type = supportCategory;
            supportCs.Subject = supportSubject;
            supportCs.Description = supportDescription;
            supportCs.AccountId = matchedAcc.AccountId;
            supportCs.ContactId = matchedAcc.Id;
            
            insert supportCs;
            
            successMessage = 'Case created successfully with Id: ' + supportCs.Id;
        } catch (Exception ex) {
            System.debug('Error in customerSupport: ' + ex.getMessage());
            successMessage = 'Error creating case: ' + ex.getMessage();
        }
        return successMessage;
    }
    

    @AuraEnabled
    public static void customerCaseImport(String csCategory, String csSubject, String csDescription, String userEmail) {
        try {
            List<Contact> conList = [SELECT Id FROM Contact WHERE Email = :userEmail];
            List<Case> caseDetails = new List<Case>();
            for (Contact conIterate : conList) {
                Case cs = new Case();
                cs.Type = csCategory;
                cs.Subject = csSubject;
                cs.Description = csDescription;
                cs.ContactId = conIterate.Id;
                cs.Origin = 'Web';
                caseDetails.add(cs);
            }
            Insert caseDetails;
        } catch (Exception e) {
            System.debug('Error Message ===> ' + e.getMessage() + ' | Error Line Number ===> ' + e.getLineNumber());
        }
    }
    
    
    @AuraEnabled
    public static Integer  getRatingForCase(String caseId) {
        try {
            Support_Feedback__c feedback = [
                SELECT Star_Rating__c 
                FROM Support_Feedback__c 
                WHERE Case__c = :caseId 
                LIMIT 1
            ]; 
            System.debug('feedback====>'+feedback); 
            System.debug('feedback====>'+Integer.valueOf(feedback.Star_Rating__c));  
            return feedback != null ? Integer.valueOf(feedback.Star_Rating__c) : 0;
            
        } catch (Exception e) {
            System.debug('Error Message ===> ' + e.getMessage() + ' | Error Line Number ===> ' + e.getLineNumber());
        }
        return null;
    }

   @AuraEnabled
    public static string reopenCase(String caseId) {
        string result;
        try {
            Case cs = [SELECT Id, Status FROM Case WHERE Id = :caseId LIMIT 1];
            System.debug('cs1====>'+cs);
            cs.Status = 'Reopened'; 
            update cs;
            result = 'success';
            System.debug('cs2====>'+cs);
        } catch (Exception e) {
            System.debug('Error Message ===> ' + e.getMessage() + ' | Error Line Number ===> ' + e.getLineNumber());
             result = 'error';
        }
         return result; 
    }



    
}