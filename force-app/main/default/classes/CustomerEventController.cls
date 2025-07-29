public without sharing class CustomerEventController {
    @AuraEnabled(cacheable=true)
    public static List<EventWrapper> getEventDetails() {
        List<Event__c> events = [SELECT Id, Name, Description__c, Event_Date__c, Event_End_Time__c, Event_Start_Time__c, Location__c ,CreatedDate
                                 FROM Event__c WHERE Event_Date__c >= TODAY];
        
        List<EventWrapper> wrappers = new List<EventWrapper>();
        
        for (Event__c evt : events) {
            EventWrapper e = new EventWrapper();
            e.id = evt.Id;
            e.title = evt.Name;
            e.description = evt.Description__c;
            
            String dateStr = evt.Event_Date__c != null ? evt.Event_Date__c.format() : '';
            String startTime = evt.Event_Start_Time__c != null ? String.valueOf(evt.Event_Start_Time__c).substring(0,5) : '';
            String endTime = evt.Event_End_Time__c != null ? String.valueOf(evt.Event_End_Time__c).substring(0,5) : '';
            e.eventDateTime = dateStr + ' ' + startTime + ' – ' + endTime;
            
            e.location = evt.Location__c;
            wrappers.add(e);
        }
        return wrappers;
    }
    
    @AuraEnabled
    public static String registerCustomer(Id eventId, String userEmail) {
        try {
            if (eventId != null && userEmail != null) {
                // Check if already registered
                List<Registered_Customer__c> existing = [
                    SELECT Id 
                    FROM Registered_Customer__c 
                    WHERE Event__c = :eventId AND Contact__r.Email = :userEmail 
                    LIMIT 1
                ];
                
                if (!existing.isEmpty()) {
                    return 'Already Registered';
                }
                
                // Find the contact based on email
                List<Contact> contactList = [SELECT Id FROM Contact WHERE Email = :userEmail LIMIT 1];
                if (contactList.isEmpty()) {
                    return 'No contact found with this email';
                }
                
                Contact userContact = contactList[0];
                
                // Create registration record
                Registered_Customer__c rc = new Registered_Customer__c();
                rc.Event__c = eventId;
                rc.Contact__c = userContact.Id;
                insert rc;
                
                return 'Success';
            }
            
            return 'Invalid input';
        } catch (Exception e) {
            System.debug('Error at Line Number ======> ' + e.getLineNumber() + ' Error Message =====> ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    } 
    
    public class EventWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String title;
        @AuraEnabled public String description;
        @AuraEnabled public String eventDateTime;
        @AuraEnabled public String location;
    }
}