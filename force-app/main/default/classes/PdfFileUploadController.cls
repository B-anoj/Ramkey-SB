/*
 * Developer: Pundareeka S
 * Modified: 11/11/2024
 * created On: 11/11/2024 */

public class PdfFileUploadController { 
    @AuraEnabled
    public static void uploadFile(Id recordId, String fileName, String fileContent) {
        if (recordId == null || String.isBlank(fileName) || String.isBlank(fileContent)) {
            throw new AuraHandledException('Invalid file, file name, or record ID.');
        }
        
        try {
            // Create ContentVersion record
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = EncodingUtil.base64Decode(fileContent);
            contentVersion.FirstPublishLocationId = recordId; // Link to the record
            contentVersion.IsMajorVersion = true;

            insert contentVersion;
        } catch (Exception e) {
            throw new AuraHandledException('File upload failed: ' + e.getMessage());
        }
    }
}