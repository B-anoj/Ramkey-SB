public class BookingFormCreationEmailHandler {
    
    public static void handleAfterInsertOrUpdate(List<Booking_Form__c> records) {
        // Query the metadata to determine if jobs are allowed
        JobControl__mdt jobControl = JobControl__mdt.getInstance('Queueable_Job_Control');
        Boolean allowQueueableJob = jobControl != null ? jobControl.Allow_Queueable_Job__c : false;
        
        List<Booking_Form__c> lstTemp = new List<Booking_Form__c>();
        for (Booking_Form__c record : records) {
            if ((record.Booking_Form_Status__c == 'Final Submit' && record.SDS_Approvel_Status__c == 'Approved' && record.isBookingFormEmailSent__c == false) ||
                (record.Booking_Form_Status__c == 'Final Submit' && record.Normal_Approval_Status__c == 'Approved' && record.isBookingFormEmailSent__c == false) ||
                (record.Booking_Form_Status__c == 'Final Submit' && record.NDS_Approval_Status__c == 'Approved' && record.isBookingFormEmailSent__c == false)) {
                    lstTemp.add(record);
                }
        }
        
        // Skip enqueueing jobs in test context or if metadata indicates false in production
        if (!lstTemp.isEmpty() && (Test.isRunningTest() || allowQueueableJob)) {
            System.enqueueJob(new BFQueuebleJob(lstTemp));
        } else {
            System.debug('Queueable job skipped based on metadata configuration or test context.');
        }
    }
    
    //@future(callout = true)
    public static void CreatePDF(string BFstr)
    {
        
        //Callout to create Individual PDF at Prelien Group Items
        list<Approver__c> ApproverDetails = new list<Approver__c>();
        List<Messaging.SingleEmailMessage> TJemails = new List<Messaging.SingleEmailMessage>();
        
        Booking_Form__c BFrec =  (Booking_Form__c)System.JSON.deserialize(BFstr, Booking_Form__c.class);        
        if ((BFrec.Booking_Form_Status__c == 'Final Submit' && BFrec.SDS_Approvel_Status__c == 'Approved' && BFrec.isBookingFormEmailSent__c == false) ||
            (BFrec.Booking_Form_Status__c == 'Final Submit' && BFrec.Normal_Approval_Status__c == 'Approved' && BFrec.isBookingFormEmailSent__c == false) ||
            (BFrec.Booking_Form_Status__c == 'Final Submit' && BFrec.NDS_Approval_Status__c == 'Approved' && BFrec.isBookingFormEmailSent__c == false)) {
                
                if(BFrec.Product2__c <> null){
                    List<Product2> ProductDetails = [select id,Sales_Office__c from Product2 where id =: BFrec.Product2__c ];                    
                    if(ProductDetails[0].Sales_Office__c <> null && ProductDetails[0].Sales_Office__c <> null){
                        ApproverDetails = [select Id,Email__c  from Approver__c where Sales_Office__c =:ProductDetails[0].Sales_Office__c and Numeric_1_character__c != 99];
                    }
                }
                
                PageReference pdf = new PageReference('/apex/BookingPDF?Id=' + BFrec.Id);
                Blob body;
                if (Test.isRunningTest()) { 
                    body = Blob.valueOf('Unit.Test');
                } else {
                    body = pdf.getContent();
                }
                
                // Create ContentVersion
                ContentVersion contentVersion = new ContentVersion(
                    Title = BFrec.First_Name__c + '_test', 
                    PathOnClient = 'Test.pdf',
                    VersionData = body, 
                    Origin = 'H'
                );
                insert contentVersion;
                
                ContentVersion insertedContentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];                
                
                ContentDocumentLink contentLink = new ContentDocumentLink();
                contentLink.LinkedEntityId = BFrec.Id;
                contentLink.ContentDocumentId = insertedContentVersion.ContentDocumentId;
                contentLink.ShareType = 'V';
                insert contentLink;
                
                Boolean isAttachment = true;
                Boolean isEmailTemplate = false;
                List<String> clientToAddress = new List<String>();
                
                if(!ApproverDetails.IsEmpty() && ApproverDetails <> null){
                    for(Approver__c  Appemail : ApproverDetails ){
                        if(Appemail.Email__c <> null && Appemail.Email__c <> ''){
                            clientToAddress.add(Appemail.Email__c);
                        }                     
                    }
                }
                
                if(!clientToAddress.isEmpty() <> null){
                    //clientToAddress.add('suguru.pundareeka@lancesoft.in');
                    if(contentVersion.Id <> null){                     
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setSaveAsActivity(false);
                        mail.setToAddresses(clientToAddress);
                        mail.setSubject('Email with Attachment');
                        mail.setPlainTextBody('Please find the attachment below.');
                        List<Messaging.EmailFileAttachment> attachmentList = new List<Messaging.EmailFileAttachment>();
                        List<ContentDocumentLink> ContentList = [select id,ContentDocumentId from ContentDocumentLink where LinkedEntityId =:BFrec.Id];
                        Set<Id> ContenDocumentIds = new Set<Id>();
                        for(ContentDocumentLink  CL: ContentList){
                            ContenDocumentIds.add(CL.ContentDocumentId);
                        } 
                        
                        if(ContenDocumentIds <> null && !ContenDocumentIds.IsEmpty()){
                            List<ContentVersion> ConAttachementDetails = [select id,Title, VersionData, FileType,FileExtension  from ContentVersion where ContentDocumentId in :ContenDocumentIds];
                            
                            if(ConAttachementDetails <> null && !ConAttachementDetails.ISEmpty()){
                                For(ContentVersion  VersionList: ConAttachementDetails){
                                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                                    attachment.setFileName(VersionList.Title);
                                    attachment.setBody(VersionList.VersionData);
                                    String contentType;
                                    if (VersionList.FileExtension == 'pdf') {
                                        contentType = 'application/pdf';
                                    } else if (VersionList.FileExtension == 'png') {
                                        contentType = 'image/png';
                                    } else if (VersionList.FileExtension == 'jpg' || VersionList.FileExtension == 'jpeg') {
                                        contentType = 'image/jpeg';
                                    } else if (VersionList.FileExtension == 'txt') {
                                        contentType = 'text/plain';
                                    } else if (VersionList.FileExtension == 'html') {
                                        contentType = 'text/html';
                                    } else {
                                        // Default content type
                                        contentType = 'application/octet-stream';
                                    } 
                                    attachment.setContentType(contentType);
                                    attachmentList.add(attachment);
                                    
                                }
                            }
                        }
                        
                        // Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                        //attachment.setFileName(contentVersion.Title);
                        //attachment.setBody(body);
                        //attachment.setContentType('application/pdf');             
                        // Attach the file to the email
                        mail.setFileAttachments(attachmentList);
                        TJemails.add(mail);  
                    }
                }
                
                
                if(!TJemails.isEmpty() && TJemails <> null){
                    Messaging.sendEmail( TJemails );
                    Booking_Form__c BFupdate = new Booking_Form__c();
                    BFupdate.isBookingFormEmailSent__c = true;
                    BFupdate.Id = BFrec.Id;
                    update BFupdate;
                    
                } 
                
                
            }
        
    }
    public static Messaging.SingleEmailMessage SendEmail(
        Id templatedId,
        Boolean isTemplateId,
        Id targetObjectId,
        Id whatId,
        List<String> toAddresses,
        Id documentLinkedId,
        Boolean isAttachment,
        Map<Id, ContentVersion> attachmentContent
    ) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);
        email.setSubject('Test Subject');
        email.setPlainTextBody('Test Body');

        // Add attachments if required
        if (isAttachment && attachmentContent.containsKey(documentLinkedId)) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(attachmentContent.get(documentLinkedId).Title);
            attachment.setBody(attachmentContent.get(documentLinkedId).VersionData);
            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{ attachment });
        }

        return email;
    }
}