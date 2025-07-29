public class PdfUploaderService {
     //TrueCopyCallbackService callback class
    // Method to handle stage change and upload the PDF
    @future(callout=true)
    public static void processBookingFormApproved(Id bookingformId) {
        try {
            // Step 1: Query the ContentDocumentLink to get the ContentDocumentId
            List<ContentDocumentLink> contentLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :bookingformId
            ];

            // Ensure there is at least one linked document
            if (contentLinks.isEmpty()) {
                System.debug('No content document found for Opportunity ID: ' + bookingformId);
                return;
            }
            Set<Id> contentDocumentIds = new Set<Id>();
                    for (ContentDocumentLink link : contentLinks) {
                        contentDocumentIds.add(link.ContentDocumentId);
                    }
            // Step 2: Query the ContentVersion using the ContentDocumentId and fetch file name
             List<ContentVersion> pdfContentVersions = [
                SELECT VersionData, Title 
                FROM ContentVersion 
                WHERE ContentDocumentId IN :contentDocumentIds
                AND FileType = 'PDF'
                AND Title LIKE '%test' 
                ORDER BY createdDate DESC Limit 1
                
            ];

            // Ensure the PDF was found
            if (pdfContentVersions.isEmpty()) {
                System.debug('No PDF version found for ContentDocumentId: ' + pdfContentVersions[0].ContentDocumentId);
                
                return;
            }

            // Convert the VersionData (binary data) to Base64
            String base64PDF = EncodingUtil.base64Encode(pdfContentVersions[0].VersionData);

            // Step 3: Fetch Booking_Form__c details
             Booking_Form__c book = [SELECT First_Name__c, Last_Name__c, Email__c,Customer_Type__c,Sign_through_Digital_Signature__c FROM Booking_Form__c WHERE Id = :bookingformId LIMIT 1];
          //Opportunity book = [SELECT Name, Email__c FROM Opportunity WHERE Id = :bookingformId LIMIT 1];
           LIST<Other_Applicants__c> appli = [SELECT First_Name__c, Last_Name__c, Email__c, Booking_Form__c FROM Other_Applicants__c WHERE Booking_Form__c = :book.id];
            
            if (book == null) {
                System.debug('No Booking Form found for the provided Booking Form Id: ' + bookingformId);
                return;
            }
             // String customerName = book.Name;
             String customerName = book.First_Name__c + ' ' + book.Last_Name__c;
            String customerEmail = book.Email__c;

            // Variables to store each applicant's name and email
                String app1Name = '';
                String app1Email = '';
                String app2Name = '';
                String app2Email = '';
                String app3Name = '';
                String app3Email = '';
                String app4Name = '';
                String app4Email = '';
                
                // Loop through each applicant and assign to variables
               
            
            if(appli != null){
                Integer index = 0;
                for (Other_Applicants__c applicant : appli) {
                    String applicantName = applicant.First_Name__c + ' ' + applicant.Last_Name__c;
                    String applicantEmail = applicant.Email__c;
                
                    if (index == 0) {
                        app1Name = applicantName;
                        app1Email = applicantEmail;
                    } else if (index == 1) {
                        app2Name = applicantName;
                        app2Email = applicantEmail;
                    } else if (index == 2) {
                        app3Name = applicantName;
                        app3Email = applicantEmail;
                    } else if (index == 3) {
                        app4Name = applicantName;
                        app4Email = applicantEmail;
                    }
                    
                    index++;
                }
                
            }
            
            // System.debug for all variables
                System.debug('app1Name: ' + app1Name);
                System.debug('app1Email: ' + app1Email);
                System.debug('app2Name: ' + app2Name);
                System.debug('app2Email: ' + app2Email);
                System.debug('app3Name: ' + app3Name);
                System.debug('app3Email: ' + app3Email);
                System.debug('app4Name: ' + app4Name);
                System.debug('app4Email: ' + app4Email);
            
            // API Key and UUID (derived from file name or other logic)
            String apiKey = 'HZQOQ8B7WY2NWXJS6OKH18LW7VQ6HKQP';  // Replace with the actual API key
           
             // Step 4: Generate the UUID in the format QARAMKY14_10_2024_1513491
            Datetime currentDateTime = Datetime.now();
            String day = currentDateTime.format('dd');
            String month = currentDateTime.format('MM');
            String year = currentDateTime.format('yy');
            String hour = currentDateTime.format('HH');
            String minute = currentDateTime.format('mm');
            String second = currentDateTime.format('ss');
            String millisecond = String.valueOf(Datetime.now().millisecond());

            String uuid = 'RAM' + day + month + year + hour + minute + second + millisecond + 'ID_' + bookingformId;
            // Log UUID and API Key for debugging purposes
            System.debug('Generated UUID: ' + uuid);
            System.debug('Using API Key: ' + apiKey);

            // Concatenate API key, UUID, and Base64 PDF for SHA-256 hash
            String dataToHash = apiKey + uuid;

            // Calculate the SHA-256 hash of the concatenated string (API Key + UUID + Base64 PDF)
            String cs = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(dataToHash)));

            System.debug('Calculated CS: ' + cs);

            // Prepare the HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://ramky.truecopy.in/services/corpservice/v2/uploadfilejson');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            // Add API Key in the header if needed
            req.setHeader('API-Key', apiKey);  // API Key in the header

           // Initialize the signer list as a String to build dynamically
            String signerList = '[';
            
            // Add the primary signer
            signerList += '{'
                + '"signer": "' + customerEmail + '",'
                + '"signer_name": "' + customerName + '",'
                + '"signloc": "L[132:270]",'
                + '"seq_no": 1,'
                + '"parallel_index": 1'
                + '}';
            
            // Initialize sequence number for additional signers
            Integer seqNo = 2;
            
            // Append optional signers conditionally
            if (app1Name != '' && app1Email != '') {
                signerList += ',{'
                    + '"signer": "' + app1Email + '",'
                    + '"signer_name": "' + app1Name + '",'
                    + '"signloc": "L[437:251]",'
                    + '"seq_no": ' + seqNo + ','
                    + '"parallel_index": 1'
                    + '}';
                seqNo++;
            }
            
            if (app2Name != '' && app2Email != '') {
                signerList += ',{'
                    + '"signer": "' + app2Email + '",'
                    + '"signer_name": "' + app2Name + '",'
                    + '"signloc": "L[434:187]",'
                    + '"seq_no": ' + seqNo + ','
                    + '"parallel_index": 1'
                    + '}';
                seqNo++;
            }
            
            if (app3Name != '' && app3Email != '') {
                signerList += ',{'
                    + '"signer": "' + app3Email + '",'
                    + '"signer_name": "' + app3Name + '",'
                    + '"signloc": "L[431:113]",'
                    + '"seq_no": ' + seqNo + ','
                    + '"parallel_index": 1'
                    + '}';
                seqNo++;
            }
            
            if (app4Name != '' && app4Email != '') {
                signerList += ',{'
                    + '"signer": "' + app4Email + '",'
                    + '"signer_name": "' + app4Name + '",'
                    + '"signloc": "L[433:42]",'
                    + '"seq_no": ' + seqNo + ','
                    + '"parallel_index": 1'
                    + '}';
            }
            
            // Close the signer list
            signerList += ']';
            
            String workflowId;
            if (book.Customer_Type__c =='Indian Resident' && book.Sign_through_Digital_Signature__c == TRUE) {
                   workflowId = 'WFRAMK101224DBXVSSNF6ESE42WL'; // Workflow for Indian Resident with digital signature
              } 
            else if (book.Customer_Type__c == 'Indian Resident' && book.Sign_through_Digital_Signature__c == FALSE) {
                   workflowId = 'WFRAMK101224DB4NTD8B4NBDRKMF'; // Workflow for Indian Resident without digital signature
               } 
            else {
                   workflowId = 'WFRAMK101224DBXVSSNF6ESE42WL'; // Fallback workflow ID
                       }

             System.debug('File uploaded: ' + signerList);
            // Construct the final JSON payload
            String jsonBody = '{'
                + '"uuid": "' + uuid + '",'
                + '"cs": "' + cs + '",'
                + '"initiator": "helpdesk+ramkyapiuser@truecopy.com",'
                + '"callbackurl": "https://ramky-estates-and-farms.my.salesforce-sites.com/ramky/services/apexrest/truecopycallback",'
                + '"workflow_id": "' + workflowId + '",'
                + '"signerlist": ' + signerList + ','
                + '"uploadfile": "' + base64PDF + '"'
                + '}';
            
               
                req.setBody(jsonBody);

            // Send the HTTP request
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('File uploaded: ' + jsonBody);

            // Check response status
            if (res.getStatusCode() ==200) {
                System.debug('File uploaded successfully' + res.getStatusCode() + ', Response: ' + res.getBody());
            } else {
                System.debug('Failed to upload file. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Error during PDF processing: ' + e.getMessage());
        }
    }
}