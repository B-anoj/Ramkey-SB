@RestResource(urlMapping='/events')
global class API_Customer_Event {
    global class EventWrapper {
        public String id;
        public String title;
        public String description;
        public String startDate;
        public time start_time;
        public time end_time;
        public String location;
        public String banner_image;
    }

    global class EventsResponse {
        public List<EventWrapper> events;
    }

    @HttpGet
    global static void getEventDetails() {
        RestResponse res = RestContext.response;
        EventsResponse response = new EventsResponse();
        response.events = new List<EventWrapper>();

        try {
            List<Event__c> customerEvents = [
                SELECT Id, Name, Event_Date__c, Event_Start_Time__c, Event_End_Time__c, 
                       Description__c, Location__c 
                FROM Event__c WHERE Event_Date__c >= Today
            ];

            for (Event__c e : customerEvents) {
                EventWrapper event = new EventWrapper();
                event.id = e.Id;
                event.title = e.Name;
                event.description = e.Description__c;
                event.StartDate = String.valueOf(e.Event_Date__c);
                event.start_time = e.Event_Start_Time__c;
                event.end_time = e.Event_End_Time__c;
                event.location = e.Location__c;
                event.banner_image = 'https://firebasestorage.googleapis.com/v0/b/rockland-e886b.firebasestorage.app/o/Project%2F8d15345cc3549e786c84d66d892700cf980c7d63.jpg?alt=media&token=f9aed359-054d-4c98-904c-7ff0df0fa36a'; 
                response.events.add(event);
            }

            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;

        } catch (Exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error": "' + ex.getMessage() + '"}');
        }
    }
    @HttpPost
    global static String registerCustomerEvent(String eventId, String userEmail) {
        System.debug('Event =' + eventId + '' + 'Email =' + userEmail);
        String successMessage;
        try {
            List<Contact> contactList = [
                SELECT Id 
                FROM Contact 
                WHERE Email = :userEmail 
                LIMIT 1
            ];
            
            if (contactList.isEmpty()) {
                successMessage = 'No customer found with the provided email.';
                return successMessage;
            }
            
            Contact customerData = contactList[0];
            
            List<Event_Register__c> existingRegistrations = [
                SELECT Id 
                FROM Event_Register__c 
                WHERE Contact__c = :customerData.Id 
                AND Event__c = :eventId
                LIMIT 1
            ];
            
            if (!existingRegistrations.isEmpty()) {
                successMessage = 'Your already registered for the event.';
            } else {
                Event_Register__c newRegistration = new Event_Register__c();
                newRegistration.Event__c = eventId;
                newRegistration.Contact__c = customerData.Id;
                insert newRegistration;
                System.debug('Register Event =' + newRegistration);
                successMessage = 'Customer has been successfully registered for the event.';
            }
            
        } catch (Exception ex) {
            System.debug('Error Message = ' + ex.getMessage());
            successMessage = 'An error occurred while processing the registration.';
        }
        
        return successMessage;
    }


}