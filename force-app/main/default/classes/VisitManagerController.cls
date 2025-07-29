@RestResource(urlMapping='/visitFeedBack')
Global without sharing class VisitManagerController {
    @AuraEnabled(cacheable=true)
    public static VisitWrapper fetchVisitDetails(String email) {
        VisitWrapper wrapper = new VisitWrapper();
        wrapper.visits = new VisitStatusMap();
        String contactEmail = 'dhayalan2531@gmail.com';
        // Step 1: Get Contact and Account
        List<Contact> contactList = [
            SELECT Id, AccountId
            FROM Contact
            WHERE Email = :contactEmail
            LIMIT 1
        ];
        
        if (contactList.isEmpty()) {
            return wrapper;
        }
        
        Id accountId = contactList[0].AccountId;
        
        // Step 2: Get Opportunities for this Account
        List<Opportunity> oppList = [
            SELECT Id
            FROM Opportunity
            WHERE AccountId = :accountId
        ];
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : oppList) {
            oppIds.add(opp.Id);
        }
        
        if (oppIds.isEmpty()) {
            return wrapper;
        }
        
        // Step 3: Get Booking Forms with required fields
        List<Booking_Form__c> bookingList = [
            SELECT Id, Booking_Id__c, Unit__c, Unit_Type__c, Project_Name__c,
            Booking_Date__c, Area_in_Sqft__c, Opportunity__c, Sales_Document__c
            FROM Booking_Form__c
            WHERE Opportunity__c IN :oppIds
        ];
        
        Set<Id> bookingIds = new Set<Id>();
        Map<Id, Booking_Form__c> bookingFormMap = new Map<Id, Booking_Form__c>();
        
        for (Booking_Form__c booking : bookingList) {
            bookingIds.add(booking.Id);
            bookingFormMap.put(booking.Id, booking);
        }
        
        if (bookingIds.isEmpty()) {
            return wrapper;
        }
        
        // Step 4: Get Visit records
        List<Visit__c> visitList = [
            SELECT Id, Name, Date_Of_Visit__c, Time_Of_Visit__c, Status__c,
            Account__r.Name, Project__c, Booking_Form__c
            FROM Visit__c
            WHERE Account__r.Email__c =:email
        ];
        
        for (Visit__c visit : visitList) {
            VisitDetail detail = new VisitDetail();
            detail.visit_id = visit.Id;
            detail.property_name = visit.Project__c;
            detail.address = '';
            detail.visit_date = visit.Date_Of_Visit__c != null ? String.valueOf(visit.Date_Of_Visit__c) : '';
            detail.visit_time = visit.Time_Of_Visit__c != null ? String.valueOf(visit.Time_Of_Visit__c) : '';
            detail.crm_person = visit.Account__r != null ? visit.Account__r.Name : '';
            detail.status = visit.Status__c;
            
            // 🔗 Add Booking Form Details
            Booking_Form__c booking = bookingFormMap.get(visit.Booking_Form__c);
            if (booking != null) {
                detail.bookingId = booking.Booking_Id__c;
                detail.unit = booking.Unit__c;
                detail.unitType = booking.Unit_Type__c;
                detail.projectName = booking.Project_Name__c;
                detail.customerId = booking.Sales_Document__c;
                detail.area = booking.Area_in_Sqft__c != null ? String.valueOf(booking.Area_in_Sqft__c) : '';
                detail.createdDate = booking.Booking_Date__c != null ? String.valueOf(booking.Booking_Date__c) : '';
            }
            
            // 🗂 Categorize
            if (visit.Status__c == 'Upcoming') {
                wrapper.visits.upcoming.add(detail);
            } else if (visit.Status__c == 'Completed') {
                wrapper.visits.completed.add(detail);
            } else if (visit.Status__c == 'Cancelled') {
                wrapper.visits.cancelled.add(detail);
            }
        }
        
        return wrapper;
    }
    @AuraEnabled
    public static String scheduleVisit(Map<String, String> visitData) {
        System.debug('📥 Incoming Visit Data: ' + JSON.serializePretty(visitData));
        
        Visit__c newVisit = new Visit__c();
        
        newVisit.Project__c = visitData.get('projectName');
        newVisit.Visit_Type__c = visitData.get('visitType');
        newVisit.Reason_Schedule__c = visitData.get('reasonSchedule');
        newVisit.Status__c = 'Upcoming';
        
        // Visit Date
        if (String.isNotBlank(visitData.get('visitDate'))) {
            newVisit.Date_Of_Visit__c = Date.valueOf(visitData.get('visitDate'));
        }
        
        // Visit Time
        if (String.isNotBlank(visitData.get('visitTime'))) {
            List<String> timeParts = visitData.get('visitTime').split(':');
            newVisit.Time_Of_Visit__c = Time.newInstance(
                Integer.valueOf(timeParts[0]),
                Integer.valueOf(timeParts[1]), 0, 0
            );
        }
        
        // Step 1: Logged-in user → Contact → Account
        String contactEmail = 'dhayalan2531@gmail.com';
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Email = :contactEmail LIMIT 1];
        Id accountId = con.AccountId;
        newVisit.Account__c = accountId;
        
        // Step 2: Get Opportunities for this Account
        List<Opportunity> opps = [
            SELECT Id FROM Opportunity
            WHERE AccountId = :accountId
            ORDER BY CreatedDate ASC
        ];
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
        }
        
        // Step 3: Get Booking_Form__c records linked to these Opportunities
        List<Booking_Form__c> bookings = [
            SELECT Id, Opportunity__c FROM Booking_Form__c
            WHERE Opportunity__c IN :oppIds
            ORDER BY CreatedDate ASC
            LIMIT 1
        ];
        
        if (!bookings.isEmpty()) {
            Booking_Form__c booking = bookings[0];
            newVisit.Booking_Form__c = booking.Id;
            
            // Update Visit__c.Opportunity__c if the field exists
            if (booking.Opportunity__c != null) {
                newVisit.Opportunity__c = booking.Opportunity__c;
            }
        }
        
        
        // Final insert
        insert newVisit;
        return newVisit.Id;
    }
    @AuraEnabled
    public static void cancelVisit(Map<String, String> visitData) {
        String visitId = visitData.get('visitId');
        String reason = visitData.get('reasonSchedule');
        
        if (String.isNotBlank(visitId) && String.isNotBlank(reason)) {
            Visit__c visit = [SELECT Id FROM Visit__c WHERE Id = :visitId LIMIT 1];
            visit.Reason_Visit_Cancel__c = reason;
            visit.Status__c = 'Cancelled';
            update visit;
        }
    }
    @AuraEnabled
    public static String rescheduleVisit(Map<String, String> visitData) {
        try {
            String visitId = visitData.get('visitId');
            if (String.isBlank(visitId)) {
                throw new AuraHandledException('Visit ID is missing.');
            }
            
            Visit__c visit = [
                SELECT Id, Reason_Schedule__c, Visit_Details__c, Date_Of_Visit__c, Time_Of_Visit__c, Status__c
                FROM Visit__c 
                WHERE Id = :visitId 
                LIMIT 1
            ];
            
            if (String.isNotBlank(visitData.get('reason')))
                visit.Reason_Schedule__c = visitData.get('reason');
            
            if (String.isNotBlank(visitData.get('details')))
                visit.Visit_Details__c = visitData.get('details');
            
            if (String.isNotBlank(visitData.get('newDate')))
                visit.Date_Of_Visit__c = Date.valueOf(visitData.get('newDate'));
            
            if (String.isNotBlank(visitData.get('newTime'))) {
                List<String> parts = visitData.get('newTime').split(':');
                if (parts.size() >= 2) {
                    visit.Time_Of_Visit__c = Time.newInstance(
                        Integer.valueOf(parts[0]),
                        Integer.valueOf(parts[1]),
                        0,
                        0
                    );
                }
            }
            
            visit.Status__c = 'Upcoming';
            update visit;
            
            return 'Visit ' + visit.Id + ' updated successfully at ' + DateTime.now();
            
        } catch (Exception e) {
            throw new AuraHandledException('Rescheduling failed: ' + e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getVisitPicklistOptions(String email) {
        Map<String, List<String>> result = new Map<String, List<String>>();
        
        if (String.isBlank(email)) return result;
        
        // Step 1: Get Contact and Account
        Contact contact = [
            SELECT Id, AccountId 
            FROM Contact 
            WHERE Email = :email 
            LIMIT 1
        ];
        
        if (contact == null || contact.AccountId == null) return result;
        
        Id accountId = contact.AccountId;
        
        // Step 2: Get Opportunities with Projects__c field
        List<Opportunity> opportunities = [
            SELECT Projects__c 
            FROM Opportunity 
            WHERE AccountId = :accountId
        ];
        
        Set<String> projectSet = new Set<String>();
        for (Opportunity opp : opportunities) {
            if (String.isNotBlank(opp.Projects__c)) {
                projectSet.add(opp.Projects__c);
            }
        }
        
        // Step 3: Get all Visit_Type__c picklist values from Visit__c schema
        List<String> visitTypeList = new List<String>();
        for (Schema.PicklistEntry entry : Visit__c.Visit_Type__c.getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                visitTypeList.add(entry.getLabel());
            }
        }
        
        // Step 4: Add to result map
        result.put('properties', new List<String>(projectSet));
        result.put('visitTypes', visitTypeList);
        
        return result;
    }
    // Wrapper Classes
    public class VisitDetailWrapper {
        @AuraEnabled public String visitId;
        @AuraEnabled public String projectName;
        @AuraEnabled public String bookingId;
        @AuraEnabled public String unit;
        @AuraEnabled public String area;
        @AuraEnabled public String unitType;
        @AuraEnabled public String createdDate;
        @AuraEnabled public String visitDate;
        @AuraEnabled public String visitTime;
        @AuraEnabled public String crmName;
        @AuraEnabled public String status;
        @AuraEnabled public String reasonSchedule;
        @AuraEnabled public String visitType;
        @AuraEnabled public String visitDetails;
    }
    public class VisitWrapper {
        @AuraEnabled public VisitStatusMap visits = new VisitStatusMap();
    }
    public class VisitStatusMap {
        @AuraEnabled public List<VisitDetail> upcoming = new List<VisitDetail>();
        @AuraEnabled public List<VisitDetail> completed = new List<VisitDetail>();
        @AuraEnabled public List<VisitDetail> cancelled = new List<VisitDetail>();
    }
    public class VisitDetail {
        @AuraEnabled public String visit_id;
        @AuraEnabled public String property_name;
        @AuraEnabled public String address;
        @AuraEnabled public String visit_date;
        @AuraEnabled public String visit_time;
        @AuraEnabled public String crm_person;
        @AuraEnabled public String status;
        @AuraEnabled public String reasonSchedule;
        @AuraEnabled public String visitType;
        @AuraEnabled public String visitDetails;
        @AuraEnabled public String bookingId;
        @AuraEnabled public String unit;
        @AuraEnabled public String unitType;
        @AuraEnabled public String projectName;
        @AuraEnabled public String area;
        @AuraEnabled public String createdDate;
        @AuraEnabled public String customerId;
        
    }
    @HttpPut
    global static void importFeedBackDetails() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        try {
            String jsonBody = RestContext.request.requestBody.toString();
            Map<String, Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
            
            String visitId = (String) inputMap.get('visitId');
            if (String.isBlank(visitId)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('{"error":"Missing visitId"}');
                return;
            }
            Visit_FeedBack__c visitDetails = [
                SELECT Id, Visit__c, Question_1_Rating__c, Rating_2__c, Rating_3__c, Rating_4__c, Rating_5__c
                FROM Visit_FeedBack__c
                WHERE Visit__c = :visitId
                LIMIT 1
            ];
            if (inputMap.containsKey('Question_1_Rating__c'))
                visitDetails.Question_1_Rating__c = Decimal.valueOf((String) inputMap.get('Question_1_Rating__c'));
            if (inputMap.containsKey('Rating_2__c'))
                visitDetails.Rating_2__c = (String) inputMap.get('Rating_2__c');
            if (inputMap.containsKey('Rating_3__c'))
                visitDetails.Rating_3__c = Decimal.valueOf((String) inputMap.get('Rating_3__c'));
            if (inputMap.containsKey('Rating_4__c'))
                visitDetails.Rating_4__c = (String) inputMap.get('Rating_4__c');
            if (inputMap.containsKey('Rating_5__c'))
                visitDetails.Rating_5__c = (String) inputMap.get('Rating_5__c');
            update visitDetails;
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('{"message":"Feedback updated successfully."}');
        } catch (QueryException qe) {
            res.statusCode = 404;
            res.responseBody = Blob.valueOf('{"error":"No feedback record found for the provided visitId."}');
        } catch (Exception ex) {
            System.debug('Error Message = ' + ex.getMessage());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error":"Something went wrong while updating feedback."}');
        }
    } 
    

}