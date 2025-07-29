@RestResource(urlMapping='/truecopycallback/*')
global class TrueCopyCallbackService {
    
    @HttpGet
    global static void handleCallback() {
        // Extract GET parameters from the params map
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        String uuid = req.params.get('uuid');
        String cs = req.params.get('cs');
        String status = req.params.get('status');
        String info = req.params.get('info');
        String mi = req.params.get('mi');
        String grp = req.params.get('grp');
        
        System.debug('Callback received: uuid=' + uuid + ', status=' + status + ', info=' + info);
                Integer startID = uuid.indexOf('ID_') + 3;  // Start right after "ID_"
                String bookingformId = uuid.substring(startID, startID + 18);  // Extract 18 characters
                
                 Booking_Form__c bookrec = [SELECT Id,Is_Booking_Form_Signed__c
                                         FROM Booking_Form__c WHERE Id = :bookingformId LIMIT 1];
        // Check the status
        if ((status == 'SIGNED' || status == 'APPROVED') && bookrec.Is_Booking_Form_Signed__c== false ) {
            // Proceed to download the signed document
            Blob pdfContent = fetchSignedFile(uuid, cs);
            
            // If a PDF is successfully retrieved, save it to Salesforce
            if (pdfContent != null) {
                saveSignedDocument(pdfContent, uuid);
                Integer startPos = uuid.indexOf('ID_') + 3;  // Start right after "ID_"
                String bookingId = uuid.substring(startPos, startPos + 18);  // Extract 18 characters
                
                 Booking_Form__c book = [SELECT Id, First_Name__c, Last_Name__c, Email__c, Owner.Email,
                                         Booking_Form_Status__c,Is_Booking_Form_Signed__c
                                         FROM Booking_Form__c WHERE Id = :bookingId LIMIT 1];
                 book.Is_Booking_Form_Signed__c = TRUE;
                 update book;
                
                res.responseBody = Blob.valueOf('File successfully saved.');
                res.statusCode = 200;
            } else {
                res.responseBody = Blob.valueOf('No file retrieved.');
                res.statusCode = 500;
                // Handle the case where no file is retrieved
            }
        }
        else if (status == 'REJECTED') { 
            Integer startPos = uuid.indexOf('ID_') + 3;  // Start right after "ID_"
            String bookingId = uuid.substring(startPos, startPos + 18);  // Extract 18 characters
           Booking_Form__c book = [SELECT Id, First_Name__c, Last_Name__c, Email__c, Owner.Email,Owner.Name,
                                   Booking_Form_Status__c,Is_Booking_Form_Signed__c,Normal_Approval_Status__c,
                                   SDS_Approvel_Status__c,NDS_Approval_Status__c,isBookingFormEmailSent__c
                                   FROM Booking_Form__c WHERE Id = :bookingId LIMIT 1];
            
            
            // Fetch owner email and name correctly (no need for getSObject)
            String ownerEmail = book.Owner.Email;
            String ownerName = book.Owner.Name;
            
            // Update description with relevant details
                book.Booking_Form_Status__c = 'Draft Save';
                book.Is_Booking_Form_Signed__c = FALSE;
                book.Normal_Approval_Status__c = '';
                book.SDS_Approvel_Status__c = '';
                book.NDS_Approval_Status__c = '';
                book.isBookingFormEmailSent__c = FALSE;
               update book;  
            
            // Send email to the owner
           
           // sendMailtoOwner(ownerEmail, bookingId, ownerName);
            
            
        } else {
            res.responseBody = Blob.valueOf('Callback received but not SIGNED.');
            res.statusCode = 200;
        }
        
    }
    
    
    public static void sendMailtoOwner(String ownerEmail, String bookingId, String ownerName) {
        try {
            // Create an email instance
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // email.setOrgWideEmailAddressId('krushnatidke.sfdc@gmail.com');
            // Set email properties
            email.setToAddresses(new String[] { ownerEmail });
            email.setSubject('Booking Confirmation - ' + bookingId);
            
            // Construct the email body
            String emailBody = '<p>Hello ' + ownerName + ',</p>' +
                '<p>The booking form with ID <b>' + bookingId + '</b> has been rejected.</p>' +
                '<p>Thank you.</p>';
            email.setHtmlBody(emailBody);
            
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            
            System.debug('Email successfully sent to ' + ownerEmail);
        } catch (Exception e) {
            System.debug('Error sending email: ' + e.getMessage());
           //throw new EmailException('Email failed to send: ' + e.getMessage());
        }
    }
    
    // Method to save the signed document in Salesforce
    public static void saveSignedDocument(Blob pdfBlob, String uuid) {
        // Save as ContentVersion
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Signed Booking Form ' + uuid;
        cv.VersionData = pdfBlob;
        cv.PathOnClient = 'SignedDocument_' + uuid + '.pdf';
        insert cv;
        System.debug('Signed document saved in Salesforce.');
        
        // Extract the Opportunity ID from the UUID if possible (assuming uuid contains "ID_" followed by the 18-character Opportunity ID)
        Integer startPos = uuid.indexOf('ID_') + 3;  // Start right after "ID_"
        String bookingId = uuid.substring(startPos, startPos + 18);  // Extract 18 characters
        
        System.debug('Extracted Opportunity ID: ' + bookingId);
        
        Id bookingformId = bookingId;
        
        // Step 4: Retrieve the ContentDocumentId after insertion (generated automatically by Salesforce)
        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        System.debug('ContentDocumentId for the inserted ContentVersion: ' + cv.ContentDocumentId);
        
        // Step 5: Create ContentDocumentLink to associate the ContentVersion with the Opportunity
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId; 
        cdl.LinkedEntityId = bookingformId;  
        cdl.ShareType = 'V';  // Viewer permission (you can change to 'C' for Collaborator)
        cdl.Visibility = 'AllUsers';  // Set visibility (AllUsers or InternalUsers)
        
        // Step 6: Insert the ContentDocumentLink to associate the file with the Opportunity
        insert cdl;
        System.debug('File successfully linked to Booking Form ID: ' + bookingformId);
    }
    
    // This method calls the external API to fetch the signed file
    public static Blob fetchSignedFile(String uuid, String cs) {
        // Build the endpoint URL dynamically
        String endpoint = 'https://ramky.truecopy.in/services/corpservice/v2/fetchsignedfile/' + uuid + '/' + cs;
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');  // Use GET method as you are fetching data
        req.setTimeout(120000); // Timeout set to 120 seconds (can be adjusted)
        
        // Optional: Add Authorization header if needed (uncomment the next line if required)
        // req.setHeader('Authorization', 'Bearer ' + '<your_auth_token>');
        
        try {
            // Send the HTTP request and capture the response
            HttpResponse res = http.send(req);
            
            // Check if the status code is 200 (OK) - successful response
            if (res.getStatusCode() == 200) {
                System.debug('Response Body: ' + res.getBody());
                
                // Convert response body (PDF file content) to Blob
                return res.getBodyAsBlob();
            } else {
                System.debug('Error Response: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            // Catch any exceptions and log the error
            System.debug('Exception: ' + e.getMessage());
        }
        
        // Return null if something went wrong
        return null;
    }
}