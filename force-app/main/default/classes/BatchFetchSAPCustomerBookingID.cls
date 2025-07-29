global class BatchFetchSAPCustomerBookingID implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Project_Meterial__c
            FROM Booking_Form__c
            WHERE Sales_Document__c = null 
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Booking_Form__c> scope) {
        List<Booking_Form__c> bookingsToUpdate = new List<Booking_Form__c>();
        
        for (Booking_Form__c booking : scope) {
            try {
                String baseUrl = Label.SAPBookingIdEndPoint;
                String queryParams = '?$SalesForceID=\'' + booking.Id + '\'&Unit=\'' + booking.Project_Meterial__c + '\'';
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint(baseUrl + queryParams);
                req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(Label.SAPStatementAuth)));
                Http http = new Http();
                HttpResponse res = http.send(req);
                if (res.getStatusCode() == 200 && String.isNotBlank(res.getBody())) {
                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    if (jsonResponse.containsKey('d')) {
                        Map<String, Object> invoiceSet = (Map<String, Object>) jsonResponse.get('d');
                        if (invoiceSet.containsKey('BookingID')) {
                            booking.Sales_Document__c = String.valueOf(invoiceSet.get('BookingID'));
                            bookingsToUpdate.add(booking);
                        }
                    }
                }
                
            } catch (Exception e) {
                System.debug('Error processing Booking_Form__c Id: ' + booking.Id + ' - ' + e.getMessage());
            }
        }
        
        if (!bookingsToUpdate.isEmpty()) {
            try {
                update bookingsToUpdate;
            } catch (Exception e) {
                System.debug('Error updating records: ' + e.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}