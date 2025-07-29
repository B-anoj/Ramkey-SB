public class EmailSender {
    @future
    public static void sendEmail(
        Id templatedId,
        Boolean isTemplateId,
        Id targetObjectId,
        Id whatId,
        List<String> toAddresses,
        Id documentLinkedId,
        Boolean isAttachment
    ) {
        // Fetch the ContentVersion data asynchronously
        ContentVersion cv = [SELECT Id, Title, VersionData, FileType FROM ContentVersion WHERE Id = :documentLinkedId LIMIT 1];
        
        Map<Id, ContentVersion> attachmentContent = new Map<Id, ContentVersion>{cv.Id => cv};
        
        // ✅ Call the correct method with correct parameters
        Messaging.SingleEmailMessage email = BookingFormCreationEmailHandler.SendEmail(
            templatedId,
            isTemplateId,
            targetObjectId,
            whatId,
            toAddresses,
            documentLinkedId,
            isAttachment,
            attachmentContent
        );
        
        // Send the email
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }
}