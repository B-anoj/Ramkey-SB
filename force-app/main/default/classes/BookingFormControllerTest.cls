@IsTest
public class BookingFormControllerTest { 
    @IsTest
    Public static Void testClassone(){
		Product2 prod = new Product2();
        prod.Project__c = 'Ramky One Karnival';
        prod.Towers__c = 'F';
        prod.Unit__c = '0602';
        prod.Name ='F-0602:R1KB';
        prod.Status__c = '09-Sold Unit';
        prod.Sales_Office__c = '1014';
        insert prod;  
        
        Scheme__c sch = new Scheme__c();
        sch.Name = 'a1j0T0000015DP2';
        sch.Sales_Office__c = '1014';
        sch.Net_Value_in_Doccument_Currency__c = 20000;
        sch.Per_SFT_Amount__c = 0;
        date valuedate = Date.today();
        date valuedatefor = Date.today().addDays(10);
        String valuedateStr = valuedate.format();  
		String valuedateforStr = valuedatefor.format();
        sch.Valid_from__c = valuedateStr;
        sch.Valid_to__c = valuedateforStr;
        insert sch;


		Payment_Schedule__c pmc = new Payment_Schedule__c();
       // pmc.Name = '';
        pmc.Amount_In_Local_Currency__c = 100000;
        pmc.Payment_Particulars__c = 'TOKEN ADVANCE';
        pmc.Payment_Schedule_Type__c = 'REGULAR';
        pmc.Project__c = 'Ramky One Karnival';
        pmc.Sales_Office__c = '1014';
        pmc.Sales_Organization__c = '9000';
        pmc.Serial_Number__c = 0;
        insert pmc;
        
        Basic_Price__c bp = new Basic_Price__c();
        bp.Basic_Price__c = 8999;
        bp.Material_Number__c = 'BB-1002:R1ON';
        //bp.Project_Name__c = 'Ramky One Karnival';
        bp.Sales_Office__c = '1014';
        bp.Sales_Organization__c = '9000';
        
        insert bp;
        
        Account Acc = new Account();
        Acc.Name = 'test Name';
        insert Acc;
        
        Contact con = new contact();
        con.FirstName ='testname';
        con.LastName ='tets name';
        con.AccountId = Acc.Id;
        insert con;
        	
        Opportunity opp = new Opportunity();
        opp.name = 't74';
        opp.AccountID = Acc.Id;
        opp.CloseDate =  Date.today();
        opp.StageName = 'Project Details';        
        insert opp;
        
        Discount__c dis = new Discount__c();
        dis.Amount_in_Local_Currency__c = 100;
        dis.Sales_Office__c = '1014';
        dis.Sales_Organization__c = '9000';
        insert dis;
        
        Booking_Form_Sources__c bfsource = new Booking_Form_Sources__c();
        bfsource.Name = '10';
        bfsource.Source_Type__c = 'PM:Times of India';
        insert bfsource;
        
        Loyalty_Bonus_Data__c LBD = new Loyalty_Bonus_Data__c();
        LBD.Booking_Form_Source__c = bfsource.Id;
        LBD.Loyalty_Bonus__c = 100000;
        LBD.Percentage__c = 6;
        LBD.Project_Name__c = 'Ramky One Karnival';
        LBD.Sales_Office__c = '1014';
        LBD.Source_Id__c = '63';
        insert LBD;
        
        Cost_Sheet__c costs = new Cost_Sheet__c();
        costs.Opportunity__c = opp.Id;
        costs.Project__c = 'Ramky One Karnival';
        costs.Tower__c = 'F';
        costs.Unit_No__c = '0602';
        costs.Basic_Price__c = 8999;
        costs.Cost_of_the_Unit__c = 15048250;
        costs.Clubhouse_Charges__c = 568750;
        costs.Infrastructure_charges__c = 0;
        costs.Car_Parking__c = 600000;
        insert costs;
        
        
        
        


        
        
        
        BookingFormController.getRecordDetails(prod.Project__c,prod.Towers__c,prod.Unit__c);
        //Test.startTest();
        try {
        	//BookingFormController.getRecordDetails('','','');
        } catch (Exception e) {
            // This block will be executed if the General Exception is caught
            System.assert(e instanceof NullPointerException, 'Expected General Exception not caught');
        }

        BookingFormController.getSchemeDetails(prod.Project__c);
        BookingFormController.getParentRecordsByPaymentType(pmc.Payment_Schedule_Type__c);
        BookingFormController.getOrginalBasePrice(prod.Project__c,bp.Material_Number__c);
        BookingFormController.OpportunityRecord(opp.Id);
        BookingFormController.getPaymentScheduleList(prod.Project__c);
        BookingFormController.getPaymentScheduleDetails(prod.Project__c,pmc.Payment_Schedule_Type__c);
        BookingFormController.getProductDetails(opp.Id);
        BookingFormController.CheckNdsDiscount(prod.Project__c);
        BookingFormController.getContactDetails(opp.Id);
        BookingFormController.getSchemeRecords(prod.Project__c);
        BookingFormController.getBookingsourceslist();
        BookingFormController.getloyaltyBonuslist(bfsource.Id,prod.Project__c);
        BookingFormController.getCostSheetRecord(opp.Id,costs.Project__c,costs.Tower__c,costs.Unit_No__c);
        
        
          BookingFormController.BookingFormWp bookwp = new BookingFormController.BookingFormWp(); 
        
        bookwp.BookingFormId = '';
        bookwp.Opportunity = opp.Id;
        bookwp.ProjectName = costs.Project__c;
        bookwp.Block = costs.Tower__c;
        bookwp.Unit = costs.Unit_No__c;
        bookwp.Tower = costs.Tower__c;
        bookwp.facing = 'WEST';
        bookwp.sftArea = 1010;
        bookwp.flatNo = '604';
        bookwp.unitType = '2 BHK';
        bookwp.CarpetArea = '683.29';
        bookwp.Balcony = 39.29;
        bookwp.Utility = 38.49;
        bookwp.ExternalWallArea = 59.52;
        bookwp.UDS = '36.28';
        bookwp.SBUA = 1010;
        bookwp.Saletype = 'REGULAR';
        bookwp.BasicRate = '6999';
        bookwp.LumpSumAmount = '2744170';
        bookwp.OrginalLumpSUmAmount = '7366940';
        bookwp.CarParking = 200000;
        bookwp.ExtraCarParkingNo = 1;
        bookwp.ExtraCarParking = '100000';
        bookwp.EvCharges = 0;
        bookwp.OtherCharges = 1000000;
        bookwp.GrandTotal = '1444170';        
        bookwp.selectedCustomerType = 'Indian Resident';
        bookwp.selectedSalutation = 'Mr.';
        bookwp.FirstName = 'SP';
        bookwp.LastName = 'Testing2';
        bookwp.Gender = 'Male';
        bookwp.Organization = 'Organization';
        bookwp.Designation = 'Designation';
        bookwp.PassportNo = 'Passport No';
        bookwp.Validtill = '2024-12-19';
        bookwp.selectedProfession = 'Business';
        bookwp.selectedSalutationr = 'S/o.';
        bookwp.FirstNamer = 'First Name';
        bookwp.LastNamer = 'Last name';
        bookwp.DateOfBirth = '2007-12-06';
        bookwp.age = '17';
        bookwp.Mobile = '1231231231';
        bookwp.AlternativeMobile = '1231231231';
        bookwp.TelRes = '1231231231';
        bookwp.TelOffice = '1231231231';
        bookwp.Email = 'test@gmail.com';
        bookwp.AlternativeEmail = 'test@gmail.com';
        bookwp.selectedMaritalStatus = 'Married';
        bookwp.AnniversaryDate = '2024-12-19';
        bookwp.PanNo = 'MERTRede21';
        bookwp.AadharNo = '123123123123';
        bookwp.SignthroughDigitalSignature=true;
        bookwp.presentStreet = 'Test';
        bookwp.presentStreet2 = 'Test';
        bookwp.presentStreet3 = '123123';
        bookwp.presentStreet4 = '1231';
        bookwp.presentStreet5 = '1344';
        bookwp.presentCity = 'Tesy';
        bookwp.selectedPresentState = 'Telangana';
        bookwp.selectedPresentCountry = 'India';
        bookwp.presentPinCode = '502220';
        bookwp.permanentStreet = 'Test';
        bookwp.permanentStreet2 = 'Test';
        bookwp.permanentStreet3 = '123123';
        bookwp.permanentStreet4 = '1231';
        bookwp.permanentStreet5 = '1344';
        bookwp.permanentCity = 'Tesy';
        bookwp.selectedPermanentState = 'Telangana';
        bookwp.selectedPermanentCountry = 'India';
        bookwp.permanentPinCode = '502220';
        bookwp.SameasPresentAddress = true;
        bookwp.Booking_Form_Status = 'Draft Save';
        bookwp.AccountHolderName = 'test hold';
        bookwp.AccountNo = 'account';
        bookwp.NameofBank = '';
        bookwp.IFSCCode = '';
        bookwp.BankBranch = '';
        bookwp.CampusFund = 50500;
        bookwp.AdvanceMaintenance = 85809.6;
        bookwp.GSTonInstalments = 'APPLICABLE AS PER GOVERNMENT NORMS';
        bookwp.StampDuty = 'APPLICABLE AS PER GOVERNMENT NORMS';
        bookwp.DocumentationCharges = 23600;
        bookwp.OtherChargesIf = 'APPLICABLE AS PER GOVERNMENT NORMS';
        bookwp.selectedServiceCategory = 'IT';
        bookwp.selectedProfessionDetails = 'Manufacturing';
        bookwp.selectedAnnualIncome = '5-15 lakhs';
        bookwp.selectedPaymentSource = 'Home Loan';
        bookwp.selectedPurchase = 'Investment';
        bookwp.selectedOtherProject = 'Yes – Commercial';
        bookwp.selectedLocation = '';
        bookwp.selectedLocationString = 'Andhra Pradesh;Telangana';
        bookwp.selectedRemarks = 'RM1';
        bookwp.RemarksDescription = 'description';
        bookwp.SalesPersonEmployeeID = 'EMP0001';
        bookwp.Declaration = true;
        bookwp.NDSORSDS = true;
        bookwp.ndsValue = '200';
		bookwp.sdsValue = '2812';
        bookwp.discount = '6999';
        bookwp.useScheme = false;
        bookwp.selectedScheme = '';
        bookwp.ndsDiscountAmount = '202000';
        bookwp.ExtraDiscountAmount = '7068990';
        bookwp.sdsDiscountAmount = '2840120';
        bookwp.DiscountAmount = '10011';
        bookwp.meterial = 'T4-0604:R1NT';
        bookwp.OrginalBasePrice = '';
        bookwp.extraBasePrice = '6999';
        bookwp.encash = false;
		bookwp.SchemeAmount = '';
        bookwp.SourceValue = 'PM:Deccan Chronicle';
        bookwp.SourceExistCustomerDiscount = '0';
        bookwp.SourceChannelPartnerCode = '';
        bookwp.SourceChannelPartnerName = '';
        bookwp.SourceReferenceEmployeeCode = '';
        bookwp.SourceEmployeeName = '';
        bookwp.SourceEmployeeCompanyName = '';
        bookwp.SourceCustomerCode = '';
        bookwp.SourceCustomerRelationName = '';
		bookwp.SourceCustomerName = '';
        bookwp.SourceFlatNo = '';
		bookwp.SourceProjectName = '';
        bookwp.PaymentScheduleTotalAmount = '953152.2';
        bookwp.PaymentSchedulepercentage = '66';
        bookwp.selectedPaymentType = 'Flexible';
        bookwp.SDSApprovelStatus = '';
        bookwp.SDSApprovelComments = '';
        bookwp.SourceExiCustomerCode = '';
        bookwp.SourceExiCustomerName = '';
        bookwp.SourceExiCustomerRelationName = '';
        bookwp.SourceExiFlatNo = '';
        bookwp.SourceExiProjectName = '';
        
        
        
        List<BookingFormController.OtherApplicentWp> otherappList = new List<BookingFormController.OtherApplicentWp>();
        
        BookingFormController.OtherApplicentWp otherApp1 = new BookingFormController.OtherApplicentWp();
        otherApp1.Id = '';
        otherApp1.index = '1';
        otherApp1.Salutation1 = 'Mr.';
        otherApp1.FirstName1 = 'Trying';
        otherApp1.LastName1 = 'Testing';
        otherApp1.Gender1 = 'Male';
        otherApp1.Organization1 = 'Male Organization';
        otherApp1.Occupation1 = 'Mechanical Engineer';
        otherApp1.salutationr1Options = 'S/o.';
        otherApp1.FirstNamer1 = 'First name';
        otherApp1.LastNamer1 = 'Last name';
        otherApp1.DateofBirth1 = '2007-12-19';
        otherApp1.age1 = '17';
        otherApp1.MaritalStatus1 = 'Single';
        otherApp1.AnniversaryDate1 = '2024-12-19';
        otherApp1.Mobile1 = '1231231231';
        otherApp1.Email1 = 'test@gmail.com';
        otherApp1.PassportNo1 = '123123121';
        otherApp1.Validtill1 = '2024-12-19';
        otherApp1.PanNo1 = '1231231231';
        otherApp1.AadharNo1 = '123123123123';
        otherApp1.applicantcount = '';
		
        otherappList.add(otherApp1);
        
		BookingFormController.OtherApplicentWp otherApp2 = new BookingFormController.OtherApplicentWp();
        otherApp2.Id = '';
        otherApp2.index =  '2';
        otherApp2.Salutation1 = 'Ms.';
        otherApp2.FirstName1 = 'test';
        otherApp2.LastName1 = 'test';
        otherApp2.Gender1 = 'Female';
        otherApp2.Organization1 = 'org';
        otherApp2.Occupation1 = 'Master Craftsman';
        otherApp2.salutationr1Options = 'D/o.';
        otherApp2.FirstNamer1 = 'test test';
        otherApp2.LastNamer1 = 'test test';
        otherApp2.DateofBirth1 = '2012-11-29';
        otherApp2.age1 = '12';
        otherApp2.MaritalStatus1 = 'Married';
        otherApp2.AnniversaryDate1 = '2024-12-18';
        otherApp2.Mobile1 = '3213213211';
        otherApp2.Email1 = 'test@gmail.com';
        otherApp2.PassportNo1 = '76788sehj';
        otherApp2.Validtill1 = '';
        otherApp2.PanNo1 = '1231231231';
        otherApp2.AadharNo1 = '123123123322';
        otherApp2.applicantcount = '';
        
        otherappList.add(otherApp2);

	
        List<BookingFormController.PaymentScheduleWp> paymentscheduleList = new List<BookingFormController.PaymentScheduleWp>();
        
        BookingFormController.PaymentScheduleWp paysch1 = new BookingFormController.PaymentScheduleWp();
        
        paysch1.Amount_In_Local_Currency ='332159.10000000003';
        paysch1.Payment_Particulars ='trws';
        paysch1.Amount ='23';
        paysch1.Payment_Schedule_Type = 'REGULAR';
        paymentscheduleList.add(paysch1);
        
        BookingFormController.PaymentScheduleWp paysch2 = new BookingFormController.PaymentScheduleWp();
        
        paysch2.Amount_In_Local_Currency ='332159.10000000003';
        paysch2.Payment_Particulars ='trws';
        paysch2.Amount ='23';
        paysch2.Payment_Schedule_Type = 'REGULAR';
        paymentscheduleList.add(paysch2);
        
        
         List<BookingFormController.FileWrapper> fileWrapperList = new List<BookingFormController.FileWrapper>();
        // Step 1: Create an instance of FileWrapper
        BookingFormController.FileWrapper fileWrapper = new BookingFormController.FileWrapper();

        // Step 2: Set values for the fileName and fileContent properties
        fileWrapper.fileName = 'testFile.pdf';
        fileWrapper.fileContent = EncodingUtil.base64Encode(Blob.valueOf('This is the content of the test file.'));
        fileWrapperList.add(fileWrapper);
        
        Booking_Form__c bf = BookingFormController.BookFormInsert(JSON.serialize(bookwp),JSON.serialize(fileWrapperList),JSON.serialize(otherappList),JSON.serialize(paymentscheduleList));
        
        
        List<id> pmcid = new List<id>();
        pmcid.add(pmc.Id);
        
        BookingFormController.associatePaymentSchedulesToBookingForm(pmcid,bf.Id);
        BookingFormController.getPaymentScheduleRecord(bf.Id);
        BookingFormController.getProductDetails(bf.Id);
        // getProductDetails
        BookingFormController.IsBookingFormExists(opp.Id,costs.Project__c,costs.Tower__c,costs.Unit_No__c);
        BookingFormController.getBookingFormRecord(opp.Id,costs.Project__c,costs.Tower__c,costs.Unit_No__c);
        
        BookingFormController.getOtherApplicantRecord(bf.Id);
        
        BookingFormController.uploadFiles(JSON.serialize(fileWrapperList),bf.Id);
    }
    
