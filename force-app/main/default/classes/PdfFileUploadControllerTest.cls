@IsTest
public class PdfFileUploadControllerTest {
    
    @IsTest
    static void testFileUpload_Success() {
        // Create a test record (e.g., an Account) to use as the recordId
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Define the parameters for a successful file upload
        Id recordId = testAccount.Id;
        String fileName = 'TestFile.pdf';
        String fileContent = EncodingUtil.base64Encode(Blob.valueOf('Sample content for file upload'));

        Test.startTest();
        PdfFileUploadController.uploadFile(recordId, fileName, fileContent);
        Test.stopTest();

        // Query the ContentVersion record to verify it was created
        ContentVersion[] contentVersions = [SELECT Id, Title, FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId = :recordId];
        System.assertEquals(1, contentVersions.size(), 'ContentVersion should be created');
        System.assertEquals(fileName, contentVersions[0].Title, 'File name should match');
        System.assertEquals(recordId, contentVersions[0].FirstPublishLocationId, 'Record ID should match');
    }
}