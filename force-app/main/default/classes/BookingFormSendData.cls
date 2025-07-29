public class BookingFormSendData {
    
    @future(callout=true)
    public static void processBookingForm(Id bookingFormId) {
        // Query Booking_Form__c
        Booking_Form__c bookingForm = [
            SELECT Aadhar__c, Account_Name__c, Account_No__c, Address__c, Advance_Maintenance__c, Age__c, 
            Alt_Unit_Measurement__c, Alternative_Email__c, Alternative_Mobile__c, AMOUNT__c, Anniversary_Date__c, 
            Annual_Income__c, Approvals__c, Area_in_Sqft__c, Balcony__c, Bank_Branch__c, Basic_Price__c, Block__c, 
            BookigFormUniqId__c, Booking_Form_Grand_Total__c, Booking_Form_Status__c, BookingSource__c, Car_Parking__c,
            Car_Parking_Charges__c, Carper_Area__c, Carpet_Area__c, Channel_Partner_Code__c, Channel_Partner_Name__c, 
            City__c, City2__c, Company_Name__c, Corpus_Fund__c, Country__c, Country2__c, Customer_Code__c, Customer_Name__c,
            Customer_Type__c, Declaration__c, Designation__c, Developer_Details__c, Discount_Amount__c, DOB__c, 
            Doc_Charges__c, Email__c, encash__c, EnCash_Amount__c, EV_Charges__c, Exist_Customer_Discount__c, 
            External_Wall_Area__c,  Extra_Base_Price_Discount__c, Extra_Car_Parking__c, Extra_Car_Parking_Charges__c, Extra_Discount_Amount__c, 
            Facing__c, First_Name__c, First_Namer__c, Flat_No__c, Gender__c, GST_NO__c, GST_on_Instalments__c, Id, 
            IFSC_Code__c, isBookingFormEmailSent__c, IsDeleted, Know_about_us__c, Last_Name__c, Last_Namer__c, 
            Location_of_Intrest__c, Loyalty_Bonus__c, Lump_Sum_Amount__c, LumpSumAmount2__c, Mail_validity__c, 
            Marital_Status__c, Mobile__c, Name, Name_of_Bank__c, nds_Discount_Amount__c, NDS_or_SDS__c, 
            NDS_per_sft__c, Occupation1__c, Occupation2__c, Opportunity__c, Organization__c, 
            Orginal_Base_Price__c, OrginalLumpSUmAmount__c, Other_Charges__c, Other_Charges_If__c, 
            Other_Projects__c, Pan_No__c, Passport_No__c, Payment_Sc_Total__c, Payment_Schedule__c, 
            Payment_Schedule_percentage__c, Payment_Schedule_Type__c, Payment_Schedules__c, Payment_source__c, 
            Payment_Type__c, Phonevalidity__c, Pin_Code__c, Pin_Code2__c, Product2__c, Profession__c, 
            Professional_Details__c, Professional_Details_Code__c, Project_Meterial__c, Project_Name__c, Purchase_of_Purpose__c, 
            Reference_Employee_Code__c, Remarks_Description__c, RERA_NO__c, richtext__c, Sale_Type__c, Sales_Office__c, Sales_Organization__c,
            Sales_PersonID__c, Salutation__c, Salutationr__c, Salutationr1__c, Same_as_Present_Address__c, SBUA__c, 
            Scheme_Discount_Amount__c, Schemes__c, SchemesName__c, SDS_Approvel_Comments__c, SDS_Approvel_Status__c,
            sds_Discount_Amount__c, SDS_per_sft__c, Select_Remarks__c, Select_Schemes__c, Service_Category__c,
            Source_Employee_Company_Name__c, Source_Employee_Name__c, Source_Flat_No__c, Source_Project__c, Source_Id__c,
            Source_Project_Name__c, Stamp_Duty_Fee__c, State__c, State2__c, Street_2__c, Street_21__c, Street_3__c, 
            Street_31__c, Street_4__c, Street_41__c, Street_5__c, Street_51__c, StreetHouse_No__c, StreetHouse_No2__c, 
            TelOffice__c, TelRes__c, Total_Car_Parking_Charges__c, Total_Parkings_Count__c, Towers__c, UDS__c, Unit__c,
            Unit_Type__c, Use_Scheme__c, Utility__c, Exist_Customer_Code__c, Exist_Customer_Name__c, Exist_Customer_Relation__c, 
            Exist_Customer_Flat_No__c, Exist_Customer_Project_Name__c, Nature_of_Work__c, CreatedDate, 
            LastModifiedDate, Salutationr_Code__c,Salutation_Code__c,Marital_Status_Code__c, Final_Basic_Price__c,
            Gender_Code__c, Country_Code__c, Country_Code2__c, Sales_Employee_Name__c, Valid_till__c
            FROM Booking_Form__c 
            WHERE Id = :bookingFormId LIMIT 1
        ];
        List<Booking_Form_Line_Items__c> lineItems = [SELECT Agreement_Value__c, Amount__c, Booking_Form__c, CreatedById, CreatedDate, Id, 
                                                      IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate,
                                                      LastReferencedDate, LastViewedDate, Name, OwnerId, 
                                                      Payment_Particulars__c, Payment_Schedule_Type__c, S_No__c
                                                      FROM Booking_Form_Line_Items__c WHERE Booking_Form__c = :bookingForm.Id];
        List<Other_Applicants__c> otherApplicants = [SELECT Aadhar_No__c, applicent_Number__c, Age__c, Anniversary_Date__c, Booking_Form__c, 
                                                     Date_of_Birth__c, Email__c, First_Name__c, 
                                                     First_Namer__c, Gender__c, Id, Last_Name__c, Last_Namer__c,CreatedDate,LastModifiedDate,
                                                     Marital_Status__c, Mobile__c, Name, Occupation__c, Occupation_Code__c, Organization__c, 
                                                     Pan_No__c, Passport_No__c, RSalutation__c, Salutation__c,Salutation_Code__c,
                                                     RSalutation_Code__c,Marital_Status_Code__c,Gender_Code__c,
                                                     Valid_till__c FROM Other_Applicants__c WHERE Booking_Form__c = :bookingForm.Id];      
        
        // Prepare the payload
        Map<String, Object> payload = new Map<String, Object>();
        Map<String, Object> bookingFormData = new Map<String, Object>();
        
        // Add parent object fields to payload
        bookingFormData.put('Aadhar__c', bookingForm.Aadhar__c);
        bookingFormData.put('Account_Name__c', bookingForm.Account_Name__c);
        bookingFormData.put('Account_No__c', bookingForm.Account_No__c);
        //bookingFormData.put('Address__c', bookingForm.Address__c);
        bookingFormData.put('Advance_Maintenance__c', bookingForm.Advance_Maintenance__c);
        bookingFormData.put('Age__c', bookingForm.Age__c);
        bookingFormData.put('Alt_Unit_Measurement__c', bookingForm.Alt_Unit_Measurement__c);
        bookingFormData.put('Alternative_Email__c', bookingForm.Alternative_Email__c);
        bookingFormData.put('Alternative_Mobile__c', bookingForm.Alternative_Mobile__c);
        bookingFormData.put('AMOUNT__c', bookingForm.AMOUNT__c);
        bookingFormData.put('Anniversary_Date__c', bookingForm.Anniversary_Date__c);
        bookingFormData.put('Annual_Income__c', bookingForm.Annual_Income__c);
        //bookingFormData.put('Approvals__c', bookingForm.Approvals__c);
        bookingFormData.put('Area_in_Sqft__c', bookingForm.Area_in_Sqft__c);
        bookingFormData.put('Balcony__c', bookingForm.Balcony__c);
        bookingFormData.put('Bank_Branch__c', bookingForm.Bank_Branch__c);
        bookingFormData.put('Basic_Price__c', bookingForm.Basic_Price__c);
        //bookingFormData.put('Orginal_Base_Price__c', bookingForm.Orginal_Base_Price__c);
        bookingFormData.put('Final_Basic_Price__c', bookingForm.Final_Basic_Price__c);
        bookingFormData.put('Block__c', bookingForm.Block__c);
        bookingFormData.put('BookigFormUniqId__c', bookingForm.BookigFormUniqId__c);
        bookingFormData.put('Booking_Form_Grand_Total__c', bookingForm.Booking_Form_Grand_Total__c);
        bookingFormData.put('Booking_Form_Status__c', bookingForm.Booking_Form_Status__c);
        bookingFormData.put('BookingSource__c', bookingForm.BookingSource__c);
        bookingFormData.put('Car_Parking__c', bookingForm.Car_Parking__c);
        bookingFormData.put('Car_Parking_Charges__c', bookingForm.Car_Parking_Charges__c);
        //bookingFormData.put('Carper_Area__c', bookingForm.Carper_Area__c);
        bookingFormData.put('Carpet_Area__c', bookingForm.Carpet_Area__c);
        bookingFormData.put('Channel_Partner_Code__c', bookingForm.Channel_Partner_Code__c);
        bookingFormData.put('Channel_Partner_Name__c', bookingForm.Channel_Partner_Name__c);
        bookingFormData.put('City__c', bookingForm.City__c);
        bookingFormData.put('City2__c', bookingForm.City2__c);
        bookingFormData.put('Company_Name__c', bookingForm.Company_Name__c);
        bookingFormData.put('Corpus_Fund__c', bookingForm.Corpus_Fund__c);
        bookingFormData.put('Country__c', bookingForm.Country__c);
        bookingFormData.put('Country_Code__c', bookingForm.Country_Code__c);
        bookingFormData.put('Country2__c', bookingForm.Country2__c);
        bookingFormData.put('Country_Code2__c', bookingForm.Country_Code2__c);
        bookingFormData.put('Customer_Code__c', bookingForm.Customer_Code__c);
        bookingFormData.put('Customer_Name__c', bookingForm.Customer_Name__c);
        bookingFormData.put('Customer_Type__c', bookingForm.Customer_Type__c);
        bookingFormData.put('Declaration__c', bookingForm.Declaration__c);
        bookingFormData.put('Designation__c', bookingForm.Designation__c);
        //bookingFormData.put('Developer_Details__c', bookingForm.Developer_Details__c);
        bookingFormData.put('Discount_Amount__c', bookingForm.Discount_Amount__c);
        bookingFormData.put('DOB__c', bookingForm.DOB__c);
        bookingFormData.put('Doc_Charges__c', bookingForm.Doc_Charges__c);
        bookingFormData.put('Email__c', bookingForm.Email__c);
        //bookingFormData.put('encash__c', bookingForm.encash__c);
        bookingFormData.put('EnCash_Amount__c', bookingForm.EnCash_Amount__c);
        bookingFormData.put('EV_Charges__c', bookingForm.EV_Charges__c);
        bookingFormData.put('Exist_Customer_Code__c', bookingForm.Exist_Customer_Code__c);
        bookingFormData.put('Exist_Customer_Name__c', bookingForm.Exist_Customer_Name__c);
        bookingFormData.put('Exist_Customer_Relation__c', bookingForm.Exist_Customer_Relation__c);
        bookingFormData.put('Exist_Customer_Flat_No__c', bookingForm.Exist_Customer_Flat_No__c);
        bookingFormData.put('Exist_Customer_Project_Name__c', bookingForm.Exist_Customer_Project_Name__c);
        bookingFormData.put('Exist_Customer_Discount__c', bookingForm.Exist_Customer_Discount__c);
        bookingFormData.put('External_Wall_Area__c', bookingForm.External_Wall_Area__c);
        bookingFormData.put('Extra_Base_Price_Discount__c', bookingForm.Extra_Base_Price_Discount__c);
        bookingFormData.put('Extra_Car_Parking__c', bookingForm.Extra_Car_Parking__c);
        bookingFormData.put('Extra_Car_Parking_Charges__c', bookingForm.Extra_Car_Parking_Charges__c);
        bookingFormData.put('Extra_Discount_Amount__c', bookingForm.Extra_Discount_Amount__c);
        bookingFormData.put('Facing__c', bookingForm.Facing__c);
        bookingFormData.put('First_Name__c', bookingForm.First_Name__c);
        bookingFormData.put('First_Namer__c', bookingForm.First_Namer__c);
        //bookingFormData.put('Flat_No__c', bookingForm.Flat_No__c);
        bookingFormData.put('Gender__c', bookingForm.Gender__c);
        bookingFormData.put('Gender_Code__c', bookingForm.Gender_Code__c);
        //bookingFormData.put('GST_NO__c', bookingForm.GST_NO__c);
        bookingFormData.put('GST_on_Instalments__c', bookingForm.GST_on_Instalments__c);
        bookingFormData.put('Id', bookingForm.Id);
        bookingFormData.put('IFSC_Code__c', bookingForm.IFSC_Code__c);
        //bookingFormData.put('isBookingFormEmailSent__c', bookingForm.isBookingFormEmailSent__c);
        //bookingFormData.put('IsDeleted', bookingForm.IsDeleted);
        //bookingFormData.put('Know_about_us__c', bookingForm.Know_about_us__c);
        bookingFormData.put('Last_Name__c', bookingForm.Last_Name__c);
        bookingFormData.put('Last_Namer__c', bookingForm.Last_Namer__c);
        bookingFormData.put('Location_of_Intrest__c', bookingForm.Location_of_Intrest__c);
        bookingFormData.put('Loyalty_Bonus__c', bookingForm.Loyalty_Bonus__c);
        bookingFormData.put('Lump_Sum_Amount__c', bookingForm.Lump_Sum_Amount__c);
        //bookingFormData.put('LumpSumAmount2__c', bookingForm.LumpSumAmount2__c);
        //bookingFormData.put('Mail_validity__c', bookingForm.Mail_validity__c);
        bookingFormData.put('Marital_Status__c', bookingForm.Marital_Status__c);
        bookingFormData.put('Marital_Status_Code__c', bookingForm.Marital_Status_Code__c);
        bookingFormData.put('Mobile__c', bookingForm.Mobile__c);
        bookingFormData.put('Name', bookingForm.Name);
        bookingFormData.put('Nature_of_Work__c', bookingForm.Nature_of_Work__c);
        bookingFormData.put('Name_of_Bank__c', bookingForm.Name_of_Bank__c);
        bookingFormData.put('nds_Discount_Amount__c', bookingForm.nds_Discount_Amount__c);
        //bookingFormData.put('NDS_or_SDS__c', bookingForm.NDS_or_SDS__c);
        bookingFormData.put('NDS_per_sft__c', bookingForm.NDS_per_sft__c);
        //bookingFormData.put('Occupation1__c', bookingForm.Occupation1__c);
        //bookingFormData.put('Occupation2__c', bookingForm.Occupation2__c);
        bookingFormData.put('Opportunity__c', bookingForm.Opportunity__c);
        bookingFormData.put('Organization__c', bookingForm.Organization__c);
        bookingFormData.put('OrginalLumpSUmAmount__c', bookingForm.OrginalLumpSUmAmount__c);
        bookingFormData.put('Other_Charges__c', bookingForm.Other_Charges__c);
        bookingFormData.put('Other_Charges_If__c', bookingForm.Other_Charges_If__c);
        bookingFormData.put('Other_Projects__c', bookingForm.Other_Projects__c);
        bookingFormData.put('Pan_No__c', bookingForm.Pan_No__c);
        bookingFormData.put('Passport_No__c', bookingForm.Passport_No__c);
        bookingFormData.put('Payment_Sc_Total__c', bookingForm.Payment_Sc_Total__c);
        //bookingFormData.put('Payment_Schedule__c', bookingForm.Payment_Schedule__c);
        bookingFormData.put('Payment_Schedule_percentage__c', bookingForm.Payment_Schedule_percentage__c);
        bookingFormData.put('Payment_Schedule_Type__c', bookingForm.Payment_Schedule_Type__c);
        //bookingFormData.put('Payment_Schedules__c', bookingForm.Payment_Schedules__c);
        bookingFormData.put('Payment_source__c', bookingForm.Payment_source__c);
        bookingFormData.put('Payment_Type__c', bookingForm.Payment_Type__c);
        //bookingFormData.put('Phonevalidity__c', bookingForm.Phonevalidity__c);
        bookingFormData.put('Pin_Code__c', bookingForm.Pin_Code__c);
        bookingFormData.put('Pin_Code2__c', bookingForm.Pin_Code2__c);
        bookingFormData.put('Product2__c', bookingForm.Product2__c);
        bookingFormData.put('Profession__c', bookingForm.Profession__c);
        bookingFormData.put('Professional_Details__c', bookingForm.Professional_Details__c);
        bookingFormData.put('Professional_Details_Code__c', bookingForm.Professional_Details_Code__c);
        bookingFormData.put('Project_Meterial__c', bookingForm.Project_Meterial__c);
        bookingFormData.put('Project_Name__c', bookingForm.Project_Name__c);
        bookingFormData.put('Purchase_of_Purpose__c', bookingForm.Purchase_of_Purpose__c);
        bookingFormData.put('Reference_Employee_Code__c', bookingForm.Reference_Employee_Code__c);
        bookingFormData.put('Remarks_Description__c', bookingForm.Remarks_Description__c);
        //bookingFormData.put('RERA_NO__c', bookingForm.RERA_NO__c);
        //bookingFormData.put('richtext__c', bookingForm.richtext__c);
        bookingFormData.put('Sale_Type__c', bookingForm.Sale_Type__c);
        bookingFormData.put('Sales_Office__c', bookingForm.Sales_Office__c);
        bookingFormData.put('Sales_Organization__c', bookingForm.Sales_Organization__c);
        bookingFormData.put('Sales_PersonID__c', bookingForm.Sales_PersonID__c);
        bookingFormData.put('Sales_Employee_Name__c', bookingForm.Sales_Employee_Name__c);
        bookingFormData.put('Salutation__c', bookingForm.Salutation__c);
        bookingFormData.put('Salutation_Code__c', bookingForm.Salutation_Code__c);
        bookingFormData.put('Salutationr__c', bookingForm.Salutationr__c);
        bookingFormData.put('Salutationr_Code__c', bookingForm.Salutationr_Code__c);
        bookingFormData.put('Salutationr1__c', bookingForm.Salutationr1__c);
        //bookingFormData.put('Same_as_Present_Address__c', bookingForm.Same_as_Present_Address__c);
        bookingFormData.put('SBUA__c', bookingForm.SBUA__c);
        bookingFormData.put('Scheme_Discount_Amount__c', bookingForm.Scheme_Discount_Amount__c);
        //bookingFormData.put('Schemes__c', bookingForm.Schemes__c);
        bookingFormData.put('SchemesName__c', bookingForm.SchemesName__c);
        //bookingFormData.put('SDS_Approvel_Comments__c', bookingForm.SDS_Approvel_Comments__c);
        bookingFormData.put('SDS_Approvel_Status__c', bookingForm.SDS_Approvel_Status__c);
        bookingFormData.put('sds_Discount_Amount__c', bookingForm.sds_Discount_Amount__c);
        bookingFormData.put('SDS_per_sft__c', bookingForm.SDS_per_sft__c);
        bookingFormData.put('Select_Remarks__c', bookingForm.Select_Remarks__c);
        //bookingFormData.put('Select_Schemes__c', bookingForm.Select_Schemes__c);
        bookingFormData.put('Service_Category__c', bookingForm.Service_Category__c);
        bookingFormData.put('Source_Employee_Company_Name__c', bookingForm.Source_Employee_Company_Name__c);
        bookingFormData.put('Source_Employee_Name__c', bookingForm.Source_Employee_Name__c);
        bookingFormData.put('Source_Flat_No__c', bookingForm.Source_Flat_No__c);
        bookingFormData.put('Source_Project__c', bookingForm.Source_Project__c);
        bookingFormData.put('Source_Project_Name__c', bookingForm.Source_Project_Name__c);
        bookingFormData.put('Source_Id__c', bookingForm.Source_Id__c);
        bookingFormData.put('Stamp_Duty_Fee__c', bookingForm.Stamp_Duty_Fee__c);
        bookingFormData.put('State__c', bookingForm.State__c);
        bookingFormData.put('State2__c', bookingForm.State2__c);
        bookingFormData.put('Street_2__c', bookingForm.Street_2__c);
        bookingFormData.put('Street_21__c', bookingForm.Street_21__c);
        bookingFormData.put('Street_3__c', bookingForm.Street_3__c);
        bookingFormData.put('Street_31__c', bookingForm.Street_31__c);
        bookingFormData.put('Street_4__c', bookingForm.Street_4__c);
        bookingFormData.put('Street_41__c', bookingForm.Street_41__c);
        bookingFormData.put('Street_5__c', bookingForm.Street_5__c);
        bookingFormData.put('Street_51__c', bookingForm.Street_51__c);
        bookingFormData.put('StreetHouse_No__c', bookingForm.StreetHouse_No__c);
        bookingFormData.put('StreetHouse_No2__c', bookingForm.StreetHouse_No2__c);
        bookingFormData.put('TelOffice__c', bookingForm.TelOffice__c);
        bookingFormData.put('TelRes__c', bookingForm.TelRes__c);
        bookingFormData.put('Total_Car_Parking_Charges__c', bookingForm.Total_Car_Parking_Charges__c);
        bookingFormData.put('Total_Parkings_Count__c', bookingForm.Total_Parkings_Count__c);
        bookingFormData.put('Towers__c', bookingForm.Towers__c);
        bookingFormData.put('UDS__c', bookingForm.UDS__c);
        bookingFormData.put('Unit__c', bookingForm.Unit__c);
        bookingFormData.put('Unit_Type__c', bookingForm.Unit_Type__c);
        bookingFormData.put('Use_Scheme__c', bookingForm.Use_Scheme__c);
        bookingFormData.put('Utility__c', bookingForm.Utility__c);
        bookingFormData.put('CreatedDate', bookingForm.CreatedDate);
        bookingFormData.put('LastModifiedDate', bookingForm.LastModifiedDate);
        bookingFormData.put('Valid_till__c', bookingForm.Valid_till__c);
        
        // Add child objects data to payload
        
        List<Map<String, Object>> lineItemsData = new List<Map<String, Object>>();
        for (Booking_Form_Line_Items__c item : lineItems) {
            Map<String, Object> itemData = new Map<String, Object>();
            itemData.put('Id', item.Id);
            itemData.put('Agreement_Value__c', item.Agreement_Value__c);
            itemData.put('Amount__c', item.Amount__c);
            itemData.put('Booking_Form__c', item.Booking_Form__c);
            //itemData.put('CreatedById', item.CreatedById);
            itemData.put('CreatedDate', item.CreatedDate);
            //itemData.put('LastModifiedById', item.LastModifiedById);
            itemData.put('LastModifiedDate', item.LastModifiedDate);
            itemData.put('Name', item.Name);
            itemData.put('OwnerId', item.OwnerId);
            itemData.put('Payment_Particulars__c', item.Payment_Particulars__c);
            itemData.put('Payment_Schedule_Type__c', item.Payment_Schedule_Type__c);
            itemData.put('S_No__c', item.S_No__c);
            lineItemsData.add(itemData);
        }
        System.debug('lineItems: ' + lineItemsData);
        System.debug('lineItems: ' + lineItemsData.size());
        bookingFormData.put('LineItems', lineItemsData);      
        
        List<Map<String, Object>> otherApplicantsData = new List<Map<String, Object>>();
        for (Other_Applicants__c applicant : otherApplicants) {
            Map<String, Object> applicantData = new Map<String, Object>();
            applicantData.put('Id', applicant.Id);
            applicantData.put('Aadhar_No__c', applicant.Aadhar_No__c);
            applicantData.put('applicent_Number__c', applicant.applicent_Number__c);
            applicantData.put('Age__c', applicant.Age__c);
            applicantData.put('LastModifiedDate', applicant.LastModifiedDate);
            applicantData.put('CreatedDate', applicant.CreatedDate);
            applicantData.put('Anniversary_Date__c', applicant.Anniversary_Date__c);
            applicantData.put('Booking_Form__c', applicant.Booking_Form__c);
            applicantData.put('Date_of_Birth__c', applicant.Date_of_Birth__c);
            applicantData.put('Email__c', applicant.Email__c);
            applicantData.put('First_Name__c', applicant.First_Name__c);
            applicantData.put('First_Namer__c', applicant.First_Namer__c);
            applicantData.put('Gender__c', applicant.Gender__c);
            applicantData.put('Gender_Code__c', applicant.Gender_Code__c);
            applicantData.put('Last_Name__c', applicant.Last_Name__c);
            applicantData.put('Last_Namer__c', applicant.Last_Namer__c);
            applicantData.put('Marital_Status__c', applicant.Marital_Status__c);
            applicantData.put('Marital_Status_Code__c', applicant.Marital_Status_Code__c);
            applicantData.put('Mobile__c', applicant.Mobile__c);
            applicantData.put('Name', applicant.Name);
            applicantData.put('Occupation__c', applicant.Occupation__c);
            applicantData.put('Occupation_Code__c', applicant.Occupation_Code__c);
            applicantData.put('Organization__c', applicant.Organization__c);
            applicantData.put('Pan_No__c', applicant.Pan_No__c);
            applicantData.put('Passport_No__c', applicant.Passport_No__c);
            applicantData.put('Salutation__c', applicant.Salutation__c);
            applicantData.put('Salutation_Code__c', applicant.Salutation_Code__c);
            applicantData.put('RSalutation__c', applicant.RSalutation__c);
            applicantData.put('RSalutation_Code__c', applicant.RSalutation_Code__c);
            applicantData.put('Valid_till__c', applicant.Valid_till__c);
            otherApplicantsData.add(applicantData);
        }
        System.debug('otherApplicantsData: ' + otherApplicantsData);
     	System.debug('otherApplicantsData: ' + otherApplicantsData.size());
        bookingFormData.put('OtherApplicants', otherApplicantsData);
        System.debug('otherApplicantsData: ' + otherApplicantsData);
     	System.debug('otherApplicantsData: ' + otherApplicantsData.size());
        
        
        System.debug('Payload Booking Form Data: ' + JSON.serialize(bookingFormData));
     	System.debug('Payload Booking Form Data Size: ' + bookingFormData.size());
        
        // Add data to payload
        payload.put('BookingForm', bookingFormData);
       
        // Convert payload to JSON
        String jsonPayload = JSON.serialize(payload);
        System.debug('JSON LOAD');
        String accessToken='';
        
         if(bookingForm.Sales_Organization__c.startsWith('4')){
            accessToken = getAccessTokenSylark();
         }
        else{
           accessToken = getAccessToken();
        }
        
        Boolean responseStatus = false;
        if (accessToken <> null && accessToken <> '') {         
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            if(bookingForm.Sales_Organization__c.startsWith('4')){
                request.setEndpoint(Label.BookingFormSendDataEndpointSkylark);
            }else{
            request.setEndpoint(Label.BookingFormSendDataEndpoint); 
            }
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(jsonPayload);
            
            try {
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() == 200) {
                    // Successfully got the response
                    String responseBody = response.getBody();
                    System.debug('Response Body: ' + responseBody);
                    responseStatus = true;
                     System.debug(response.getBody());
                } else {
                    System.debug('Error: ' + response.getStatusCode());
                    System.debug('Response Body: ' + response.getBody());
                    System.debug(response.getBody());
                }
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }
        } else {
            System.debug('Access Token is null or empty');
        }
        
        // Handle and log response status
        System.debug('Response Status: ' + responseStatus);
    }
    //for Ramky
    public static String getAccessToken() {
        String accessToken;
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
        
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                // Parse the response to get the access token
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                accessToken = (String) result.get('access_token');
                System.debug('Access Token: ' + accessToken);
                return accessToken;
            } else {
                System.debug('Error: ' + response.getStatusCode());
                System.debug('Response Body: ' + response.getBody());
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception in getting Access Token: ' + e.getMessage());
            return null;
        }
    }
    
    //for Skylark
    public static String getAccessTokenSylark() {
        String accessToken;
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
        
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                // Parse the response to get the access token
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                accessToken = (String) result.get('access_token');
                System.debug('Access Token: ' + accessToken);
                return accessToken;
            } else {
                System.debug('Error: ' + response.getStatusCode());
                System.debug('Response Body: ' + response.getBody());
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception in getting Access Token: ' + e.getMessage());
            return null;
        }
    }
    
    
}