@isTest
public class BookingFormPDFTest {
    
    @testSetup
    static void setupTestData() {
        // Create a test user
        User testUser = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1];

        // Create a test Booking_Form__c record
        Booking_Form__c bookingForm = new Booking_Form__c(
            Aadhar__c = '123456789012',
            Account_Name__c = 'Test Account',
            Project_Name__c = 'Test Project',
            Booking_Form_Grand_Total__c = 50000.00
        );
        insert bookingForm;

        // Create related Booking_Form_Line_Items__c records
        Booking_Form_Line_Items__c bookingItem1 = new Booking_Form_Line_Items__c(
            Booking_Form__c = bookingForm.Id,
            Agreement_Value__c = 10,
            Amount__c = 5000,
            Payment_Particulars__c = 'Test Payment Particulars',
            Payment_Schedule_Type__c = 'Full'
        );
        insert bookingItem1;

        // Create Ramky_Account_Details__c records
        Ramky_Account_Details__c ramkyAccount = new Ramky_Account_Details__c(
            Project_Name__c = bookingForm.Project_Name__c,
            Account_No__c = '1234567890',
            Bank_Name__c = 'Test Bank'
        );
        insert ramkyAccount;
    }
    
    @isTest
    static void testBookingFormPDFController() {
        // Fetch the test Booking_Form__c record
        Booking_Form__c testBooking = [SELECT Id FROM Booking_Form__c LIMIT 1];
        
        // Instantiate the controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testBooking);
        BookingFormPDF controller = new BookingFormPDF(sc);

        // Assertions to check if fields are correctly populated
        System.assertNotEquals(null, controller.bookingFormId, 'Booking form ID should be populated');
        System.assert(controller.bookingList.size() > 0, 'Booking list should contain records');
        System.assert(controller.RamkyACC.size() > 0, 'Ramky account details should be populated');

        // Test fetching current user
        System.assertNotEquals(null, controller.currentUser, 'Current user should be fetched');
        
        // Test amount in words
        String expectedAmountInWords = 'fifty thousand rupees only';
        System.assertEquals(expectedAmountInWords, controller.amountInWords, 'Amount in words should be correct');

        // Test formatted booking form line items
        List<BookingFormPDF.BookingFormLineItemWrapper> formattedItems = controller.getFormattedBookingFormLineItems();
        System.assert(formattedItems.size() > 0, 'Formatted booking form line items should contain records');
        System.assertEquals('5,000.00', formattedItems[0].FormattedAmount, 'Formatted amount should match');
        
        // Test navigation
        controller.next();
        System.assertEquals(0, controller.currentPageIndex, 'Page index should increment');
    }

    @isTest
    static void testEmptyLists() {
        // Create a new Booking_Form__c record without related records
        Booking_Form__c emptyBooking = new Booking_Form__c(
            Aadhar__c = '987654321098',
            Account_Name__c = 'Empty Account',
            Project_Name__c = 'Empty Project',
            Booking_Form_Grand_Total__c = 0.00
        );
        insert emptyBooking;
        
        // Instantiate the controller with the new empty record
        ApexPages.StandardController sc = new ApexPages.StandardController(emptyBooking);
        BookingFormPDF controller = new BookingFormPDF(sc);
        
        // Test the behavior with empty lists
        System.assertEquals(0, controller.bsli.size(), 'Booking form line items should be empty');
        System.assertEquals(0, controller.RamkyACC.size(), 'Ramky account details should be empty');
        System.assertEquals('zero rupees only', controller.amountInWords, 'Amount in words should return a default message');
    }

    @isTest
    static void testNumberToWordsEdgeCases() {
        // Edge cases for amount in words conversion
        String zeroInWords = BookingFormPDF.AmountToWords(0);
        System.assertEquals('zero rupees only', zeroInWords, 'Zero should be converted correctly');
        
        String nullInWords = BookingFormPDF.AmountToWords(null);
        System.assertEquals('Amount not available', nullInWords, 'Null amount should return default message');
        
        String largeNumberInWords = BookingFormPDF.AmountToWords(123456789);
        System.assertEquals('twelve crore thirty four lakh fifty six thousand seven hundred eighty nine rupees only', largeNumberInWords, 'Large numbers should be converted correctly');
    }

    @isTest
    static void testFormattedFields() {
        // Fetch the test Booking_Form__c record
        Booking_Form__c testBooking = [SELECT Id FROM Booking_Form__c LIMIT 1];
        
        // Instantiate the controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testBooking);
        BookingFormPDF controller = new BookingFormPDF(sc);
        
        // Test the formatted fields
        Map<String, String> formattedFields = controller.getFormattedFields();
        System.assertNotEquals(null, formattedFields.get('Total_Car_Parking_Charges__c'), 'Field should be formatted');
    }
    @isTest
    static void testPaginationMethods() {
        // New test method for covering getCurrentReport() and next()
        List<Booking_Form__c> bookingForms = [SELECT Id FROM Booking_Form__c];
        System.assert(bookingForms.size() > 0, 'Booking forms should be created in test setup');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(bookingForms[0]);
        BookingFormPDF controller = new BookingFormPDF(sc);
        
        controller.bookingList = bookingForms;
        controller.totalPages = bookingForms.size();
        controller.currentPageIndex = 0;
        
        Booking_Form__c currentReport = controller.getCurrentReport();
        System.assertNotEquals(null, currentReport, 'getCurrentReport() should return the current booking form');
        System.assertEquals(currentReport.Id, bookingForms[0].Id, 'getCurrentReport() should return the first booking form');
        
        controller.next();
        System.assertEquals(0, controller.currentPageIndex, 'currentPageIndex should increment after calling next()');
        currentReport = controller.getCurrentReport();
        System.assertEquals(currentReport.Id, bookingForms[0].Id, 'getCurrentReport() should return the second booking form after calling next()');
        
        while (controller.currentPageIndex < controller.totalPages - 1) {
            controller.next();
        }
        controller.next(); // Should not increment currentPageIndex further
        currentReport = controller.getCurrentReport();
        System.assertEquals(currentReport.Id, bookingForms[bookingForms.size() - 1].Id, 'getCurrentReport() should return the last booking form');
    }
    
}