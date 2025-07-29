public class BookingFormPDF {
    public Id bookingFormId { get; set; }
    public User currentUser { get; set; }
    public List<Booking_Form__c> bookingList { get; set; }
    public List<Booking_Form_Line_Items__c> bsli { get; set; }
    public List<Other_Applicants__c> OtherApplicants { get; set; }
    public List<Ramky_Account_Details__c> RamkyACC { get; set; }
    public Integer currentPageIndex { get; set; }
    public String amountInWords { get; set; }
    public Integer totalPages { get; set; }
    
    public BookingFormPDF(ApexPages.StandardController controller) {
        bookingFormId = controller.getId();
        fetchCurrentUser();
        
        // Query Booking_Form__c records
        bookingList = [
            SELECT Id, Aadhar__c, Account_Name__c, Account_No__c, Address__c, Advance_Maintenance__c, Age__c, 
            Alt_Unit_Measurement__c, Alternative_Email__c, Alternative_Mobile__c, AMOUNT__c, Anniversary_Date__c, 
            Annual_Income__c, Approvals__c, Area_in_Sqft__c, Balcony__c, Bank_Branch__c, Basic_Price__c, Block__c, 
            Booking_Form_Grand_Total__c, Booking_Form_Status__c, BookingSource__c, Car_Parking__c, Car_Parking_Charges__c, 
            Carper_Area__c, Carpet_Area__c, Channel_Partner_Code__c, Channel_Partner_Name__c, City__c, City2__c, 
            Company_Name__c, Corpus_Fund__c, Country__c, Country2__c, CreatedById, CreatedDate, Customer_Code__c,
            Customer_Name__c, Customer_Type__c, Declaration__c, Designation__c, Developer_Details__c, 
            Discount_Amount__c, DOB__c, Doc_Charges__c, Email__c, encash__c, EnCash_Amount__c, EV_Charges__c, 
            Exist_Customer_Discount__c, Total_Car_Parking_Charges__c, External_Wall_Area__c, Extra_Base_Price_Discount__c, Extra_Car_Parking_Charges__c,
            Extra_Car_Parking__c, Extra_Discount_Amount__c, Facing__c, First_Name__c, First_Namer__c, Flat_No__c, Gender__c, GST_NO__c, 
            GST_on_Instalments__c, IFSC_Code__c, IsDeleted, Know_about_us__c, Last_Name__c, Last_Namer__c,
            Location_of_Intrest__c, Loyalty_Bonus__c, Lump_Sum_Amount__c, Mail_validity__c, Marital_Status__c, Mobile__c, 
            Name, Name_of_Bank__c, nds_Discount_Amount__c, NDS_or_SDS__c, NDS_per_sft__c, Note__c, Occupation1__c, 
            Occupation2__c, Opportunity__c, Organization__c, Orginal_Base_Price__c, Other_Charges__c, 
            Other_Charges_If__c, Other_Projects__c, OwnerId, Record_Owner__c, Pan_No__c, Passport_No__c, Payment_Sc_Total__c, 
            Payment_Schedule__c, Payment_Schedule_percentage__c, Payment_Schedule_Type__c, Payment_Schedules__c, 
            Payment_source__c, Payment_Type__c, Phonevalidity__c, Pin_Code__c, Pin_Code2__c, Product2__c, Profession__c, 
            Professional_Details__c, Project_Meterial__c, Project_Name__c, Purchase_of_Purpose__c, Reference_Employee_Code__c, 
            Remarks_Description__c, RERA_NO__c, richtext__c, Sale_Type__c, Sales_PersonID__c, Salutation__c, 
            Salutationr__c, Salutationr1__c, Same_as_Present_Address__c, SBUA__c, Scheme_Discount_Amount__c, 
            Schemes__c, SchemesName__c, SDS_Approvel_Comments__c, SDS_Approvel_Status__c, sds_Discount_Amount__c, 
            SDS_per_sft__c, Select_Remarks__c, Select_Schemes__c, Service_Category__c, Source_Employee_Company_Name__c, 
            Source_Employee_Name__c, Source_Flat_No__c, Total_Parkings_Count__c,Source_Project__c, Source_Project_Name__c, Stamp_Duty_Fee__c, 
            State__c, State2__c, Street_2__c, Street_21__c, Street_3__c, Street_31__c, Street_4__c, Street_41__c, 
            Street_5__c, Street_51__c, StreetHouse_No__c, StreetHouse_No2__c, SystemModstamp, TelOffice__c, TelRes__c, 
            Towers__c, UDS__c, Unit__c, Unit_Type__c, Use_Scheme__c, Utility__c, Valid_till__c
            FROM Booking_Form__c 
            WHERE Id = :bookingFormId
        ];
        
        if (!bookingList.isEmpty()) {
            amountInWords = AmountToWords(bookingList[0].Booking_Form_Grand_Total__c);
            
            // Fetch Ramky_Account_Details__c records based on Project_Name__c
            RamkyACC = [
                SELECT Account_No__c, Bank_Address__c, Bank_Name__c, BF_Transfer_Fees__c, Company_Address__c, External_ID__c,
                GST_No__c, Id, IFSC_Code__c, Name, Pan_No__c, Project_Name__c, RERA_No__c, Sales_Office__c, 
                Sales_Organization__c,State__c
                FROM Ramky_Account_Details__c 
                WHERE Project_Name__c = :bookingList[0].Project_Name__c
            ];
        }
        
        // Set total pages and initialize currentPageIndex
        totalPages = bookingList.size();
        currentPageIndex = 0;
        
        // Query Booking_Form_Line_Items__c records related to bookingList
        Set<Id> bookingFormIds = new Set<Id>();
        for (Booking_Form__c bookingFormRecord : bookingList) {
            bookingFormIds.add(bookingFormRecord.Id);
        }
        
        bsli = [
            SELECT Id, Agreement_Value__c, Amount__c, Booking_Form__c, Payment_Particulars__c, Payment_Schedule_Type__c
            FROM Booking_Form_Line_Items__c
            WHERE Booking_Form__c IN :bookingFormIds 
            ORDER BY S_No__c ASC
        ];
        
        // Query multiple Other_Applicants__c records related to the booking form
        OtherApplicants = [SELECT Id, Aadhar_No__c, Age__c, Anniversary_Date__c, applicent_Number__c, Booking_Form__c, 
                           Date_of_Birth__c, Email__c, First_Name__c, First_Namer__c, Gender__c, Gender_Code__c, 
                           Last_Name__c, Last_Namer__c, Marital_Status__c, Marital_Status_Code__c, Mobile__c, Occupation__c, 
                           Occupation_Code__c, Organization__c, Pan_No__c, Passport_No__c, RSalutation__c, RSalutation_Code__c, 
                           Salutation__c, Salutation_Code__c, Valid_till__c FROM Other_Applicants__c 
                           WHERE Booking_Form__c IN :bookingFormIds ORDER BY applicent_Number__c ASC ];
        
    }
    
    private void fetchCurrentUser() {
        currentUser = [
            SELECT Id, FirstName, LastName, Name 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ];
    }
    
    public static String AmountToWords(Decimal GrandTotal) {
        String amountInWords = '';
        
        // Check if GrandTotal is not null
        if (GrandTotal != null) {
            // If GrandTotal is 0, return "zero rupees only"
            if (GrandTotal == 0) {
                amountInWords = 'zero rupees only';
            } else {
                // Convert non-zero values to words
                amountInWords = numberToWords(GrandTotal) + ' rupees only';
            }
        } else {
            // Handle null case
            amountInWords = 'Amount not available';
        }
        
        System.debug('amountInWords: ' + amountInWords);
        return amountInWords;
    }
    
    
    public static String numberToWords(Decimal amount) {
        List<String> units = new List<String>{'', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'};
            List<String> teens = new List<String>{'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'};
                List<String> tens = new List<String>{'', 'ten', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'};
                    List<String> thousands = new List<String>{'', 'thousand', 'lakh', 'crore'};
                        
                        Integer num = amount.intValue();
        String words = '';
        Integer i = 0;
        
        while (num > 0) {
            Integer part;
            if (i == 0) {
                part = Math.mod(num, 1000);
                num = num / 1000;
            } else if (i == 1) {
                part = Math.mod(num, 100);
                num = num / 100;
            } else {
                part = Math.mod(num, 100);
                num = num / 100;
            }
            
            if (part > 0) {
                String partInWords = convertThreeDigits(part, units, teens, tens);
                words = partInWords + ' ' + thousands[i] + ' ' + words;
            }
            i++;
        }
        
        return words.trim();
    }
    
    private static String convertThreeDigits(Integer num, List<String> units, List<String> teens, List<String> tens) {
        String words = '';
        
        if (num >= 100) {
            words += units[num / 100] + ' hundred ';
            num = Math.mod(num, 100);
        }
        
        if (num >= 11 && num <= 19) {
            words += teens[num - 11] + ' ';
        } else {
            words += tens[num / 10] + ' ';
            words += units[Math.mod(num, 10)] + ' ';
        }
        
        return words.trim();
    }
    
    public Booking_Form__c getCurrentReport() {
        if (currentPageIndex >= 0 && currentPageIndex < bookingList.size()) {
            return bookingList[currentPageIndex];
        }
        return null;
    }
    
    public PageReference next() {
        if (currentPageIndex < totalPages - 1) {
            currentPageIndex++;
        }
        return null;
    }
    
    public List<BookingFormLineItemWrapper> getFormattedBookingFormLineItems() {
        List<BookingFormLineItemWrapper> formattedItems = new List<BookingFormLineItemWrapper>();
        if (bsli != null && bsli.size() > 0) {
            for (Booking_Form_Line_Items__c item : bsli) {
                BookingFormLineItemWrapper wrapper = new BookingFormLineItemWrapper();
                wrapper.Id = item.Id;
                wrapper.AgreementValue = item.Agreement_Value__c;
                wrapper.FormattedAmount = formatIndianCurrency(item.Amount__c);
                wrapper.BookingFormId = item.Booking_Form__c;
                wrapper.PaymentParticulars = item.Payment_Particulars__c;
                wrapper.PaymentScheduleType = item.Payment_Schedule_Type__c;
                formattedItems.add(wrapper);
            }
        }
        return formattedItems;
    }
    
    public String formatIndianCurrency(Decimal amount) {
        if (amount == null) return 'N/A';
        String formattedAmount = amount.setScale(2).format();
        if (!formattedAmount.contains('.')) {
            formattedAmount += '.00';
        }
        return formattedAmount;
    }
    
    public Map<String, String> getFormattedFields() {
        Map<String, String> formattedFields = new Map<String, String>();
        if (bookingList != null && !bookingList.isEmpty()) {
            Booking_Form__c booking = bookingList[0];
            Map<String, Decimal> fieldsToFormat = new Map<String, Decimal>{
                'Total_Car_Parking_Charges__c' => booking.Total_Car_Parking_Charges__c,
                    'EV_Charges__c' => booking.EV_Charges__c,
                    'Other_Charges__c' => booking.Other_Charges__c,
                    'Booking_Form_Grand_Total__c' => booking.Booking_Form_Grand_Total__c,
                    'Corpus_Fund__c' => booking.Corpus_Fund__c,
                    'Advance_Maintenance__c' => booking.Advance_Maintenance__c,
                    'Doc_Charges__c' => booking.Doc_Charges__c,
                    'Payment_Sc_Total__c' => booking.Payment_Sc_Total__c != null ? (Integer) Math.ceil(booking.Payment_Sc_Total__c) : 0,
                    'Lump_Sum_Amount__c' => booking.Lump_Sum_Amount__c
                    };
                        
                        for (String key : fieldsToFormat.keySet()) {
                            formattedFields.put(key, formatIndianCurrency(fieldsToFormat.get(key)));
                        }
        } else {
            formattedFields.put('Total_Car_Parking_Charges__c', 'N/A');
            formattedFields.put('EV_Charges__c', 'N/A');
            formattedFields.put('Other_Charges__c', 'N/A');
            formattedFields.put('Booking_Form_Grand_Total__c', 'N/A');
            formattedFields.put('Corpus_Fund__c', 'N/A');
            formattedFields.put('Advance_Maintenance__c', 'N/A');
            formattedFields.put('Doc_Charges__c', 'N/A');
            formattedFields.put('Payment_Sc_Total__c', 'N/A');
            formattedFields.put('Lump_Sum_Amount__c', 'N/A');
            formattedFields.put('GST_on_Instalments__c', 'N/A');
            formattedFields.put('Stamp_Duty_Fee__c', 'N/A');
            formattedFields.put('Payment_Sc_Total__c', 'N/A');
        }
        return formattedFields;
    }
    
    public class BookingFormLineItemWrapper {
        public Id Id { get; set; }
        public Decimal AgreementValue { get; set; }
        public String FormattedAmount { get; set; }
        public Id BookingFormId { get; set; }
        public String PaymentParticulars { get; set; }
        public String PaymentScheduleType { get; set; }
    }
}