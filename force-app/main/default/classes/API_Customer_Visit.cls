@RestResource(urlMapping='/visits')
global without sharing class API_Customer_Visit {
    
    global class VisitWrapper {
        public VisitGroups visits { get; set; }
        
        public VisitWrapper() {
            visits = new VisitGroups();
        }
    }
    public class FinalResponseWrapper {
        public VisitWrapper visits;
        public VisitResponseWrapper current_visit;
        public Set<String> projectName;
        public List<String> visitQueries;
    }
    global class VisitGroups {
       @AuraEnabled  public List<VisitDetail> upcoming { get; set; }
       @AuraEnabled  public List<VisitDetail> completed { get; set; }
       @AuraEnabled  public List<VisitDetail> cancelled { get; set; }
        
        public VisitGroups() {
            upcoming = new List<VisitDetail>();
            completed = new List<VisitDetail>();
            cancelled = new List<VisitDetail>();
        }
    }
    global class VisitDetail {
       @AuraEnabled  public String visit_id { get; set; }
       @AuraEnabled  public String property_name { get; set; }
       @AuraEnabled  public String address { get; set; }
       @AuraEnabled  public String visit_date { get; set; }
       @AuraEnabled  public String visit_day { get; set; }
       @AuraEnabled  public String visit_time { get; set; }
       @AuraEnabled  public String crm_person { get; set; }
       @AuraEnabled  public String status { get; set; }
    }
    @HttpGet
    global static void getCustomerVisitDetails() {
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        try {
            String email = req.params.get('userEmail');
            String visitId = req.params.get('visitId');
            VisitWrapper wrapper = fetchVisitDetails(email); 
            VisitResponseWrapper currentVisit = fetchCurrentVisit(visitId); 
            // Combine both into one response
            FinalResponseWrapper finalWrapper = new FinalResponseWrapper();
            finalWrapper.visits = wrapper;
            finalWrapper.current_visit = currentVisit;
            finalWrapper.projectName = projectList(email);
            finalWrapper.visitQueries = visitQueried();
            res.responseBody = Blob.valueOf(JSON.serializePretty(finalWrapper));
            res.statusCode = 200;
        } catch (Exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error": "' + ex.getMessage() + '"}');
        }
    }
    @AuraEnabled(cacheable = true)
    public static VisitWrapper fetchVisitDetails(String email) {
        VisitWrapper wrapper = new VisitWrapper();
        try {
        List<Visit__c> visitList = [
            SELECT Id, Name, Date_Of_Visit__c, Time_Of_Visit__c, Status__c, Account__r.Name,
            Project__c
            FROM Visit__c
            WHERE Account__r.Email__c = :email
        ];
            Set<String> projName = new Set<String>();
            for (Visit__c visitDetails : visitList) {
                projName.add(visitDetails.project__c);
            }
        List<Ramky_Projects__mdt> projectAddress = [SELECT Id, MasterLabel, Property_Address__c 
                                                    FROM Ramky_Projects__mdt WHERE MasterLabel IN: projName];
            Map<String, String> mapValue = new Map<String, String>();
            for (Ramky_Projects__mdt propertyIterate : projectAddress) {
                mapValue.put(propertyIterate.masterLabel, propertyIterate.Property_Address__c);
            }
        for (Visit__c visit : visitList) {
            VisitDetail detail = new VisitDetail();
            detail.visit_id = visit.Id;
            detail.property_name = visit.Project__c != null ? visit.Project__c : '';
            detail.address = mapValue.get(visit.Project__c);
            detail.visit_date = visit.Date_Of_Visit__c != null ? String.valueOf(visit.Date_Of_Visit__c) : '';
            detail.visit_time = visit.Time_Of_Visit__c != null ? String.valueOf(visit.Time_Of_Visit__c) : '';
            detail.crm_person = visit.Account__r.Name != null ? visit.Account__r.Name : '';
            detail.status = visit.Status__c;
            
            if (visit.Status__c == 'Upcoming') {
                wrapper.visits.upcoming.add(detail);
            } else if (visit.Status__c == 'Completed') {
                wrapper.visits.completed.add(detail);
            } else if (visit.Status__c == 'Cancelled') {
                wrapper.visits.cancelled.add(detail);
            }
        }
        } Catch(Exception ex) {
            System.debug('Error Message =' + ex.getMessage());
        }
        
        return wrapper;
    }
    @HttpPost
    global static String importCustomerVisit(String property_id, Date visit_date, Time visit_time, String visit_type,
                                             String visit_details, String visitor_Email) {
                                                 String successMessage = 'Visit creation failed.';
                                                 
                                                 try {
                                                     // Validate required fields
                                                     if (String.isBlank(property_id) || visit_date == null || visit_time == null || 
                                                         String.isBlank(visitor_Email)) {
                                                             return 'Missing required fields.';
                                                         }
                                                     
                                                     // Query related booking form and account
                                                     List<Booking_Form__c> bookings = [
                                                         SELECT Id, Opportunity__r.AccountId
                                                         FROM Booking_Form__c
                                                         WHERE Project_Name__c = :property_id
                                                         AND Opportunity__r.Account.Email__c = :visitor_Email
                                                         LIMIT 1
                                                     ];
                                                     
                                                     if (!bookings.isEmpty()) {
                                                         Booking_Form__c booking = bookings[0];
                                                         
                                                         Visit__c customerVisit = new Visit__c();
                                                         customerVisit.Project__c = property_id;
                                                         customerVisit.Date_Of_Visit__c = visit_date;
                                                         customerVisit.Time_Of_Visit__c = visit_time;
                                                         customerVisit.Visit_Type__c = visit_type;
                                                         customerVisit.Visit_Details__c = visit_details;
                                                         customerVisit.Account__c = booking.Opportunity__r.AccountId;
                                                         customerVisit.Status__c = 'Upcoming';
                                                         customerVisit.Booking_Form__c = booking.Id;
                                                         
                                                         insert customerVisit;
                                                         
                                                         successMessage = 'Visit created successfully.';
                                                     } else {
                                                         successMessage = 'No matching booking found for provided email and project.';
                                                     }
                                                     
                                                 } catch (Exception ex) {
                                                     System.debug('Error creating visit: ' + ex.getMessage());
                                                     successMessage = 'Error: ' + ex.getMessage();
                                                 }
                                                 
                                                 return successMessage;
                                             }

    @HttpPatch
    global static String updateCustomerVisit(String visitId, Date visit_Date, Time Visit_Time, String reason_Cancellation, String reasonReschedule, String visit_Detail) {
        String successMessage = '';
        try {
            Visit__c existVisits = [SELECT Id, Date_Of_Visit__c, Time_Of_Visit__c, Status__c, Reason_Schedule__c, Visit_Details__c  
                                    FROM Visit__c WHERE Id =:visitId];
            
            if (visitId != null && visit_Date != null && Visit_Time != null) {
                // Reschedule logic
                existVisits.Date_Of_Visit__c = visit_Date;
                existVisits.Time_Of_Visit__c = Visit_Time;
                existVisits.Reason_Schedule__c = reasonReschedule;
                existVisits.Visit_Details__c = visit_Detail;
                existVisits.Status__c = 'Upcoming';
                update existVisits;
                successMessage = 'Visit Rescheduled Successfully';
                
            } else if (visitId != null && reason_Cancellation != null) {
                // Cancel logic
                cancelCustomerVisit(visitId, reason_Cancellation);
                successMessage = 'Visit Cancelled Successfully';
            }
            
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            successMessage = 'Error occurred: ' + ex.getMessage();
        }
        return successMessage;
    }
    
    public static void cancelCustomerVisit(String visitId, String cancellationReason) {
        try {
            Visit__c customerVisit = [SELECT Id, Status__c FROM Visit__c WHERE Id =: visitId];
            customerVisit.Status__c = 'Cancelled';
            customerVisit.Reason_Visit_Cancel__c = cancellationReason;
            DataBase.Update(customerVisit, false);
        } Catch (Exception ex) {
            System.debug('Error Message =' + ex.getMessage());
        }
    }
    public static Set<String> projectList( String email) {
        Set<String> categories = new Set<String>();
        List<Booking_Form__c> customerBook = [SELECT Id, Opportunity__r.Account.Email__c, Project_Name__c FROM Booking_Form__c WHERE Opportunity__r.Account.Email__c =: email];
        for (Booking_Form__c bookData : customerBook) {
            categories.add(bookData.Project_Name__c);
        }

        return categories;
    }
    public class VisitResponseWrapper {
        public VisitDetails visit_details;
    }
    public class VisitDetails {
        public String property_name;
        public String booking_id;
        public UnitDetails unit_details;
        public VisitInfo visit_info;
        public Location location;
    }
    public class UnitDetails {
        public String unit_number;
        public String type;
        public String customer_id;
        public String super_built_up_area;
    }
    public class VisitInfo {
        public String visit_id;
        public String status;
        public String visit_date;
        public String visit_time;
        public String visit_completed_date;
        public String visit_completed_time;
        public String visit_cancelled_date;
        public String visit_cancelled_time;
        public String crm_person;
        public String remarks;
    }
    public class Location {
        public String latitude;
        public String longitude;
    }
    public static VisitResponseWrapper fetchCurrentVisit(String visitId) {
        String jsonResponse;
        VisitResponseWrapper wrapper = new VisitResponseWrapper();
        try {
            Visit__c visit = [
                SELECT Id, Name, Date_Of_Visit__c, Time_Of_Visit__c, Status__c, Account__r.Name,
                Project__c
                FROM Visit__c
                WHERE Id = :visitId
                LIMIT 1
            ];
            
            // Find a matching booking based on the project name
            List<Booking_Form__c> bookings = [
                SELECT Id, First_Name__c, Last_Name__c, DOB__c, Mobile__c, Email__c, Aadhar__c, CreatedDate,
                Pan_No__c, Project_Name__c, Booking_Form_Grand_Total__c, Area_in_Sqft__c, Unit__c, Unit_Type__c
                FROM Booking_Form__c
                WHERE Project_Name__c = :visit.Project__c
                LIMIT 1
            ];
            
            Booking_Form__c booking = bookings.isEmpty() ? null : bookings[0];
            
            wrapper.visit_details = new VisitDetails();
            
            // Property name
            wrapper.visit_details.property_name = visit.Project__c;
            wrapper.visit_details.booking_id = booking != null ? booking.Id : '';
            
            // Unit details
            UnitDetails unitDetails = new UnitDetails();
            unitDetails.unit_number = booking != null ? booking.Unit__c : '';
            unitDetails.type = booking != null ? booking.Unit_Type__c : '';
            unitDetails.customer_id = booking != null ? booking.Email__c : '';
            unitDetails.super_built_up_area = booking != null && booking.Area_in_Sqft__c != null
                ? booking.Area_in_Sqft__c + ' sq.ft.' : '';
            wrapper.visit_details.unit_details = unitDetails; 
            
            // Visit Info
            VisitInfo visitInfo = new VisitInfo();
            visitInfo.visit_id = visit.Id;
            visitInfo.status = visit.Status__c;
            visitInfo.visit_date = visit.Date_Of_Visit__c != null ? String.valueOf(visit.Date_Of_Visit__c) : '';
            visitInfo.visit_time = visit.Time_Of_Visit__c != null ? String.valueOf(visit.Time_Of_Visit__c) : '';
            visitInfo.visit_completed_date = visit.Date_Of_Visit__c != null ? String.valueOf(visit.Date_Of_Visit__c) : '';
            visitInfo.visit_completed_time = visit.Time_Of_Visit__c != null ? String.valueOf(visit.Time_Of_Visit__c) : ''; 
            visitInfo.visit_cancelled_date = visit.Date_Of_Visit__c != null ? String.valueOf(visit.Date_Of_Visit__c) : '';
            visitInfo.visit_cancelled_time = visit.Time_Of_Visit__c != null ? String.valueOf(visit.Time_Of_Visit__c) : '';
            visitInfo.crm_person = visit.Account__r.Name != null ? visit.Account__r.Name : '';
            visitInfo.remarks = 'Very Good Visit.'; 
            
            wrapper.visit_details.visit_info = visitInfo;
            
            // Static Location
            Location loc = new Location();
            loc.latitude = '12.9716';
            loc.longitude = '77.5946';
            wrapper.visit_details.location = loc;
            
            // Convert to JSON
            jsonResponse = JSON.serializePretty(wrapper);
            System.debug(jsonResponse); 
            
        } catch (Exception ex) {
            System.debug('Error Message = ' + ex.getMessage());
        }
        return wrapper;
    }
    public static void importVisitQueries(List<Visit__c> newList) {
        try {
            List<Visit_Feedback__c> feedbackDetails = new List<Visit_Feedback__c>();
            String questionLabel = Label.VisitFeedbackQuestions; 
            List<String> questions = questionLabel.split(',\\s*'); 
            for (Visit__c visitDetails : newList) {
                if (visitDetails.Status__c == 'Completed') {
                    Visit_Feedback__c feedback = new Visit_Feedback__c();
                    for (Integer i = 0; i < questions.size(); i++) {
                        String question = questions[i];
                        Map<String, Object> questionMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(feedback));
                        String fieldName = 'Question_' + String.valueOf(i + 1) + '__c';
                        questionMap.put(fieldName, question);
                        feedback = (Visit_Feedback__c)JSON.deserialize(JSON.serialize(questionMap), Visit_Feedback__c.class);
                    }
                    feedback.Visit__c = visitDetails.Id;
                    feedbackDetails.add(feedback);
                }
            }
            insert feedbackDetails;
            
        } catch (Exception ex) {
            System.debug('Error Message = ' + ex.getMessage());
        }
    }
    public Static List<String> visitQueried() {
        String questionLabel = Label.VisitFeedbackQuestions;
        List<String> questions = questionLabel.split(',\\s*');
        return questions;
    }  
    
}