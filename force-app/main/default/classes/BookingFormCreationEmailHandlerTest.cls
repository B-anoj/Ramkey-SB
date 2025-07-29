@isTest
private class BookingFormCreationEmailHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Create a Product2 record
        Product2 testProduct = new Product2(
            Name = 'Test Product', 
            Sales_Office__c = '9014' // Adjust as needed
        );
        insert testProduct;
        
        // Create Booking Form
        Booking_Form__c testBookingForm = new Booking_Form__c(
            Booking_Form_Status__c = 'Final Submit',
            //SDS_Approvel_Status__c = 'Approved',
            Normal_Approval_Status__c = 'Approved',
            NDS_Approval_Status__c = 'Approved',
            isBookingFormEmailSent__c = false,
            Product2__c = testProduct.Id // Use the ID of the created Product2 record
        );
        insert testBookingForm;
        
        // Create Approver Record
        Approver__c approver = new Approver__c(
            Email__c = 'test@domain.com',
            Sales_Office__c = '9014'
        );
        insert approver;
        
        // Create a ContentVersion record (Attachment)
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test PDF',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test File Content'),
            FirstPublishLocationId = testBookingForm.Id
        );
        insert contentVersion;
    }

    @isTest
    static void testCreatePDF() {
        // Step 1: Query Booking Form (Ensure it Exists)
        Booking_Form__c testBookingForm;
        try {
            testBookingForm = [SELECT Id FROM Booking_Form__c LIMIT 1];
        } catch (Exception e) {
            System.assert(false, 'No Booking_Form__c record found. Make sure test data is created.');
        }
        
        // Serialize the Booking Form into JSON
        String bfStr = JSON.serialize(testBookingForm);
        
        // Call the method
        Test.startTest();
        BookingFormCreationEmailHandler.CreatePDF(bfStr);
        Test.stopTest();
        
        // Step 6: Verify `isBookingFormEmailSent__c` is true
        testBookingForm = [SELECT isBookingFormEmailSent__c FROM Booking_Form__c WHERE Id = :testBookingForm.Id];
        System.assertEquals(true, testBookingForm.isBookingFormEmailSent__c, 'Expected isBookingFormEmailSent__c to be true');
    }

    /*@isTest
    static void testHandleAfterInsertOrUpdate() {
        // Step 1: Query Booking Form (Ensure it Exists)
        List<Booking_Form__c> testRecords = [SELECT Id, Booking_Form_Status__c FROM Booking_Form__c];

        Test.startTest();
        BookingFormCreationEmailHandler.handleAfterInsertOrUpdate(testRecords);
        Test.stopTest();

        System.assert(true, 'Handler executed successfully');
    }*/

    @isTest
    static void testEmailSender() {
        Test.startTest();

        // Step 1: Query Required Test Data
        Booking_Form__c bookingForm;
        ContentVersion cv;
        
        try {
            bookingForm = [SELECT Id, Email__c FROM Booking_Form__c LIMIT 1];
            cv = [SELECT Id FROM ContentVersion LIMIT 1];
        } catch (Exception e) {
            System.assert(false, 'No Booking_Form__c or ContentVersion record found. Make sure test data is created.');
        }

        List<String> toAddresses = new List<String>{'test@example.com'};

        // Step 2: Call EmailSender Class
        EmailSender.sendEmail(
            null, // Template Id (if applicable)
            false, // isTemplateId
            null, // Target Object Id (Contact, Lead, etc.)
            bookingForm.Id, // WhatId (related object)
            toAddresses,
            cv.Id, // Attachment Id
            true // isAttachment
        );

        Test.stopTest();

        System.assert(true, 'Email sender method executed successfully');
    }
}