   /* 
   // Mock for the HttpRequest used in getAccessToken
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            // Check the endpoint URL to return different mock responses
            if (req.getEndpoint().contains('oauth/token')) {
                res.setStatusCode(200);
                // Mocked response for token request
                res.setBody('{"access_token": "mockAccessToken"}');
            } else if (req.getEndpoint().contains('IFSC_CodeValidation')) {
                res.setStatusCode(200);
                // Mocked response for the main API call
                res.setBody('{"status": "success"}');
            }
            return res;
        }
    }

    @isTest
    static void testIFSCCodeSAPApi() {
        // Set up the mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Test the getAccessToken method
        Test.startTest();
        String accessToken = BookingFormController.getAccessToken();
        Test.stopTest();
        
        // Assert the access token is returned correctly
        System.assertEquals('mockAccessToken', accessToken);
        
        // Test the IFSCCodeSAPApi method with mock data
        Test.startTest();
        Boolean responseStatus = BookingFormController.IFSCCodeSAPAPi('SBIN0000001', 'State Bank of India', 'Mumbai');
        Test.stopTest();
        
        // Assert that the response status is true based on the mocked response
        System.assert(responseStatus, 'The API call should return true for a successful response');
    }
	*/
    
    /*
    
   // Define the WrapperClass1 to use within the test class
    public class WrapperClass1 {
        public String ProjectName;
        public String Block;
        public String selectedUnit;
        public Id Opportunity;
        public String FlatNo;
        public Decimal LumpSumAmount;
        public String selectedSaletype;
        public Decimal OtherCharges;
        public String CustomerType;
        public String Salutation;
        public String FirstName;
        public String LastName;
        public String Gender;
        public String Organization;
        public String Designation;
        public String PassportNo;
        public Date Validtill;
        public String Profession;
        public String Mobile;
        public String AlternativeMobile;
        public String Email;
        public String MaritalStatus;
        public String presentStreet;
        public String presentCity;
        public String presentPinCode;
        public String selectedPresentCountry;
        public String selectedPresentState;
        public String Utility {get;set;}
         
        public Boolean useScheme {get;set;}
         
        public String UnitType {get;set;}
         
        public Integer Unit {get;set;}
         
        public String UDS {get;set;}
         
        public String Tower {get;set;}
         
        public String SalesOrganization {get;set;}
        
        public String SalesOffice {get;set;}
         
        public String SourceID {get;set;}
         
        public String StampDuty {get;set;}
         
        public Integer SFTArea {get;set;}
         
        public String  selectedServiceCategory{get;set;}
         
        public String selectedScheme {get;set;}
         
        public String RemarksDescription {get;set;}
         
        public String selectedRemarks {get;set;}
        public Integer AadharNo {get;set;}
         
        public String fname {get;set;}
         
        public String lname {get;set;}
       
    
    }
    
    @TestSetup
    static void setupTestData() {
    // Create test Product2 record
   Product2 product = new Product2(
            Name = 'Test Product',
            Project__c = 'TestProject',
            Towers__c = 'TestBlock',
            Unit__c = 'TestUnit',
            Area_in_Sqft__c = 1000,
            Phone__c = '9634566677',
            Sale_Unit_Carpet_Area_in_SFT__c = 'TestcarpetArea',
            Balcony__c = 50,
            Utility__c = 25,
            External_wall_area__c = 75,
            UDS__c = 'TestUds',
            Base_Value__c = 5000000,
            Car_Parking_Charges__c = 200000,
            EV_Charges__c = 50000,
            Sales_Office__c = '1010',
            Type__c = 'Residential'
        );
        insert product;

    Account account = new Account(
        Name = 'Test Account',
        Phone = '9422353539'
    );
    insert account;

    // Create test Opportunity linked to the Account
    Opportunity opp = new Opportunity(
        Name = 'Test Opportunity',
        StageName = 'Prospecting',
        CloseDate = Date.today(),
        AccountId = account.Id
    );
    insert opp;
        
    // Create test Booking_Form__c record
        Booking_Form__c bookingForm = new Booking_Form__c(
            Project_Name__c = 'TestProject',
            Towers__c = 'TestTower',
            Unit__c = 'TestUnit',
            Opportunity__c = opp.Id
        );
        insert bookingForm;

    // Create a test Contact linked to the Account
    Contact contact = new Contact(
        FirstName = 'Test',
        LastName = 'Contact',
        AccountId = account.Id,
        Email = 'test@example.com',
        Phone = '1234567890'
    );
    insert contact;

    // Create test Scheme__c with Sales_Office__c set to a known value to match Project_Name__c via formula
    Scheme__c scheme = new Scheme__c(
        Name = 'Test Scheme',
        Sales_Office__c = '1010', // This should correspond to 'Ramky One Harmony' as per the formula
        Description__c = 'Test scheme description'
    );
    insert scheme;

     // Create test Payment_Schedule__c, using Sales_Office__c for the formula field Project_Name__c
    Payment_Schedule__c paymentSchedule = new Payment_Schedule__c(
        Payment_Schedule_Type__c = 'TestType',
        Sales_Office__c = '1010', // This should correspond to 'Ramky One Harmony'
        Amount_In_Local_Currency__c = 500
    );
    insert paymentSchedule;

    // Create test Cost_Sheet__c record with Sales_Office__c for Project_Name__c calculation
    Cost_Sheet__c costSheet = new Cost_Sheet__c(
        Opportunity__c = opp.Id,
       // Sales_Office__c = '1010', // Corresponding to 'Ramky One Harmony'
        Tower__c = 'TestBlock',
        Unit_No__c = 'TestUnit',
        Basic_Price__c = 1000
    );
    insert costSheet;

    // Create test records for Booking_Form_Sources__c
    Booking_Form_Sources__c source1 = new Booking_Form_Sources__c(
        Name = 'Source 1',
        Source_Type__c = 'Online'
    );
    
    Booking_Form_Sources__c source2 = new Booking_Form_Sources__c(
        Name = 'Source 2',
        Source_Type__c = 'Referral'
    );
    
    insert new List<Booking_Form_Sources__c>{source1, source2};

    // Create test Basic_Price__c with Sales_Office__c to reflect Project_Name__c
    Basic_Price__c basicPrice = new Basic_Price__c(
        Sales_Office__c = '1010', // Corresponding to 'Ramky One Harmony'
        Material_Number__c = 'TestMaterial',
        Basic_Price__c = 1200
    );
    insert basicPrice;
}
    
    @IsTest
    static void testGetRecordDetails() {
        // Retrieve the test Product2 record
        Product2 testProduct = [SELECT Project__c, Towers__c, Unit__c FROM Product2 LIMIT 1];
        
        // Call the method with the parameters of the test record
        Test.startTest();
        Product2 result = BookingFormController.getRecordDetails(testProduct.Project__c, testProduct.Towers__c, testProduct.Unit__c);
        Test.stopTest();

        // Assert that the result is not null
        System.assertNotEquals(null, result, 'The Product2 record should be fetched successfully.');

        // Assert that some of the retrieved fields match the expected values
        System.assertEquals('TestProject', result.Project__c, 'Project should match the test data.');
        System.assertEquals('TestBlock', result.Towers__c, 'Block should match the test data.');
        System.assertEquals('TestUnit', result.Unit__c, 'Unit should match the test data.');
        System.assertEquals(1000, result.Area_in_Sqft__c, 'Area in Sqft should match the test data.');
    }

    @IsTest
    static void testGetRecordDetailsWithInvalidParams() {
        // Call the method with parameters that do not match any Product2 record
        Test.startTest();
        try {
            Product2 result = BookingFormController.getRecordDetails('InvalidProject', 'InvalidBlock', 'InvalidUnit');
            System.assert(false, 'Expected an AuraHandledException to be thrown due to invalid parameters.');
        } catch (AuraHandledException e) {
            // Verify that the exception message is as expected
            System.assert(e.getMessage().contains('Error fetching record details'), 'Exception message should indicate an error fetching record details.');
        }
        Test.stopTest();
    }

   @IsTest
static void testGetSchemeDetails() {
    Test.startTest();
    Scheme__c result = BookingFormController.getSchemeDetails('TestProject');
    Test.stopTest();
    
    System.assertNotEquals(null, result, 'Scheme details should be fetched successfully.');
    System.assertEquals('Test scheme description', result.Description__c, 'Description should match the test data.');
}

    @IsTest
    static void testGetParentRecordsByPaymentType() {
        Test.startTest();
        List<Payment_Schedule__c> results = BookingFormController.getParentRecordsByPaymentType('TestType');
        Test.stopTest();
        
        System.assert(results.size() > 0, 'Payment records should be retrieved.');
    }

    @IsTest
static void testGetOrginalBasePrice() {
    Test.startTest();
    List<Basic_Price__c> results = BookingFormController.getOrginalBasePrice('TestProject', 'TestMaterial');
    Test.stopTest();

    System.assert(results.size() > 0, 'Original base price should be retrieved.');
    System.assertEquals(1200, results[0].Basic_Price__c, 'Basic price should match the test data.');
}
    
   @IsTest
static void testAssociatePaymentSchedulesToBookingForm() {
    // Ensure Booking_Form__c record
    Booking_Form__c bookingForm;
    List<Booking_Form__c> bookingForms = [SELECT Id FROM Booking_Form__c LIMIT 1];
    if (bookingForms.isEmpty()) {
        bookingForm = new Booking_Form__c(
            Project_Name__c = 'TestProject',
            Towers__c = 'TestBlock',
            Unit__c = 'TestUnit'
        );
        insert bookingForm;
    } else {
        bookingForm = bookingForms[0];
    }
    
    // Ensure Payment_Schedule__c record
    Payment_Schedule__c paymentSchedule;
    List<Payment_Schedule__c> paymentSchedules = [SELECT Id FROM Payment_Schedule__c LIMIT 1];
    if (paymentSchedules.isEmpty()) {
        paymentSchedule = new Payment_Schedule__c(
            Payment_Schedule_Type__c = 'TestType',
            Project__c = 'TestProject',
            Amount_In_Local_Currency__c = 500
        );
        insert paymentSchedule;
    } else {
        paymentSchedule = paymentSchedules[0];
    }
    
    // Test method logic
    Test.startTest();
    BookingFormController.associatePaymentSchedulesToBookingForm(new List<Id>{ paymentSchedule.Id }, bookingForm.Id);
    Test.stopTest();
    
    // Verify that the payment schedule is associated
    bookingForm = [SELECT Payment_Schedules__c FROM Booking_Form__c WHERE Id = :bookingForm.Id];
    String paymentSchedules1 = bookingForm.Payment_Schedules__c;
    System.assert(paymentSchedules1.contains(paymentSchedule.Id), 'Payment Schedule should be associated with Booking Form.');
}

  @IsTest
static void testCreateBookingForm() {
    // Prepare the WrapperClass1 JSON data
    WrapperClass1 wrapperData = new WrapperClass1();
    wrapperData.ProjectName = 'TestProject';
    wrapperData.Block = 'TestBlock';
    wrapperData.selectedUnit = 'TestUnit';
    wrapperData.Opportunity = null; // Replace with an Opportunity Id if necessary
    wrapperData.FlatNo = '101';
    wrapperData.LumpSumAmount = 5000000;
    wrapperData.selectedSaletype = 'Full Payment';
    wrapperData.OtherCharges = 100000;
    wrapperData.CustomerType = 'Individual';
    wrapperData.Salutation = 'Mr';
    wrapperData.FirstName = 'John';
    wrapperData.LastName = 'Doe';
    wrapperData.Gender = 'Male';
    wrapperData.Organization = 'Tech Corp';
    wrapperData.Designation = 'Developer';
    wrapperData.PassportNo = 'P123456';
    wrapperData.Validtill = Date.today().addYears(5);
    wrapperData.Profession = 'Software Engineer';
    wrapperData.Mobile = '1234567890';
    wrapperData.AlternativeMobile = '0987654321';
    wrapperData.Email = 'john.doe@example.com';
    wrapperData.MaritalStatus = 'Single';
    wrapperData.presentStreet = '123 Main St';
    wrapperData.presentCity = 'San Francisco';
    wrapperData.presentPinCode = '94105';
    wrapperData.selectedPresentCountry = 'USA';
    wrapperData.selectedPresentState = 'CA';

    String wrapperJson = JSON.serialize(wrapperData);

    // Call the createBookingForm method
    Test.startTest();
    Booking_Form__c bookingForm = BookingFormController.createBookingForm(wrapperJson);
    Test.stopTest();

    // Assert that the booking form was created
    System.assertNotEquals(null, bookingForm, 'Booking form should be created');

    // Verify some fields were populated correctly
    System.assertEquals('TestProject', bookingForm.Project_Name__c, 'Project name should be set correctly');
    System.assertEquals('TestBlock', bookingForm.Block__c, 'Block should be set correctly');
    System.assertEquals(1000, bookingForm.Area_in_Sqft__c, 'Area in Sqft should match');
    System.assertEquals('Full Payment', bookingForm.Sale_Type__c, 'Sale Type should match');
    System.assertEquals('John', bookingForm.First_Name__c, 'First Name should match');
    System.assertEquals('USA', bookingForm.Country__c, 'Present Country should match');
}  
    // Optional additional test case for null or empty JSON input
   @IsTest
static void testCreateBookingFormWithEmptyJson() {
    Test.startTest();
    try {
        BookingFormController.createBookingForm('');
        System.assert(false, 'Expected exception to be thrown for empty JSON input');
    } catch (Exception e) { // Use Exception if CustomException is not defined
        System.assert(e.getMessage().contains('Null or empty JSON data received for wrapperBookingFormData'), 'Exception message should match');
    }
    Test.stopTest();
}

    @IsTest
    static void testOpportunityRecord() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        List<Opportunity> result = BookingFormController.OpportunityRecord(opp.Id);
        Test.stopTest();
        
        System.assertEquals(1, result.size(), 'Opportunity record should be retrieved.');
    }

    @IsTest
    static void testGetPaymentScheduleList() {
        Test.startTest();
        List<Map<String, String>> results = BookingFormController.getPaymentScheduleList('TestProject');
        Test.stopTest();
        
        System.assertNotEquals(0, results.size(), 'Payment schedule list should be retrieved.');
    }
    
     @IsTest
    static void testGetPaymentScheduleRecord() {
        // Step 1: Create test data for Booking_Form__c
        Booking_Form__c bookingForm = new Booking_Form__c(First_Name__c = 'Test Booking Form');
        insert bookingForm;

        // Step 2: Create test data for Booking_Form_Line_Items__c
        Booking_Form_Line_Items__c lineItem = new Booking_Form_Line_Items__c(
            Booking_Form__c = bookingForm.Id,
            Amount__c = 1000,
            Agreement_Value__c = 10000,
            Payment_Particulars__c = 'Initial Payment',
            Payment_Schedule_Type__c = 'Type A'
        );
        insert lineItem;

        // Step 3: Call the method and assert results
        Test.startTest();
        List<Booking_Form_Line_Items__c> result = BookingFormController.getPaymentScheduleRecord(bookingForm.Id);
        Test.stopTest();

        // Assert that results are not null and contain expected data
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(lineItem.Id, result[0].Id);
    }

 @IsTest
    static void testGetPaymentScheduleDetails() {
        // Step 1: Create a parent object to associate with Project__c field
        Account account = new Account(Name = 'Test Account');
        insert account;

        // Step 2: Create test data for Payment_Schedule__c with Project__c as a field
        Payment_Schedule__c paymentSchedule = new Payment_Schedule__c(
            Project__c = account.Id, // Assuming Project__c is a lookup to Account
            Payment_Schedule_Type__c = 'Type A',
            Payment_Particulars__c = 'Milestone 1',
            Amount__c = 5000,
            Amount_In_Local_Currency__c = 5000,
            Serial_Number__c = 1
        );
        insert paymentSchedule;

        // Step 3: Call the method and assert results
        Test.startTest();
        List<Payment_Schedule__c> result = BookingFormController.getPaymentScheduleDetails(account.Id, 'Type A');
        Test.stopTest();

        // Assert that results are not null and contain expected data
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Result size should be 1');
        System.assertEquals(paymentSchedule.Id, result[0].Id, 'Returned record ID should match the test data');
    }
    
    @IsTest
    static void testGetProductDetails() {
        // Retrieve Opportunity created in setup
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Execute the method
        Test.startTest();
        List<BookingFormController.WrapperData> results = BookingFormController.getProductDetails(opp.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, results.size(), 'Should return one product detail.');
        System.assertEquals('TestProject', results[0].ProjectName, 'Project name should match the test data.');
        System.assertEquals('TestTower', results[0].Block, 'Block should match the test data.');
        System.assertEquals('TestUnit', results[0].Unit, 'Unit should match the test data.');
    } 
    
     @IsTest
    static void testGetProductDetailsWithOpportunity() {
        // Retrieve test Opportunity
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        List<BookingFormController.WrapperData> result = BookingFormController.getProductDetails(opp.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assertEquals(1, result.size(), 'Only one product detail should be returned.');
        System.assertEquals('Test Project', result[0].ProjectName, 'ProjectName should match.');
        System.assertEquals('Test Block', result[0].Block, 'Block should match.');
        System.assertEquals('Test Unit', result[0].Unit, 'Unit should match.');
        System.assertEquals(opp.Id, result[0].OpportunityId, 'OpportunityId should match.');
    }

    @IsTest
    static void testGetProductDetailsWithBookingForm() {
        // Retrieve test Booking_Form__c
        Booking_Form__c bookingForm = [SELECT Id FROM Booking_Form__c LIMIT 1];

        Test.startTest();
        List<BookingFormController.WrapperData> result = BookingFormController.getProductDetails(bookingForm.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assertEquals(1, result.size(), 'Only one booking form detail should be returned.');
        System.assertEquals('Test Project', result[0].ProjectName, 'ProjectName should match.');
        System.assertEquals('Test Block', result[0].Block, 'Block should match.');
        System.assertEquals('Test Unit', result[0].Unit, 'Unit should match.');
        System.assertEquals(bookingForm.Opportunity__c, result[0].OpportunityId, 'OpportunityId should match.');
    }

    @IsTest
    static void testGetProductDetailsWithNullRecordId() {
        Test.startTest();
        List<BookingFormController.WrapperData> result = BookingFormController.getProductDetails(null);
        Test.stopTest();

        // Assertions
        System.assertEquals(0, result.size(), 'Result should be empty for null record ID.');
    }

    @IsTest
    static void testBookFormInsert() {
        // Prepare Wrapper JSON data
        String wrapperJson = '{"ProjectName":"TestProject","Block":"TestTower","Unit":"TestUnit","Opportunity":"'
            + [SELECT Id FROM Opportunity LIMIT 1].Id + '"}';
        String files = '[]'; // No files to test basic functionality
        String otherApplicants = '[]'; // No other applicants for simplicity
        String paymentSchedule = '[{"Payment_Particulars":"Booking Advance","Payment_Schedule_Type":"Installment","Amount":"1000","Amount_In_Local_Currency":"1000","SerialNumber":"1"}]';

        // Execute the method
        Test.startTest();
        Booking_Form__c bookingForm = BookingFormController.BookFormInsert(wrapperJson, files, otherApplicants, paymentSchedule);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, bookingForm, 'Booking form should be created.');
        System.assertEquals('TestProject', bookingForm.Project_Name__c, 'Project name should match the test data.');
        System.assertEquals('TestTower', bookingForm.Block__c, 'Block should match the test data.');
        System.assertEquals('TestUnit', bookingForm.Unit__c, 'Unit should match the test data.');

        // Verify associated line items
        List<Booking_Form_Line_Items__c> lineItems = [SELECT Id, Payment_Particulars__c, Amount__c FROM Booking_Form_Line_Items__c WHERE Booking_Form__c = :bookingForm.Id];
        System.assertEquals(1, lineItems.size(), 'One payment schedule line item should be created.');
        System.assertEquals('Booking Advance', lineItems[0].Payment_Particulars__c, 'Payment particulars should match.');
        System.assertEquals(1000, lineItems[0].Amount__c, 'Amount should match.');
    }
    
   @IsTest
static void testUploadFiles() {
    // Ensure a Booking_Form__c record exists
    Booking_Form__c bookingForm;
    List<Booking_Form__c> bookingForms = [SELECT Id FROM Booking_Form__c LIMIT 1];
    if (bookingForms.isEmpty()) {
        bookingForm = new Booking_Form__c(
            Project_Name__c = 'TestProject',
            Towers__c = 'TestBlock',
            Unit__c = 'TestUnit'
        );
        insert bookingForm;
    } else {
        bookingForm = bookingForms[0];
    }

    // Sample file data to test file upload
    String fileData = '[{"fileName":"testfile.pdf","fileContent":"dGVzdCBjb250ZW50"}]';
    
    Test.startTest();
    BookingFormController.uploadFiles(fileData, bookingForm.Id);
    Test.stopTest();
    
    // Verify that the file was uploaded
    ContentDocumentLink docLink = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :bookingForm.Id LIMIT 1];
    System.assertNotEquals(null, docLink, 'File should be uploaded and linked to the record.');
}
   
   @IsTest
static void testIsBookingFormExists() {
    // Retrieve or create a Booking_Form__c record for the test
    Booking_Form__c bookingForm;
    List<Booking_Form__c> bookingForms = [SELECT Project_Name__c, Towers__c, Unit__c FROM Booking_Form__c LIMIT 1];
    if (bookingForms.isEmpty()) {
        bookingForm = new Booking_Form__c(
            Project_Name__c = 'TestProject',
            Towers__c = 'TestBlock',
            Unit__c = 'TestUnit'
        );
        insert bookingForm;
    } else {
        bookingForm = bookingForms[0];
    }
    
    // Test method logic
    Test.startTest();
    Boolean exists = BookingFormController.IsBookingFormExists(null, bookingForm.Project_Name__c, bookingForm.Towers__c, bookingForm.Unit__c);
    Test.stopTest();
    
    System.assert(exists, 'Booking form should exist.');
}

   @IsTest
static void testGetBookingFormRecord() {
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    if (opp == null) {
        opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp;
    }
    
    // Ensure Booking_Form__c is available
    Booking_Form__c bookingForm = [SELECT Project_Name__c, Towers__c, Unit__c, Opportunity__c FROM Booking_Form__c LIMIT 1];
    if (bookingForm == null) {
        bookingForm = new Booking_Form__c(
            Project_Name__c = 'TestProject',
            Towers__c = 'TestBlock',
            Unit__c = 'TestUnit',
            Opportunity__c = opp.Id
        );
        insert bookingForm;
    }

    // Perform test logic
    Test.startTest();
    Booking_Form__c result = BookingFormController.getBookingFormRecord(bookingForm.Opportunity__c, bookingForm.Project_Name__c, bookingForm.Towers__c, bookingForm.Unit__c);
    Test.stopTest();
    
    System.assertNotEquals(null, result, 'Booking form record should be retrieved.');
}

   @IsTest
static void testGetContactDetails() {
    // Retrieve the Opportunity created in the @TestSetup
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    
    Test.startTest();
    List<Contact> contacts = BookingFormController.getContactDetails(opp.Id);
    Test.stopTest();
    
    // Assert that at least one contact was retrieved
    System.assert(contacts.size() > 0, 'Contact details should be retrieved.');
    System.assertEquals('Test', contacts[0].FirstName, 'Contact FirstName should match the test data.');
    System.assertEquals('Contact', contacts[0].LastName, 'Contact LastName should match the test data.');
}

   @IsTest
static void testGetCostSheetRecord() {
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

    Test.startTest();
    List<Cost_Sheet__c> costSheetRecords = BookingFormController.getCostSheetRecord(opp.Id, 'TestProject', 'TestBlock', 'TestUnit');
    Test.stopTest();

    System.assert(costSheetRecords.size() > 0, 'Cost sheet record should be retrieved.');
    System.assertEquals(1000, costSheetRecords[0].Basic_Price__c, 'Basic price should match the test data.');
}   
    
   @IsTest
static void testGetBookingsourceslist() {
    Test.startTest();
    List<Booking_Form_Sources__c> sources = BookingFormController.getBookingsourceslist();
    Test.stopTest();
    
    // Assert that at least one source was retrieved
    System.assert(sources.size() > 0, 'Booking sources should be retrieved.');
    System.assertEquals('Source 1', sources[0].Name, 'The first booking source name should match the test data.');
}
    
  @IsTest
static void testGetloyaltyBonuslist() {
    // Set up a Booking_Form_Sources__c record with necessary fields
    Booking_Form_Sources__c source = new Booking_Form_Sources__c(
        Name = 'Test Source',
        Source_Type__c = 'TestSource'
    );
    insert source;
    
    // Create Loyalty_Bonus_Data__c with the required Source_Id__c field
    Loyalty_Bonus_Data__c loyaltyBonus = new Loyalty_Bonus_Data__c(
        Booking_Form_Source__c = source.Id,
        Project_Name__c = 'TestProject',
        Sales_Office__c = 'TestOffice',
        Source_Id__c = source.Id, // Make sure this field is used in getloyaltyBonuslist
        Loyalty_Bonus__c = 100
    );
    insert loyaltyBonus;
    
    // Perform the test by invoking the method
    Test.startTest();
    List<Loyalty_Bonus_Data__c> results = BookingFormController.getloyaltyBonuslist(source.Id, 'TestProject');
    Test.stopTest();
    // Validate the results
    System.assert(results.size() > 0, 'Loyalty bonus list should be retrieved.');
    System.assertEquals(100, results[0].Loyalty_Bonus__c, 'Loyalty bonus should match the test data.');
}
  
    // Mock for the HttpRequest used in getAccessToken
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            // Check the endpoint URL to return different mock responses
            if (req.getEndpoint().contains('oauth/token')) {
                res.setStatusCode(200);
                // Mocked response for token request
                res.setBody('{"access_token": "mockAccessToken"}');
            } else if (req.getEndpoint().contains('IFSC_CodeValidation')) {
                res.setStatusCode(200);
                // Mocked response for the main API call
                res.setBody('{"status": "success"}');
            }
            return res;
        }
    }

    @isTest
    static void testIFSCCodeSAPApi() {
        // Set up the mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Test the getAccessToken method
        Test.startTest();
        String accessToken = BookingFormController.getAccessToken();
        Test.stopTest();
        
        // Assert the access token is returned correctly
        System.assertEquals('mockAccessToken', accessToken);
        
        // Test the IFSCCodeSAPApi method with mock data
        Test.startTest();
        Boolean responseStatus = BookingFormController.IFSCCodeSAPAPi('SBIN0000001', 'State Bank of India', 'Mumbai');
        Test.stopTest();
        
        // Assert that the response status is true based on the mocked response
        System.assert(responseStatus, 'The API call should return true for a successful response');
    }

*/
}