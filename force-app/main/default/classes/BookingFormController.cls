public class BookingFormController {
        
    
    Public Class CustomException extends Exception{}
        
    @AuraEnabled
    public static Product2 getRecordDetails(String selectedProject, String selectedBlock, String selectedUnit) {
        try {
            
            return [SELECT Id, Advance_Maintenance__c, Alt_Unit_Measurement__c, Amenities_Charges__c, Area_in_Sqft__c, 
                    Balcony__c, Base_Value__c, Boundary_East__c, Boundary_North__c, Boundary_South__c, Boundary_West__c, 
                    Car_Parking_Charges__c, Description__c, Description_PLC1__c, Description_PLC2__c, Description_PLC3__c, 
                    Description_PLC4__c, Description_PLC5__c, Direction_Facing__c, Dist_Channel__c, 
                    Electrical_Water_Charges__c, EV_Charges__c, External_wall_area__c,
                    Face__c, Facing__c, Family, Floor__c, Flat_No__c, Floor_Number__c, Floor_Rise__c,Infra_Charges__c,
                    Legal_Charges__c, Location__c, Material__c, Material_Description__c, Material_No__c, Name, 
                    Opportunity__c, Other_Charges__c, Parking_Area__c, Parking_No__c, Phone__c, Plant_Description__c, 
                    PLC1__c, PLC2__c, PLC3__c, PLC4__c, PLC5__c, Pricing_Condition__c, Pricing_Sequence__c, ProductCode, 
                    Project__c,Sale_Unit_Carpet_Area_in_SFT__c, Sale_Unit_Terrace_Area_in_SFT__c, Sales_Office__c, 
                    Sales_Org__c, Sales_Organization__c, Square_Yards__c, Square_Yards_Price__c, Status__c,
                    Sublocation__c, Total_Cost__c, Towers__c, Type__c, UDS__c, Undivided_share_of_Flat__c, Unit__c, 
                    Unit_Original_Status__c, Utility__c, Valid_from__c,Corpus_Fund__c FROM Product2 WHERE 
                    Project__c = :selectedProject AND Towers__c = :selectedBlock AND Unit__c = :selectedUnit LIMIT 1];
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching record details: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static Scheme__c getSchemeDetails(String selectedProject) {
        try {
            
            return [SELECT Id, Description__c, External_Id__c, General_Flag__c, Name, 
                    Net_Value_in_Doccument_Currency__c, OwnerId, Per_SFT_Amount__c, Sales_Office__c, 
                    Valid_from__c, Valid_to__c, Project_Name__c FROM Scheme__c where Project_Name__c = :selectedProject];
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching record details: ' + e.getMessage());
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Payment_Schedule__c> getParentRecordsByPaymentType(String paymentType) {
        try {
            // Direct query based on Payment_Type__c field
            return [
                SELECT Id, Name, Amount_In_Local_Currency__c, Opportunity__c, Payment_Particulars__c, Payment_Schedule_Type__c, 
                Project__c, Sales_Office__c, Sales_Organization__c, Serial_Number__c, Unique_Id__c
                FROM Payment_Schedule__c 
                WHERE Payment_Schedule_Type__c = :paymentType
            ];
        } catch (Exception ex) {
            throw new AuraHandledException('Error fetching parent records: ' + ex.getMessage());
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Basic_Price__c > getOrginalBasePrice(String ProjectName , String MaterialNumber) {
        
        List<Basic_Price__c> OrginalPrice = new List<Basic_Price__c>();
        try {
            // Direct query based on Payment_Type__c field
            OrginalPrice = [select id,Material_Number__c, Basic_Price__c,Client__c, Name, Project_Name__c, Sales_Office__c, Sales_Organization__c from Basic_Price__c where Material_Number__c =:MaterialNumber and Project_Name__c =:ProjectName order by CreatedDate desc limit 1];
            
        } catch (Exception ex) {
            throw new AuraHandledException('Error fetching parent records: ' + ex.getMessage());
        }
         return OrginalPrice;
    }
    
    
    @AuraEnabled
    public static void associatePaymentSchedulesToBookingForm(List<Id> paymentScheduleIds, Id bookingFormId) {
        List<Booking_Form__c> bookingForms = [
            SELECT Id, Payment_Schedules__c 
            FROM Booking_Form__c 
            WHERE Id = :bookingFormId
        ];
        
        if (!bookingForms.isEmpty()) {
            Booking_Form__c bookingForm = bookingForms[0];
            bookingForm.Payment_Schedules__c = String.join(paymentScheduleIds, ';');
            update bookingForm;
        }
    }  
    
    public class FileDataWrapper {
        public String fileName;
        public String fileContent;
    }
    
    @AuraEnabled(cacheable=true)
    public static list<Opportunity> OpportunityRecord(Id recordId) {    
        List <Opportunity> returnList = new List < Opportunity > ();
        if(recordId <> null){
            string sQuery = 'Select Id,Name From Opportunity Where id =:recordId';
            for (Opportunity obj: database.query(sQuery)) {
                returnList.add(obj);
            }
        }        
        return returnList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPaymentScheduleList(String selectedProject) {
        
        List<Map<String, String>> getPaymentScheduleDetails = new List<Map<String, String>>();
        List<AggregateResult> lstPaymentSchedule = [select Payment_Schedule_Type__c from Payment_Schedule__c where Project__c =: selectedProject group by Payment_Schedule_Type__c ];
        
        for (AggregateResult ar : lstPaymentSchedule) {      
            Map<String, String> valueMap = new Map<String, String>();
            valueMap.put('label', String.valueof(ar.get('Payment_Schedule_Type__c')));
            valueMap.put('value', String.valueof(ar.get('Payment_Schedule_Type__c')));
            getPaymentScheduleDetails.add(valueMap);
            
        }
        
        Map<String, String> valueMap = new Map<String, String>();
        valueMap.put('label', 'Flexible');
        valueMap.put('value', 'Flexible');
        getPaymentScheduleDetails.add(valueMap);
        
        return getPaymentScheduleDetails ;
        
    }
    
    
    @AuraEnabled(cacheable=true)
    public static list<Booking_Form_Line_Items__c > getPaymentScheduleRecord(string BookingFormId) {    
        List <Booking_Form_Line_Items__c > returnList = new List <  Booking_Form_Line_Items__c > ();
        
        returnList =  [select id,Amount__c, Agreement_Value__c, Booking_Form__c,Payment_Particulars__c, Payment_Schedule_Type__c  from Booking_Form_Line_Items__c where Booking_Form__c =:BookingFormId ] ;
        
        return returnList;
    }  
    
    @AuraEnabled(cacheable=true)
    public static list<Payment_Schedule__c > getPaymentScheduleDetails(String selectedProject , string paymentScheduleType) {    
        List <Payment_Schedule__c > returnList = new List < Payment_Schedule__c > ();
        
        returnList =  [select Payment_Schedule_Type__c,Payment_Particulars__c,Amount__c, Amount_In_Local_Currency__c,Serial_Number__c  from Payment_Schedule__c where Project__c =:selectedProject and Payment_Schedule_Type__c = :paymentScheduleType order by Serial_Number__c asc] ;
        
        return returnList;
    } 
    
    
    Public class WrapperData{
        @AuraEnabled Public String ProjectName {get;Set;}
        @AuraEnabled Public String Block {get;Set;}
        @AuraEnabled Public String Unit {get;Set;}
        @AuraEnabled Public Id OpportunityId {get;Set;}
    }
    
    @AuraEnabled(cacheable=true)
    public static list<WrapperData> getProductDetails(Id recordId) {
        
        //recordId = 'a02Il000001px0GIAQ';
        system.debug('recordId. '+recordId);
        List<WrapperData> BookingFormdata = new List<WrapperData>();
        if(recordId != null){
            
            String sobjectName = String.ValueOf(recordId.getsobjecttype());
            system.debug('sobjectName. '+sobjectName);
            if(sobjectName == 'Opportunity'){
                List<Product2> product = [Select id, Towers__c, Unit__c, Project__c, name from Product2 where Opportunity__c =: recordId order by CreatedDate desc limit 1];
                for (Product2 prod: product) {
                    WrapperData Data = new WrapperData();
                    Data.ProjectName = prod.Project__c;
                    Data.Block = prod.Towers__c;
                    Data.Unit = prod.Unit__c;
                    Data.OpportunityId = recordId;
                    BookingFormdata.add(Data);
                }  
            }else if(sobjectName == 'Booking_Form__c'){
                List<Booking_Form__c> booking = [Select Id, Project_Name__c, Towers__c, Unit__c, Opportunity__c from Booking_Form__c where Id =:recordId order by CreatedDate desc limit 1];
                for (Booking_Form__c book : booking) {
                    WrapperData Data = new WrapperData();
                    Data.ProjectName = book.Project_Name__c ;
                    Data.Block = book.Towers__c;
                    Data.Unit = book.Unit__c;
                    Data.OpportunityId = book.Opportunity__c;
                    BookingFormdata.add(Data);
                }  
            }
        }
        system.debug('BookingFormdata. '+BookingFormdata);
        return BookingFormdata;
    }

    @AuraEnabled
    public static Booking_Form__c BookFormInsert(String wrapperBookingFormData , string files , String OtherApplicentWP , String PaymentScheduleWP) {
        try{
            if (String.isBlank(wrapperBookingFormData)) {
                throw new CustomException('Null or empty JSON data received for wrapperBookingFormData.');
            }
            
            system.debug('wrapperBookingFormData '+wrapperBookingFormData);
            
            Booking_Form__c newBookingForm = new Booking_Form__c();
            BookingFormWp  BookingFormWpDetails = (BookingFormWp) JSON.deserialize(wrapperBookingFormData, BookingFormWp.class);
            
            Product2 product = [SELECT Id, Advance_Maintenance__c, Alt_Unit_Measurement__c, Amenities_Charges__c, Area_in_Sqft__c, 
                                Balcony__c, Base_Value__c, Boundary_East__c, Boundary_North__c, Boundary_South__c, Boundary_West__c, 
                                Car_Parking_Charges__c, Corpus_Fund__c,  
                                Description__c, Description_PLC1__c, Description_PLC2__c, Description_PLC3__c, 
                                Description_PLC4__c, Description_PLC5__c, Direction_Facing__c, Dist_Channel__c, 
                                Electrical_Water_Charges__c, EV_Charges__c, External_wall_area__c, 
                                Face__c, Facing__c, Family, Floor__c, Floor_Number__c, Floor_Rise__c, Infra_Charges__c,
                                Legal_Charges__c, Location__c, Material__c, Material_Description__c, Material_No__c, Name, 
                                Opportunity__c, Other_Charges__c, Parking_Area__c, Parking_No__c, Phone__c, Plant_Description__c, 
                                PLC1__c, PLC2__c, PLC3__c, PLC4__c, PLC5__c, Pricing_Condition__c, Pricing_Sequence__c, ProductCode, 
                                Project__c, QuantityUnitOfMeasure, Sale_Unit_Carpet_Area_in_SFT__c, Sale_Unit_Terrace_Area_in_SFT__c, Sales_Office__c, 
                                Sales_Org__c, Sales_Organization__c, Square_Yards__c, Square_Yards_Price__c, Status__c, 
                                Sublocation__c, SystemModstamp, Total_Cost__c, Towers__c, Type__c, UDS__c, Undivided_share_of_Flat__c, Unit__c, 
                                Unit_Original_Status__c, Utility__c, Valid_from__c 
                                FROM Product2 
                                WHERE Project__c = :BookingFormWpDetails.ProjectName AND Towers__c = :BookingFormWpDetails.Block AND Unit__c = :BookingFormWpDetails.Unit LIMIT 1];
            
            // Create a new record in booking_form__c object
            newBookingForm.Product2__c = product.Id;
            newBookingForm.Block__c = product.Id;
            newBookingForm.Product2__c = product.Id;
            
            
            //Unit Details
            newBookingForm.Opportunity__c = BookingFormWpDetails.Opportunity;
            newBookingForm.Project_Name__c = BookingFormWpDetails.ProjectName;
            newBookingForm.Block__c = BookingFormWpDetails.Block;
            newBookingForm.Towers__c = product.Towers__c;
            newBookingForm.Area_in_Sqft__c = product.Area_in_Sqft__c;
            newBookingForm.Unit_Type__c = product.Type__c;
            newBookingForm.Unit__c = product.Unit__c;
            newBookingForm.Facing__c = product.Facing__c;
            newBookingForm.Sales_Organization__c = product.Sales_Org__c;
            newBookingForm.Sales_Office__c = product.Sales_Office__c;
            newBookingForm.Flat_No__c = BookingFormWpDetails.FlatNo;
            
            //Area Details
            newBookingForm.Carpet_Area__c=product.Sale_Unit_Carpet_Area_in_SFT__c;
            newBookingForm.Balcony__c = product.Balcony__c;
            newBookingForm.Utility__c = product.Utility__c;
            newBookingForm.External_wall_area__c = product.External_wall_area__c;
            newBookingForm.UDS__c = product.UDS__c;
            newBookingForm.SBUA__c = product.Area_in_Sqft__c;
            //Price details
            if(BookingFormWpDetails.BasicRate != '' && BookingFormWpDetails.BasicRate != null){
                newBookingForm.Basic_Price__c = decimal.valueOf(BookingFormWpDetails.BasicRate);
            }
            
            newBookingForm.Car_Parking__c = product.Parking_No__c;
            newBookingForm.Car_Parking_Charges__c = product.Car_Parking_Charges__c;
            newBookingForm.EV_Charges__c = product.EV_Charges__c;
            newBookingForm.Extra_Car_Parking__c=BookingFormWpDetails.ExtraCarParkingNo;
            
            if(BookingFormWpDetails.ExtraCarParking <> '' && BookingFormWpDetails.ExtraCarParking <> null ){             
                newBookingForm.Extra_Car_Parking_Charges__c= decimal.valueOf(BookingFormWpDetails.ExtraCarParking);
            }
            
            if(BookingFormWpDetails.LumpSumAmount <> '' && BookingFormWpDetails.LumpSumAmount <> null ){             
                newBookingForm.Lump_Sum_Amount__c= decimal.valueOf(BookingFormWpDetails.LumpSumAmount);
            }
            
            if(BookingFormWpDetails.OrginalLumpSUmAmount <> '' && BookingFormWpDetails.OrginalLumpSUmAmount <> null ){             
                newBookingForm.OrginalLumpSUmAmount__c= decimal.valueOf(BookingFormWpDetails.OrginalLumpSUmAmount);
            }
            
            
            newBookingForm.Sale_Type__c=BookingFormWpDetails.Saletype;
            newBookingForm.Other_Charges__c=BookingFormWpDetails.OtherCharges;
            
            if(BookingFormWpDetails.GrandTotal <> '' && BookingFormWpDetails.GrandTotal <> null ){ 
                newBookingForm.Booking_Form_Grand_Total__c= decimal.valueOf(BookingFormWpDetails.GrandTotal);
            }      
            
            //First Applicant
            newBookingForm.Customer_Type__c=BookingFormWpDetails.selectedCustomerType;
            newBookingForm.Salutation__c=BookingFormWpDetails.selectedSalutation;
            newBookingForm.First_Name__c=BookingFormWpDetails.FirstName;
            newBookingForm.Last_Name__c=BookingFormWpDetails.LastName;
            newBookingForm.Gender__c=BookingFormWpDetails.Gender;
            newBookingForm.Organization__c=BookingFormWpDetails.Organization;
            newBookingForm.Designation__c=BookingFormWpDetails.Designation;
            newBookingForm.Passport_No__c=BookingFormWpDetails.PassportNo;
            if(BookingFormWpDetails.Validtill  <> '' && BookingFormWpDetails.Validtill  <> null){
                newBookingForm.Valid_till__c= Date.valueOf(BookingFormWpDetails.Validtill);
            }
            
            newBookingForm.Profession__c=BookingFormWpDetails.selectedProfession;
            newBookingForm.Salutationr__c=BookingFormWpDetails.selectedSalutationr;
            newBookingForm.First_Namer__c=BookingFormWpDetails.FirstNamer;
            newBookingForm.Last_Namer__c=BookingFormWpDetails.LastNamer;
            
            if(BookingFormWpDetails.DateofBirth  <> '' && BookingFormWpDetails.DateofBirth  <> null){
                newBookingForm.DOB__c= Date.valueOf(BookingFormWpDetails.DateofBirth);
            }
            
            newBookingForm.Age__c=BookingFormWpDetails.Age;
            newBookingForm.Mobile__c=BookingFormWpDetails.Mobile;
            newBookingForm.Alternative_Mobile__c=BookingFormWpDetails.AlternativeMobile;
            newBookingForm.TelRes__c=BookingFormWpDetails.TelRes;
            newBookingForm.TelOffice__c=BookingFormWpDetails.TelOffice;
            newBookingForm.Email__c=BookingFormWpDetails.Email;
            newBookingForm.Alternative_Email__c=BookingFormWpDetails.AlternativeEmail;
            newBookingForm.Marital_Status__c= BookingFormWpDetails.selectedMaritalStatus;
            
            if(BookingFormWpDetails.AnniversaryDate  <> '' && BookingFormWpDetails.AnniversaryDate  <> null){
                newBookingForm.Anniversary_Date__c= Date.valueOf(BookingFormWpDetails.AnniversaryDate);
            }
            
            newBookingForm.Pan_No__c=BookingFormWpDetails.PanNo;
            newBookingForm.Aadhar__c= BookingFormWpDetails.AadharNo;
            newBookingForm.Sign_through_Digital_Signature__c= BookingFormWpDetails.SignthroughDigitalSignature;
                       
            //Present&PermanentAddress
            newBookingForm.Same_as_Present_Address__c=BookingFormWpDetails.SameasPresentAddress;
            newBookingForm.StreetHouse_No2__c=BookingFormWpDetails.permanentStreet;
            newBookingForm.StreetHouse_No__c=BookingFormWpDetails.presentStreet;
            newBookingForm.Street_51__c=BookingFormWpDetails.permanentStreet5;
            newBookingForm.Street_5__c=BookingFormWpDetails.presentStreet5;
            newBookingForm.Street_4__c=BookingFormWpDetails.presentStreet4;
            newBookingForm.Street_31__c=BookingFormWpDetails.permanentStreet3;
            newBookingForm.Street_3__c=BookingFormWpDetails.presentStreet3;
            newBookingForm.Street_21__c=BookingFormWpDetails.permanentStreet2;
            newBookingForm.Street_2__c=BookingFormWpDetails.presentStreet2;
            newBookingForm.Street_41__c=BookingFormWpDetails.permanentStreet4;
            newBookingForm.Country2__c=BookingFormWpDetails.selectedPermanentCountry;
            newBookingForm.Country__c=BookingFormWpDetails.selectedPresentCountry;
            newBookingForm.City2__c=BookingFormWpDetails.permanentCity;
            newBookingForm.City__c=BookingFormWpDetails.presentCity;
            newBookingForm.State2__c=BookingFormWpDetails.selectedPermanentState;
            newBookingForm.State__c=BookingFormWpDetails.selectedPresentState;
            
            
            if(BookingFormWpDetails.permanentPinCode  <> '' && BookingFormWpDetails.permanentPinCode  <> null){
                newBookingForm.Pin_Code2__c= BookingFormWpDetails.permanentPinCode;
            }
            
            
            if(BookingFormWpDetails.presentPinCode  <> '' && BookingFormWpDetails.presentPinCode  <> null){
                newBookingForm.Pin_Code__c= BookingFormWpDetails.presentPinCode;
            }
            
            system.debug('newBookingForm'+newBookingForm);
            newBookingForm.Booking_Form_Status__c=BookingFormWpDetails.Booking_Form_Status;
            
            
            if(BookingFormWpDetails.BookingFormId <> null && BookingFormWpDetails.BookingFormId <> ''){
                newBookingForm.Id = BookingFormWpDetails.BookingFormId;            
            }
            
            //Scheme
            
            newBookingForm.NDS_or_SDS__c= BookingFormWpDetails.NDSORSDS;
            newBookingForm.Project_Meterial__c= BookingFormWpDetails.meterial;
            
            if(BookingFormWpDetails.DiscountAmount  <> '' && BookingFormWpDetails.DiscountAmount  <> null){
                newBookingForm.Scheme_Discount_Amount__c= Decimal.valueOf(BookingFormWpDetails.DiscountAmount);
            }
            
            if(BookingFormWpDetails.OrginalBasePrice  <> '' && BookingFormWpDetails.OrginalBasePrice  <> null){
                newBookingForm.Orginal_Base_Price__c= Decimal.valueOf(BookingFormWpDetails.OrginalBasePrice);
            }
            
            if(BookingFormWpDetails.extraBasePrice  <> '' && BookingFormWpDetails.extraBasePrice  <> null){
                newBookingForm.Extra_Base_Price_Discount__c= Decimal.valueOf(BookingFormWpDetails.extraBasePrice);
            }
            
            
            if(BookingFormWpDetails.ndsValue  <> '' && BookingFormWpDetails.ndsValue  <> null){
                newBookingForm.NDS_per_sft__c= Decimal.valueOf(BookingFormWpDetails.ndsValue);
            }
            if(BookingFormWpDetails.sdsValue  <> '' && BookingFormWpDetails.sdsValue  <> null){         
                newBookingForm.SDS_per_sft__c= Decimal.valueOf(BookingFormWpDetails.sdsValue);
            }
            
            if(BookingFormWpDetails.Discount  <> '' && BookingFormWpDetails.Discount  <> null){         
                newBookingForm.Discount_Amount__c = Decimal.valueOf(BookingFormWpDetails.Discount);
            }

            newBookingForm.Use_Scheme__c=BookingFormWpDetails.useScheme;
            newBookingForm.SchemesName__c=BookingFormWpDetails.selectedScheme;
            if(BookingFormWpDetails.ExtraDiscountAmount  <> '' && BookingFormWpDetails.ExtraDiscountAmount  <> null){           
                newBookingForm.Extra_Discount_Amount__c = Decimal.valueOf(BookingFormWpDetails.ExtraDiscountAmount);        
            }
            
            if(BookingFormWpDetails.ndsDiscountAmount  <> '' && BookingFormWpDetails.ndsDiscountAmount  <> null){           
                newBookingForm.nds_Discount_Amount__c= Decimal.valueOf(BookingFormWpDetails.ndsDiscountAmount);        
            }
            
            if(BookingFormWpDetails.sdsDiscountAmount  <> '' && BookingFormWpDetails.sdsDiscountAmount  <> null){  
                newBookingForm.sds_Discount_Amount__c= Decimal.valueOf(BookingFormWpDetails.sdsDiscountAmount);
                newBookingForm.SDS_Approvel_Status__c= BookingFormWpDetails.SDSApprovelStatus;
            }
            newBookingForm.encash__c=BookingFormWpDetails.encash;
            newBookingForm.EnCash_Amount__c=BookingFormWpDetails.SchemeAmount;
            
            //Account 
            newBookingForm.Account_Name__c=BookingFormWpDetails.AccountHolderName;
            newBookingForm.Account_No__c=BookingFormWpDetails.AccountNo;
            newBookingForm.Name_of_Bank__c=BookingFormWpDetails.NameofBank;
            newBookingForm.IFSC_Code__c=BookingFormWpDetails.IFSCCode;
            newBookingForm.Bank_Branch__c=BookingFormWpDetails.BankBranch;
            
            if((newBookingForm.IFSC_Code__c <> null && newBookingForm.IFSC_Code__c <> '') || (newBookingForm.Sales_Organization__c <> null && newBookingForm.Sales_Organization__c <> '') || (newBookingForm.Bank_Branch__c <> null && newBookingForm.Bank_Branch__c <> '') || (newBookingForm.Name_of_Bank__c <> null && newBookingForm.Name_of_Bank__c <> '')){
                IFSCCodeSAPAPi(BookingFormWpDetails.IFSCCode ,BookingFormWpDetails.NameofBank, BookingFormWpDetails.BankBranch, newBookingForm.Sales_Organization__c);
            }
            
            //other changes 
            newBookingForm.Corpus_Fund__c=BookingFormWpDetails.CampusFund;
            newBookingForm.Advance_Maintenance__c=BookingFormWpDetails.AdvanceMaintenance;
            newBookingForm.GST_on_Instalments__c=BookingFormWpDetails.GSTonInstalments;
            newBookingForm.Stamp_Duty_Fee__c=BookingFormWpDetails.StampDuty;
            newBookingForm.Doc_Charges__c=BookingFormWpDetails.DocumentationCharges;
            newBookingForm.Other_Charges_If__c=BookingFormWpDetails.OtherChargesIf;
            
            newBookingForm.Channel_Partner_Code__c =  BookingFormWpDetails.SourceChannelPartnerCode;
            newBookingForm.Channel_Partner_Name__c =BookingFormWpDetails.SourceChannelPartnerName;
            newBookingForm.Reference_Employee_Code__c =BookingFormWpDetails.SourceReferenceEmployeeCode;
            newBookingForm.Source_Employee_Name__c =BookingFormWpDetails.SourceEmployeeName;        
            newBookingForm.Source_Employee_Company_Name__c =BookingFormWpDetails.SourceEmployeeCompanyName;
            newBookingForm.Customer_Code__c =BookingFormWpDetails.SourceCustomerCode;
            newBookingForm.Customer_Name__c =BookingFormWpDetails.SourceCustomerName;
            newBookingForm.Customer_Relation__c =BookingFormWpDetails.SourceCustomerRelationName;         
            newBookingForm.Source_Flat_No__c = BookingFormWpDetails.SourceFlatNo;
            newBookingForm.Source_Project_Name__c=BookingFormWpDetails.SourceProjectName;
            
            if(BookingFormWpDetails.SourceExistCustomerDiscount  <> '' && BookingFormWpDetails.SourceExistCustomerDiscount  <> null){
                newBookingForm.Exist_Customer_Discount__c =Decimal.valueOf(BookingFormWpDetails.SourceExistCustomerDiscount);
            }
            newBookingForm.Exist_Customer_Code__c =BookingFormWpDetails.SourceExiCustomerCode;
            newBookingForm.Exist_Customer_Name__c =BookingFormWpDetails.SourceExiCustomerName;
            newBookingForm.Exist_Customer_Relation__c =BookingFormWpDetails.SourceExiCustomerRelationName;
            newBookingForm.Exist_Customer_Flat_No__c =BookingFormWpDetails.SourceExiFlatNo;         
            newBookingForm.Exist_Customer_Project_Name__c = BookingFormWpDetails.SourceExiProjectName;
            
            //source       
            newBookingForm.BookingSource__c =BookingFormWpDetails.SourceValue;
            if(newBookingForm.BookingSource__c == 'Existing Customer'){
                
                newBookingForm.Channel_Partner_Code__c = '';
                newBookingForm.Channel_Partner_Name__c = '';
                newBookingForm.Reference_Employee_Code__c = '';
                newBookingForm.Source_Employee_Name__c = '';
                newBookingForm.Source_Employee_Company_Name__c = '';
                newBookingForm.Customer_Code__c = '';
                newBookingForm.Customer_Name__c = '';
                newBookingForm.Customer_Relation__c = '';
                newBookingForm.Source_Flat_No__c = '';
                newBookingForm.Source_Project_Name__c = '';
                
            }else if(newBookingForm.BookingSource__c == 'Channel Partner'){
                
                newBookingForm.Reference_Employee_Code__c = '';
                newBookingForm.Source_Employee_Name__c = '';
                newBookingForm.Source_Employee_Company_Name__c = '';
                newBookingForm.Customer_Code__c = '';
                newBookingForm.Customer_Name__c = '';
                newBookingForm.Customer_Relation__c = '';
                newBookingForm.Source_Flat_No__c = '';
                newBookingForm.Source_Project_Name__c = '';
                
                newBookingForm.Exist_Customer_Code__c = '';
                newBookingForm.Exist_Customer_Name__c = '';
                newBookingForm.Exist_Customer_Relation__c = '';
                newBookingForm.Exist_Customer_Flat_No__c = '';
                newBookingForm.Exist_Customer_Project_Name__c = '';
                newBookingForm.Exist_Customer_Discount__c = 0;
                
                
            }else if(newBookingForm.BookingSource__c == 'Reference by Employe'){
                newBookingForm.Channel_Partner_Code__c = '';
                newBookingForm.Channel_Partner_Name__c = '';
                newBookingForm.Customer_Code__c = '';
                newBookingForm.Customer_Name__c = '';
                newBookingForm.Customer_Relation__c = '';
                newBookingForm.Source_Flat_No__c = '';
                newBookingForm.Source_Project_Name__c = '';
                newBookingForm.Exist_Customer_Code__c = '';
                newBookingForm.Exist_Customer_Name__c = '';
                newBookingForm.Exist_Customer_Relation__c = '';
                newBookingForm.Exist_Customer_Flat_No__c = '';
                newBookingForm.Exist_Customer_Project_Name__c = '';
                newBookingForm.Exist_Customer_Discount__c = 0;
                
            }else if(newBookingForm.BookingSource__c == 'Reference by Custome'){
                newBookingForm.Reference_Employee_Code__c = '';
                newBookingForm.Channel_Partner_Code__c = '';
                newBookingForm.Channel_Partner_Name__c = '';
                newBookingForm.Exist_Customer_Code__c = '';
                newBookingForm.Exist_Customer_Name__c = '';
                newBookingForm.Exist_Customer_Relation__c = '';
                newBookingForm.Exist_Customer_Flat_No__c = '';
                newBookingForm.Exist_Customer_Project_Name__c = '';
                newBookingForm.Exist_Customer_Discount__c = 0;
            }else {
                
                newBookingForm.Channel_Partner_Code__c = '';
                newBookingForm.Channel_Partner_Name__c = '';
                newBookingForm.Customer_Code__c = '';
                newBookingForm.Customer_Name__c = '';
                newBookingForm.Customer_Relation__c = '';
                newBookingForm.Source_Flat_No__c = '';
                newBookingForm.Source_Project_Name__c = '';
                newBookingForm.Exist_Customer_Code__c = '';
                newBookingForm.Exist_Customer_Name__c = '';
                newBookingForm.Exist_Customer_Relation__c = '';
                newBookingForm.Exist_Customer_Flat_No__c = '';
                newBookingForm.Exist_Customer_Project_Name__c = '';
                newBookingForm.Exist_Customer_Discount__c = 0;
                
            }   
            
            //Payment Schedule
            newBookingForm.Payment_Schedule_Type__c=BookingFormWpDetails.selectedPaymentType;
            if(BookingFormWpDetails.PaymentScheduleTotalAmount  <> '' && BookingFormWpDetails.PaymentScheduleTotalAmount  <> null){
                newBookingForm.Payment_Sc_Total__c= Decimal.valueOf(BookingFormWpDetails.PaymentScheduleTotalAmount);
            }
            /*
             newBookingForm.Payment_Schedule_Type__c = BookingFormWpDetails.selectedPaymentType;

			if (String.isNotBlank(BookingFormWpDetails.PaymentScheduleTotalAmount)) {
   			Decimal paymentAmount = Decimal.valueOf(BookingFormWpDetails.PaymentScheduleTotalAmount);
   		    newBookingForm.Payment_Sc_Total__c = paymentAmount.setScale(0, System.RoundingMode.CEILING); // Always rounds UP
			}*/

            //PaymentSchedulepercentage
            if(BookingFormWpDetails.PaymentSchedulepercentage  <> '' && BookingFormWpDetails.PaymentSchedulepercentage  <> null){
                newBookingForm.Payment_Schedule_percentage__c= Decimal.valueOf(BookingFormWpDetails.PaymentSchedulepercentage);
            }
            
            
            //other info
            newBookingForm.Service_Category__c =BookingFormWpDetails.selectedServiceCategory;
            newBookingForm.Professional_Details__c =BookingFormWpDetails.selectedProfessionDetails;
            newBookingForm.Annual_Income__c =BookingFormWpDetails.selectedAnnualIncome;
            newBookingForm.Payment_source__c =BookingFormWpDetails.selectedPaymentSource;
            newBookingForm.Purchase_of_Purpose__c =BookingFormWpDetails.selectedPurchase;
            newBookingForm.Other_Projects__c =BookingFormWpDetails.selectedOtherProject;        
            newBookingForm.Location_of_Intrest__c =BookingFormWpDetails.selectedLocationString;
            newBookingForm.Preferred_Bank__c=BookingFormWpDetails.PreferredBank;
            
            //Remarks
            newBookingForm.Select_Remarks__c = BookingFormWpDetails.selectedRemarks;
            newBookingForm.Remarks_Description__c = BookingFormWpDetails.RemarksDescription;
            newBookingForm.Sales_PersonID__c=BookingFormWpDetails.SalesPersonEmployeeID;
            newBookingForm.Declaration__c=BookingFormWpDetails.Declaration;

            upsert newBookingForm;
            if(newBookingForm.Id <> null){
                
                List<Product2> ProductUpdate = new List<Product2>();
                if(newBookingForm.Product2__c <> null && newBookingForm.Booking_Form_Status__c == 'Draft Save'){
                    Product2 Proupdate = new Product2();
                    Proupdate.Id = newBookingForm.Product2__c;
                    Proupdate.Status__c = 'Hold';
                    ProductUpdate.add(Proupdate);
                }   
                
                if(ProductUpdate <> null && !ProductUpdate.isEmpty()){
                    update ProductUpdate;
                }
                
                
                List<OtherApplicentWp>  OtherApplicentDetails = (List<OtherApplicentWp>)JSON.deserialize(OtherApplicentWP, List<OtherApplicentWp>.class);
                list<Other_Applicants__c> OtherApplicantList = new list<Other_Applicants__c>();
                
                Set<Id> UpdateOtherApplicant = new Set<Id>();
                for(OtherApplicentWp OApplicent:OtherApplicentDetails){ 
                    system.debug('OApplicent'+OApplicent);
                    
                    Other_Applicants__c OtherApplicantRec = new Other_Applicants__c();
                    OtherApplicantRec.Salutation__c = OApplicent.Salutation1;
                    OtherApplicantRec.applicent_Number__c = OApplicent.index;
                    OtherApplicantRec.First_Name__c = OApplicent.FirstName1;
                    OtherApplicantRec.Last_Name__c = OApplicent.LastName1;
                    OtherApplicantRec.Gender__c = OApplicent.Gender1;
                    OtherApplicantRec.Organization__c = OApplicent.Organization1;
                    OtherApplicantRec.Occupation__c = OApplicent.Occupation1;
                    OtherApplicantRec.RSalutation__c = OApplicent.salutationr1Options;
                    OtherApplicantRec.First_Namer__c = OApplicent.FirstNamer1;
                    OtherApplicantRec.Last_Namer__c = OApplicent.LastNamer1;
                    if(OApplicent.DateofBirth1  <> '' && OApplicent.DateofBirth1  <> null){
                        OtherApplicantRec.Date_of_Birth__c= Date.valueOf(OApplicent.DateofBirth1);
                    }
                    if(OApplicent.age1  <> '' && OApplicent.age1  <> null){
                        OtherApplicantRec.Age__c= OApplicent.age1;
                    }
                    OtherApplicantRec.Marital_Status__c = OApplicent.MaritalStatus1;
                    
                    if(OApplicent.AnniversaryDate1  <> '' && OApplicent.AnniversaryDate1  <> null){
                        OtherApplicantRec.Anniversary_Date__c= Date.valueOf(OApplicent.AnniversaryDate1);
                    }
                    
                    // OtherApplicantRec.Anniversary_Date__c = OApplicent.AnniversaryDate1;
                    if(OApplicent.Mobile1  <> '' && OApplicent.Mobile1  <> null){
                        OtherApplicantRec.Mobile__c= OApplicent.Mobile1;
                    } 
                    
                    //OtherApplicantRec.Mobile__c = OApplicent.Mobile1;
                    OtherApplicantRec.Email__c = OApplicent.Email1;
                    OtherApplicantRec.Passport_No__c = OApplicent.PassportNo1;
                    OtherApplicantRec.Pan_No__c = OApplicent.PanNo1;
                    //if(OApplicent.AadharNo1  <> '' && OApplicent.AadharNo1  <> null){
                    OtherApplicantRec.Aadhar_No__c= OApplicent.AadharNo1;
                    //}
                    // OtherApplicantRec.Aadhar_No__c = OApplicent.AadharNo1;
                    //OtherApplicantRec.Valid_till__c = OApplicent.Validtill1;
                    if(OApplicent.Validtill1  <> '' && OApplicent.Validtill1  <> null){
                        OtherApplicantRec.Valid_till__c= Date.valueOf(OApplicent.Validtill1);
                    }
                    OtherApplicantRec.Booking_Form__c = newBookingForm.Id;
                    if(OApplicent.Id != null && OApplicent.Id != ''){
                        OtherApplicantRec.Id = (Id) OApplicent.Id;
                        UpdateOtherApplicant.add(OtherApplicantRec.Id);
                    }
                    OtherApplicantList.add(OtherApplicantRec);                
                }
                
                list<Other_Applicants__c> checkoldOtherApplicant = [select id from Other_Applicants__c where Booking_Form__c =: newBookingForm.Id and Id Not in :(UpdateOtherApplicant)];
                
                if(!OtherApplicantList.isEmpty() && OtherApplicantList <> null){
                    system.debug('OtherApplicantList'+OtherApplicantList);  
                    upsert OtherApplicantList;
                    
                    
                    if(!checkoldOtherApplicant.isEmpty() && checkoldOtherApplicant <> null){
                        system.debug('checkoldOtherApplicant'+checkoldOtherApplicant);                    
                        Delete checkoldOtherApplicant;
                    }
                    
                }

                List<FileWrapper>  fileDetails = (List<FileWrapper>)JSON.deserialize(files, List<FileWrapper>.class);            
                List<Attachment> attachments = new List<Attachment>();
                system.debug('files test '+files);
                for (FileWrapper file : fileDetails) {
                    system.debug('file'+file.fileContent);
                    system.debug('fileName'+file.fileName);
                    system.debug('recordId'+newBookingForm.Id);
                    
                    ContentVersion cVersion = new ContentVersion();            
                    cVersion.PathOnClient = file.fileName;//File name with extention 
                    cVersion.Title = file.fileName;//Name of the file
                    cVersion.VersionData = EncodingUtil.base64Decode(file.fileContent);//File content
                    
                    cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
                    //cVersion.PublishStatus = 'P';
                    Insert cVersion;
                    
                    //Get the ContentDocumentId
                    Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                    
                    //Insert ContentDocumentLink
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
                    cDocLink.LinkedEntityId = newBookingForm.Id;//Add attachment parentId
                    cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                    cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                    Insert cDocLink;                
                }
                
                
                
                //PaymentScheduleWP
                //
                List<PaymentScheduleWp>  PaymentScheduleDetails = (List<PaymentScheduleWp>)JSON.deserialize(PaymentScheduleWP, List<PaymentScheduleWp>.class);
                list<Booking_Form_Line_Items__c > PaymentScheduleList = new list<Booking_Form_Line_Items__c >();
                
                Set<Id> UpdatePaymentSchedule = new Set<Id>();
                for(PaymentScheduleWp PaymentSched:PaymentScheduleDetails){ 
                    
                    
                    Booking_Form_Line_Items__c BookingFormLineItemRec = new Booking_Form_Line_Items__c();

                    if(PaymentSched.Amount  <> '' && PaymentSched.Amount  <> null){
                        BookingFormLineItemRec.Agreement_Value__c = Decimal.valueOf(PaymentSched.Amount);
                    }
                    if(PaymentSched.Amount_In_Local_Currency  <> '' && PaymentSched.Amount_In_Local_Currency  <> null){
                        BookingFormLineItemRec.Amount__c = Decimal.valueOf(PaymentSched.Amount_In_Local_Currency);
                    }
                    BookingFormLineItemRec.Booking_Form__c = newBookingForm.Id;
                    BookingFormLineItemRec.Payment_Particulars__c = PaymentSched.Payment_Particulars;
                    BookingFormLineItemRec.Payment_Schedule_Type__c = PaymentSched.Payment_Schedule_Type;
                    BookingFormLineItemRec.S_No__c = PaymentSched.SerialNumber;
                    
                    if(PaymentSched.Id != null && PaymentSched.Id != ''){
                        BookingFormLineItemRec.Id = (Id) PaymentSched.Id;
                        UpdatePaymentSchedule.add(BookingFormLineItemRec.Id);
                    }
                    PaymentScheduleList.add(BookingFormLineItemRec);                
                }
                
                list<Booking_Form_Line_Items__c> checkoldBookingFormLineItem = [select id from Booking_Form_Line_Items__c where Booking_Form__c =: newBookingForm.Id and Id Not in :(UpdatePaymentSchedule)];
                
                if(!PaymentScheduleList.isEmpty() && PaymentScheduleList <> null){
                    //system.debug('OtherApplicantList'+OtherApplicantList);    
                    upsert PaymentScheduleList;
                    
                    
                    if(!checkoldBookingFormLineItem.isEmpty() && checkoldBookingFormLineItem <> null){
                        Delete checkoldBookingFormLineItem;
                    }
                }
            }
            
            return newBookingForm;
        }catch(Exception e){
            System.debug('Exception '+e.getlineNumber()+'   error '+e.getMessage());
            throw new CustomException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void uploadFiles(string files, Id recordId) {
        system.debug('test lo'+files);
        List<FileWrapper>  fileDetails = (List<FileWrapper>)JSON.deserialize(files, List<FileWrapper>.class);            
        List<Attachment> attachments = new List<Attachment>();
        system.debug('files test '+files);
        for (FileWrapper file : fileDetails) {
            system.debug('file'+file.fileContent);
            system.debug('fileName'+file.fileName);
            system.debug('recordId'+recordId);
            
            ContentVersion cVersion = new ContentVersion();            
            cVersion.PathOnClient = file.fileName;//File name with extention 
            cVersion.Title = file.fileName;//Name of the file
            cVersion.VersionData = EncodingUtil.base64Decode(file.fileContent);//File content
            
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            //cVersion.PublishStatus = 'P';
            Insert cVersion;
            
            //Get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            
            //Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = recordId;//Add attachment parentId
            cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            Insert cDocLink;                
        }
        
        
    }
    
    
    @AuraEnabled
    public static Boolean IsBookingFormExists(string OpportunityId ,String selectedProject, String selectedBlock, String selectedUnit){
         system.debug(OpportunityId);
         system.debug(selectedProject);
         system.debug(selectedBlock);
         system.debug(selectedUnit);
        
        Boolean IsRecordExisted = False; 
        string query;
        string searchText ='';
        if(OpportunityId <> null && OpportunityId <> ''){
            searchText =' and Opportunity__c  = \''+(Id)OpportunityId+'\'';
        }
        
        query = 'select Id from Booking_Form__c  where Project_Name__c =: selectedProject and Towers__c =: selectedBlock and Unit__c =:selectedUnit '+ searchText +'';
        system.debug(query);
        
        List<Booking_Form__c> BookingFormRecords = Database.query(''+query+'');
        system.debug(BookingFormRecords);
        if(!BookingFormRecords.isEmpty() && BookingFormRecords <> null){
            IsRecordExisted = true;
        }else{
            IsRecordExisted = false;
        }
        system.debug('IsRecordExisted'+IsRecordExisted);
        
        
        return IsRecordExisted;
        
        
    }
    
    @AuraEnabled
    public static Booking_Form__c getBookingFormRecord(string OpportunityId ,String selectedProject, String selectedBlock, String selectedUnit){
        
        Booking_Form__c BookingFormRecord = new Booking_Form__c();
        string query;
        string searchText ='';
        ID BookingfmId;
        if(OpportunityId <> null && OpportunityId <> ''){
            searchText =' and Opportunity__c  = \''+(Id)OpportunityId+'\'';
        }
        
        query = 'select Id from Booking_Form__c  where Project_Name__c =: selectedProject and Towers__c =: selectedBlock and Unit__c =:selectedUnit '+ searchText +' order by CreatedDate desc';
        system.debug('query'+query);
        List<Booking_Form__c> BookingFormRecords = Database.query(''+query+'');
        system.debug('BookingFormRecords 2'+BookingFormRecords);
        if(!BookingFormRecords.isEmpty() && BookingFormRecords <> null){
            system.debug('BookingFormRecords'+BookingFormRecords);
            BookingfmId = BookingFormRecords[0].id;           
        }
        
        
        if(BookingfmId <> null){
            List<Booking_Form__c> BookingFormResults = [select Id,Block__c,Opportunity__c,Project_Name__c,Booking_Form_Status__c, Towers__c,Area_in_Sqft__c,Unit_Type__c,
                                                        Unit__c,Facing__c,Flat_No__c,Carpet_Area__c,Balcony__c,Utility__c,External_Wall_Area__c,UDS__c,
                                                        SBUA__c,Basic_Price__c,Car_Parking_Charges__c,Extra_Car_Parking__c, Extra_Car_Parking_Charges__c,EV_Charges__c,Lump_Sum_Amount__c,Sale_Type__c,Other_Charges__c,
                                                        Customer_Type__c,Salutation__c,First_Name__c,Last_Name__c,Gender__c,Organization__c,Designation__c,Passport_No__c,
                                                        Valid_till__c,Profession__c,Salutationr__c,First_Namer__c,Last_Namer__c,DOB__c,Age__c,Mobile__c,Alternative_Mobile__c,
                                                        TelRes__c,TelOffice__c,Email__c,Marital_Status__c,Alternative_Email__c,Anniversary_Date__c,Pan_No__c,Aadhar__c,
                                                        Same_as_Present_Address__c,StreetHouse_No2__c,StreetHouse_No__c,Street_51__c,Street_5__c,Street_4__c,Street_31__c,
                                                        Street_3__c,Street_21__c,Street_2__c,Street_41__c,Country2__c,Country__c,City2__c,City__c,State2__c,State__c,
                                                        Account_Name__c,Account_No__c,Name_of_Bank__c,Bank_Branch__c,IFSC_Code__c,Corpus_Fund__c,Advance_Maintenance__c,GST_on_Instalments__c,
                                                        Stamp_Duty_Fee__c,Doc_Charges__c,Other_Charges_If__c,Service_Category__c,Professional_Details__c,Annual_Income__c,
                                                        Payment_source__c,Purchase_of_Purpose__c,Other_Projects__c,Location_of_Intrest__c,Select_Remarks__c,Remarks_Description__c,
                                                        NDS_or_SDS__c,NDS_per_sft__c,SDS_per_sft__c,Use_Scheme__c,SchemesName__c,nds_Discount_Amount__c,sds_Discount_Amount__c,
                                                        encash__c,EnCash_Amount__c,BookingSource__c,Exist_Customer_Discount__c,Channel_Partner_Code__c,Channel_Partner_Name__c,
                                                        Reference_Employee_Code__c,Source_Employee_Name__c,Source_Employee_Company_Name__c,Customer_Code__c,Customer_Name__c,
                                                        Source_Flat_No__c,Source_Project_Name__c,Pin_Code2__c,Pin_Code__c,Payment_Sc_Total__c,Payment_Schedule_Type__c,
                                                        SDS_Approvel_Status__c,SDS_Approvel_Comments__c,Payment_Schedule_percentage__c,Booking_Form_Grand_Total__c,
                                                        Declaration__c,Sales_PersonID__c, Sales_Organization__c, Sales_Office__c, Project_Meterial__c,Scheme_Discount_Amount__c,Orginal_Base_Price__c,Extra_Base_Price_Discount__c,
                                                        Discount_Amount__c,Extra_Discount_Amount__c,OrginalLumpSUmAmount__c,Exist_Customer_Code__c,Sign_through_Digital_Signature__c,
                                                        Exist_Customer_Flat_No__c,Exist_Customer_Name__c,Exist_Customer_Project_Name__c,Exist_Customer_Relation__c
                                                        from Booking_Form__c  where Id =:BookingfmId  order by CreatedDate desc ];
            
            if(BookingFormResults <> null && !BookingFormResults.isEmpty()){
                BookingFormRecord = BookingFormResults[0];
            }
            
        }
        
        system.debug('BookingfmId'+BookingfmId);
        
        return BookingFormRecord;
    }
    
    
    @AuraEnabled
    public static List<Discount__c> CheckNdsDiscount(String selectedProject){
        
        List<Discount__c> NDSDiscountDetails = new List<Discount__c>();
        NDSDiscountDetails = [select id,Project_Name__c, Amount_in_Local_Currency__c from Discount__c where Project_Name__c=: selectedProject order by CreatedDate Desc limit 1];
        
        return NDSDiscountDetails;
    }
    
    
    @AuraEnabled
    public static List<contact> getContactDetails(String OpportunityId){
        List<contact> Conlist = new List<contact>();
        Id OppId = (Id)OpportunityId;
        //date Currentdate = Date.today();
        // SchemeDetails = [select id,CreatedDate,Valid_from__c, Valid_to__c,Description__c , Project_Name__c,Net_Value_in_Doccument_Currency__c from Scheme__c  where Project_Name__c =:selectedProject and Scheme_Valid_To__c  >= TODAY  order by CreatedDate Desc];
        if(OpportunityId <> null && OpportunityId <> ''){
            List<Opportunity> opprec  = [select id,AccountId  from Opportunity where id =:OppId];
            
            if(!opprec.isEmpty() && opprec<> null){
                Id AccountId = opprec[0].AccountId;
                if(AccountId <> null){
                    Conlist = [select id,FirstName, LastName,DOB__c,Phone, Email,Phone_2__c,Salutation from Contact where AccountId =:AccountId order by CreatedDate desc limit 1 ];
                    
                }
                
            }
        }
        
        return Conlist;
        
        
    }
    
    @AuraEnabled
    public static List<Scheme__c> getSchemeRecords(String selectedProject){
        List<Scheme__c> SchemeDetails = new List<Scheme__c>();
        date Currentdate = Date.today();
        SchemeDetails = [select id,CreatedDate,Valid_from__c, Valid_to__c,Description__c , Project_Name__c,Net_Value_in_Doccument_Currency__c from Scheme__c  where Project_Name__c =:selectedProject and Scheme_Valid_To__c  >= TODAY  order by CreatedDate Desc];
        
        return SchemeDetails;
    }
    
    @AuraEnabled
    public static List<Booking_Form_Sources__c > getBookingsourceslist(){
        List<Booking_Form_Sources__c > BookingsourceDetails = new List<Booking_Form_Sources__c >();
        BookingsourceDetails = [select id,Source_Type__c, Name from Booking_Form_Sources__c ];
        
        return BookingsourceDetails;
    }   
    
    @AuraEnabled
    public static List<Loyalty_Bonus_Data__c > getloyaltyBonuslist(string BokingFormSourceId , string selectedProject){
        List<Loyalty_Bonus_Data__c > BookingLoyalityDetails = new List<Loyalty_Bonus_Data__c >();
        BookingLoyalityDetails = [select id,Booking_Form_Source__c, Loyalty_Bonus__c, Name, Percentage__c, Project_Name__c from Loyalty_Bonus_Data__c where Booking_Form_Source__c =:BokingFormSourceId and Project_Name__c =:selectedProject order by CreatedDate desc limit 1 ];
        
        return BookingLoyalityDetails;
    } 
    
    
    @AuraEnabled
    public static List<Cost_Sheet__c> getCostSheetRecord(string OpportunityId ,String selectedProject, String selectedBlock, String selectedUnit){
        list<Cost_Sheet__c> CostSheetDetail = new list<Cost_Sheet__c>();
        string query;
        string searchText ='';
        ID BookingfmId;
        if(OpportunityId <> null && OpportunityId <> ''){
            searchText =' and Opportunity__c  = \''+(Id)OpportunityId+'\'';
        }
        query = 'select id, Opportunity__c, Project__c, Tower__c, Unit_No__c, Basic_Price__c,Cost_of_the_Unit__c, Clubhouse_Charges__c, Infrastructure_charges__c, Car_Parking__c  from Cost_Sheet__c where Project__c =: selectedProject and Tower__c =: selectedBlock and Unit_No__c =:selectedUnit '+ searchText +' order by CreatedDate desc limit 1';
        //query = 'select Id from Booking_Form__c  where Project_Name__c =: selectedProject and Towers__c =: selectedBlock and Unit__c =:selectedUnit '+ searchText +' order by CreatedDate desc';
        system.debug('query'+query);
        List<Cost_Sheet__c> CostSheetDetails = Database.query(''+query+'');
        if(CostSheetDetails <> null && !CostSheetDetails.isEmpty()){
            CostSheetDetail = CostSheetDetails;
        }
        return CostSheetDetail;
        
    }   
    
    @AuraEnabled
    public static List<Other_Applicants__c>  getOtherApplicantRecord (string BookingFormId ){
        List<Other_Applicants__c> OtherApplicantDetails = new List<Other_Applicants__c>();
        if(BookingFormId <> null  && BookingFormId <> ''){
            OtherApplicantDetails = [select id,Salutation__c,First_Name__c,Last_Name__c,Gender__c,Occupation__c,RSalutation__c,First_Namer__c,Last_Namer__c,Date_of_Birth__c,Age__c,Marital_Status__c,Anniversary_Date__c,Mobile__c,Email__c,Passport_No__c,Pan_No__c,Aadhar_No__c,Valid_till__c,Booking_Form__c from Other_Applicants__c where Booking_Form__c =:BookingFormId ];
        }        
        
        return OtherApplicantDetails;
        
    }
    
    public class FileWrapper {
        @AuraEnabled
        public String fileName;
        @AuraEnabled
        public String fileContent;
    }
    
    Public Class BookingFormWp {
        public String BookingFormId;
        public String Booking_Form_Status;
        public String Opportunity;
        public String ProjectName;
        public String Block;
        public String Unit;
        public String Tower;
        public String facing;
        public Integer sftArea;
        public String flatNo;
        public String unitType;
        public String CarpetArea;
        public Decimal Balcony;
        public Decimal Utility;
        public Decimal ExternalWallArea;
        public String UDS;
        public Integer SBUA;
        public String SourceID;
        public String SalesOrganization;
        public String SalesOffice;        
        public String Saletype;
        public String BasicRate;
        public String LumpSumAmount; 
        public String OrginalLumpSUmAmount; 
        public Integer CarParking;
        public String ExtraCarParking;
        public Integer ExtraCarParkingNo;
        public Integer EvCharges;
        public Integer OtherCharges;
        public String GrandTotal;        
        public String selectedCustomerType;
        public String selectedSalutation;
        public String FirstName;
        public String LastName;
        public String Gender;
        public String Organization;
        public String Designation;
        public String PassportNo;
        public String Validtill;
        public String selectedProfession;
        public String selectedSalutationr;
        public String FirstNamer;
        public String LastNamer;
        public String DateOfBirth;
        public String age;
        public String Mobile;
        public String AlternativeMobile;
        public String TelRes;
        public String TelOffice;
        public String Email;
        public String AlternativeEmail;
        public String selectedMaritalStatus;
        public String AnniversaryDate;
        public String PanNo;
        public String AadharNo;
        public Boolean SignthroughDigitalSignature;
        public String PreferredBank;
        public String presentStreet;        
        public String presentStreet2;
        public String presentStreet3;
        public String presentStreet4;
        public String presentStreet5;
        public String presentCity;
        public String selectedPresentState;
        public String selectedPresentCountry;
        public String presentPinCode;
        public String permanentStreet;
        public String permanentStreet2;
        public String permanentStreet3;
        public String permanentStreet4;
        public String permanentStreet5;
        public String permanentCity;
        public String selectedPermanentState;
        public String selectedPermanentCountry;
        public String permanentPinCode;
        public boolean SameasPresentAddress;
        public String AccountHolderName;
        public String AccountNo;
        public String NameofBank;
        public String IFSCCode;
        public String BankBranch;        
        public Decimal CampusFund;
        public Decimal AdvanceMaintenance;
        public String GSTonInstalments;
        public String StampDuty;
        public Decimal DocumentationCharges;
        public String OtherChargesIf;
        public String selectedServiceCategory;
        public String selectedProfessionDetails;
        public String selectedAnnualIncome;
        public String selectedPaymentSource;
        public String selectedPurchase;
        public String selectedOtherProject;
        public String selectedLocation;
        public String selectedLocationString;
        public String selectedRemarks;
        public String RemarksDescription;
        Public String SalesPersonEmployeeID;
        Public boolean Declaration;
        public boolean NDSORSDS;
        public String ndsValue;
        public String sdsValue;
        public boolean useScheme;
        public String selectedScheme;
        public String ExtraDiscountAmount;
        public String ndsDiscountAmount;
        public String sdsDiscountAmount;
        public boolean encash;        
        public String SchemeAmount;
        public String SourceValue;
        public String SourceExiCustomerCode;
        public String SourceExiCustomerName;
        public String SourceExiCustomerRelationName;
        public String SourceExiFlatNo;
        public String SourceExiProjectName;
        public String SourceExistCustomerDiscount;
        public String SourceChannelPartnerCode;
        public String SourceChannelPartnerName;
        public String SourceReferenceEmployeeCode;
        public String SourceEmployeeName;
        public String SourceEmployeeCompanyName;        
        public String SourceCustomerCode;
        public String SourceCustomerName;
        public String SourceCustomerRelationName;
        public String SourceFlatNo;
        public String SourceProjectName;
        public String selectedPaymentType;
        public String PaymentScheduleTotalAmount;
        public String PaymentSchedulepercentage;
        Public String SDSApprovelStatus;
        Public String SDSApprovelComments;        
        public String DiscountAmount;
        public String Discount;
        public String meterial;
        Public String OrginalBasePrice;
        Public String extraBasePrice;
         
    }

    public class OtherApplicentWp {
        public String Id;
        Public String index;
        public String Salutation1;
        public String FirstName1;
        public String LastName1;
        public String Gender1;
        public String Organization1;
        public String Occupation1;
        public String salutationr1Options;
        public String FirstNamer1;
        public String LastNamer1;
        public String DateofBirth1;
        public String age1;
        public String MaritalStatus1;
        public String AnniversaryDate1;
        public String Mobile1;
        public String Email1;
        public String PassportNo1;
        public String Validtill1;
        public String PanNo1;
        public String AadharNo1;
        public String applicantcount;   
    }

    public class PaymentScheduleWp{
        public String Id;
        public String Payment_Schedule_Type;
        public String Payment_Particulars;
        public String Amount;
        public String Amount_In_Local_Currency;
        public String SerialNumber;
    }
    
    
    Public Static Boolean IFSCCodeSAPAPi(string IFSCCODE , string NameofBank , string BankBranch, String SalesOrganization){
        Boolean Responsestatus = false;
        
        String accessToken='';
        
         if(SalesOrganization.startsWith('4')){
            accessToken = getAccessTokenSylark();
         }
        else{
           accessToken = getAccessToken();
        }
         
        system.debug('accessToken' +accessToken);
        if(accessToken <> null && accessToken <> ''){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            if(SalesOrganization.startsWith('4')){
                request.setEndpoint(Label.BookingFormIFSCCodeEndpointSkylark); // Replace with your actual endpoint
            }else{
            request.setEndpoint(Label.BookingFormIFSCCodeEndpoint); // Replace with your actual endpoint
            }
            request.setMethod('GET');
             request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setHeader('Content-Type', 'application/json'); 
            // Set the raw string body
            String jsonBody  = '{"IFSCCODE":"'+IFSCCODE+'","NameofBank":"'+NameofBank+'","BankBranch":"'+BankBranch+'"}'; // Your raw string
            system.debug('jsonBody SAP ='+jsonBody);
            request.setBody(jsonBody);
            try {
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() == 200) {
                    // Successfully got the response
                    String responseBody = response.getBody();
                    System.debug('Response Body: ' + responseBody);
                    
                    Responsestatus = true;
                    // Parse the response as needed
                    // e.g., deserialize JSON
                    // Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    
                } else {
                    System.debug('Error: ' + response.getStatus());
                    System.debug('Response Body: ' + response.getBody());
                    Responsestatus = false;
                }
            } catch (Exception e) {
                Responsestatus = false;
                System.debug('Exception: ' + e.getMessage());
            }
            
        }
         return Responsestatus;
    }
    
    
    public static String getAccessToken() {
        
        String AccessCode ;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Label.BookingFormAccessToken);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        // Set the body for the token request
        String clientId = Label.BookingFormClientId;
        String clientSecret = Label.BookingFormClientSecret;
        String body = 'grant_type=client_credentials&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') + '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8');
        request.setBody(body);
        
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            // Parse the response to get the access token
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            //return (String) result.get('access_token');
            
            AccessCode = (String) result.get('access_token');
            system.debug('AccessCode'+AccessCode);
            return AccessCode;
        } else {
            System.debug('Error: ' + response.getStatus());
            System.debug('Response Body: ' + response.getBody());
            return null;
        }        
    }
    
    public static String getAccessTokenSylark() {
        
        String AccessCode ;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Label.BookingFormAccessTokenfroSkylark);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        // Set the body for the token request
        String clientId = Label.BookingFormClientIdforSkylark;
        String clientSecret = Label.BookingFormClientSecretforSkylark;
        String body = 'grant_type=client_credentials&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') + '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8');
        request.setBody(body);
        
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            // Parse the response to get the access token
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            //return (String) result.get('access_token');
            
            AccessCode = (String) result.get('access_token');
            system.debug('AccessCode'+AccessCode);
            return AccessCode;
        } else {
            System.debug('Error: ' + response.getStatus());
            System.debug('Response Body: ' + response.getBody());
            return null;
        }        
    }
}