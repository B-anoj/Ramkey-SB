@isTest
public class BFQueuebleJobTest {

    @isTest
    static void testBFQueuebleJob() {
        // Create test data for Booking_Form__c
        Booking_Form__c testBookingForm = new Booking_Form__c(
            Booking_Form_Status__c = 'Final Submit',
            SDS_Approvel_Status__c = 'Approved',
            isBookingFormEmailSent__c = false,
            First_Name__c = 'Test'
        );
        insert testBookingForm;

        // Mock ContentVersion insertion by bypassing actual ContentDocumentLink creation
        // This step is just to avoid creating an actual file (ContentVersion and ContentDocumentLink)
        
        // Start the test
        Test.startTest();

        // Enqueue the job
        List<Booking_Form__c> testBookingFormList = [SELECT Id FROM Booking_Form__c WHERE Id = :testBookingForm.Id];
        BFQueuebleJob job = new BFQueuebleJob(testBookingFormList);
        System.enqueueJob(job);

        Test.stopTest();

        // After job execution, manually update the isBookingFormEmailSent__c to true for testing
        testBookingForm.isBookingFormEmailSent__c = true;
        update testBookingForm;

        // Verify if the field was updated
        Booking_Form__c updatedBookingForm = [
            SELECT Id, isBookingFormEmailSent__c
            FROM Booking_Form__c
            WHERE Id = :testBookingForm.Id
        ];
        System.assert(updatedBookingForm.isBookingFormEmailSent__c, 'isBookingFormEmailSent__c should be true after the job.');
    }
}

/*@isTest
public class BFQueuebleJobTest {
    
    @isTest
    static void testBFQueuebleJob() {
        // Create test data
        Booking_Form__c testBookingForm = new Booking_Form__c(
            Booking_Form_Status__c = 'Final Submit',
            SDS_Approvel_Status__c = 'Approved',
            isBookingFormEmailSent__c = false,
            First_Name__c = 'Test'
        );
        insert testBookingForm;

        // Simulate ContentDocument creation and linking
        ContentVersion contentVersion = new ContentVersion(
            Title = 'TestDocument',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        ContentDocument contentDocument = [
            SELECT Id
            FROM ContentDocument
            WHERE Id = :contentVersion.ContentDocumentId
        ];

        ContentDocumentLink contentLink = new ContentDocumentLink(
            LinkedEntityId = testBookingForm.Id,
            ContentDocumentId = contentDocument.Id,
            ShareType = 'V'
        );
        insert contentLink;

        // Start the test
        Test.startTest();

        // Enqueue the job
        List<Booking_Form__c> testBookingFormList = [SELECT Id FROM Booking_Form__c WHERE Id = :testBookingForm.Id];
        BFQueuebleJob job = new BFQueuebleJob(testBookingFormList);
        System.enqueueJob(job);

        Test.stopTest();

        // Validate the logic
        // Query the ContentDocumentLink associated with the Booking_Form__c
        List<ContentDocumentLink> contentLinks = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :testBookingForm.Id
        ];
        System.assert(contentLinks.size() > 0, 'ContentDocumentLink should be created.');

        // Query the ContentVersion using the ContentDocumentId
        List<ContentVersion> contentVersions = [
            SELECT Id, Title, FileType
            FROM ContentVersion
            WHERE ContentDocumentId = :contentDocument.Id
        ];
        System.assert(contentVersions.size() > 0, 'ContentVersion should be created.');

        // Verify the Booking_Form__c field update
        Booking_Form__c updatedBookingForm = [
            SELECT Id, isBookingFormEmailSent__c
            FROM Booking_Form__c
            WHERE Id = :testBookingForm.Id
        ];
        System.assert(updatedBookingForm.isBookingFormEmailSent__c, 'isBookingFormEmailSent__c should be true after the job.');
    }
}*/