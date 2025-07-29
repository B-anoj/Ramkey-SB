public without sharing class BookingProjectController {
    
    public class ProjectCardWrapper {
        @AuraEnabled public String projectName;
        @AuraEnabled public String description;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public String propertyAddress;
        @AuraEnabled public string bookingName;
    }
    
    public class ApplicantWrapper {
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String mobile;
        @AuraEnabled public String email;
        @AuraEnabled public String dob;
        @AuraEnabled public String aadhar;
        @AuraEnabled public String pan;
    }
    
    public class DocumentWrapper {
        @AuraEnabled public String documentName;
        @AuraEnabled public String documentType;
        @AuraEnabled public String downloadUrl;
        @AuraEnabled public String viewUrl;
    }
    
    public class BookingWrapper {
        @AuraEnabled public String bookingId;
        @AuraEnabled public String unit;
        @AuraEnabled public String unitType;
        @AuraEnabled public String projectName;
        @AuraEnabled public Date bookingDate;
        @AuraEnabled public String flatVilla;
        @AuraEnabled public Decimal totalAmount;
        @AuraEnabled public Decimal AreainSqft;
        @AuraEnabled public Decimal CarParking;
        @AuraEnabled public Decimal OtherCharges;
        @AuraEnabled public Decimal AdvanceMaintenance;
        @AuraEnabled public Decimal CorpusFund;
        @AuraEnabled public Decimal DocCharges;
        @AuraEnabled public String name;
        
        // First Applicant
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String customerType;
        @AuraEnabled public String gender;
        @AuraEnabled public String maritalStatus;
        @AuraEnabled public String dob;
        @AuraEnabled public String mobile;
        @AuraEnabled public String email;
        @AuraEnabled public String aadhar;
        @AuraEnabled public String pan;
        @AuraEnabled public Id id;
       
        
        // Associated docs
        @AuraEnabled public List<DocumentWrapper> documents;
        
        // Other Applicants
        @AuraEnabled public List<ApplicantWrapper> applicants;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<BookingWrapper> getBookingApplicantDetails(String userEmail) {
        List<BookingWrapper> result = new List<BookingWrapper>();
        if (String.isBlank(userEmail)) return result;
        
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Email = :userEmail LIMIT 1];
        if (con == null || con.AccountId == null) return result;
        Id accountId = con.AccountId;
        
        List<Opportunity> opps = [
            SELECT Id, Projects__c
            FROM Opportunity
            WHERE AccountId = :accountId
        ];
        if (opps.isEmpty()) return result;
        
        Set<Id> oppIds = new Set<Id>();
        Map<Id, String> oppIdToProjectMap = new Map<Id, String>();
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
            if (opp.Projects__c != null) {
                oppIdToProjectMap.put(opp.Id, opp.Projects__c);
            }
        }
        
        List<Booking_Form__c> bookings = [
            SELECT Id, Name, Booking_Id__c, Unit__c, Unit_Type__c, Opportunity__c, Sales_Document__c,
            First_Name__c, Last_Name__c, Mobile__c, Email__c,
            Area_in_Sqft__c, Booking_Date__c
            FROM Booking_Form__c
            WHERE Opportunity__c IN :oppIds
            ORDER BY CreatedDate DESC
        ];
        if (bookings.isEmpty()) return result;
        
        Set<Id> bookingFormIds = new Set<Id>();
        Set<String> bookingIds = new Set<String>();
        for (Booking_Form__c b : bookings) {
            bookingFormIds.add(b.Id);
            bookingIds.add(b.Sales_Document__c);
        }
        
        Map<Id, List<Other_Applicants__c>> applicantMap = new Map<Id, List<Other_Applicants__c>>();
        for (Other_Applicants__c oa : [
            SELECT First_Name__c, Last_Name__c, Mobile__c, Email__c, Booking_Form__c
            FROM Other_Applicants__c
            WHERE Booking_Form__c IN :bookingFormIds
        ]) {
            if (!applicantMap.containsKey(oa.Booking_Form__c)) {
                applicantMap.put(oa.Booking_Form__c, new List<Other_Applicants__c>());
            }
            applicantMap.get(oa.Booking_Form__c).add(oa);
        }
        
        Map<String, List<Document__c>> salesDocToDocs = new Map<String, List<Document__c>>();
        for (Document__c doc : [
            SELECT Name, Document_Type__c, Document_Link__c, Sales_Document__c
            FROM Document__c
            WHERE Sales_Document__c IN :bookingIds
        ]) {
            if (!salesDocToDocs.containsKey(doc.Sales_Document__c)) {
                salesDocToDocs.put(doc.Sales_Document__c, new List<Document__c>());
            }
            salesDocToDocs.get(doc.Sales_Document__c).add(doc);
        }
        
        for (Booking_Form__c b : bookings) {
            BookingWrapper bw = new BookingWrapper();
            bw.id = b.Id;
            bw.bookingId = b.Booking_Id__c;
            bw.unit = b.Unit__c;
            bw.unitType = b.Unit_Type__c;
            bw.projectName = oppIdToProjectMap.get(b.Opportunity__c);
            bw.bookingDate = b.Booking_Date__c;
            bw.AreainSqft = b.Area_in_Sqft__c;
            bw.firstName = b.First_Name__c;
            bw.lastName = b.Last_Name__c;
            bw.mobile = b.Mobile__c;
            bw.email = b.Email__c;
            bw.name = b.Name;
            bw.applicants = new List<ApplicantWrapper>();
            if (applicantMap.containsKey(b.Id)) {
                for (Other_Applicants__c oa : applicantMap.get(b.Id)) {
                    ApplicantWrapper aw = new ApplicantWrapper();
                    aw.firstName = oa.First_Name__c;
                    aw.lastName = oa.Last_Name__c;
                    aw.mobile = oa.Mobile__c;
                    aw.email = oa.Email__c;
                    bw.applicants.add(aw);
                }
            }
            
            bw.documents = new List<DocumentWrapper>();
            if (salesDocToDocs.containsKey(b.Sales_Document__c)) {
                for (Document__c doc : salesDocToDocs.get(b.Sales_Document__c)) {
                    DocumentWrapper dw = new DocumentWrapper();
                    dw.documentName = doc.Name;
                    dw.documentType = doc.Document_Type__c;
                    dw.viewUrl = doc.Document_Link__c;
                    dw.downloadUrl = doc.Document_Link__c;
                    bw.documents.add(dw);
                }
            }
            
            result.add(bw);
        }
        
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static BookingWrapper getBookingApplicantDetailsById(Id bookingId) {
        if (bookingId == null) return null;
        
        Booking_Form__c booking = [
            SELECT Id, Name, Booking_Id__c, Unit__c, Unit_Type__c, Project_Name__c,
            Booking_Date__c, Flat_Villa__c, Booking_Form_Grand_Total__c,
            Opportunity__c, First_Name__c, Last_Name__c, Customer_Type__c,
            Gender__c, Marital_Status__c, DOB__c, Mobile__c, Email__c,
            Aadhar__c, Pan_No__c, Car_Parking__c, Other_Charges__c, 
            Advance_Maintenance__c, Corpus_Fund__c, Doc_Charges__c, Area_in_Sqft__c
            FROM Booking_Form__c
            WHERE Id = :bookingId
            LIMIT 1
        ];
        
        List<Other_Applicants__c> otherApplicants = [
            SELECT First_Name__c, Last_Name__c, Mobile__c, Email__c,
            Date_of_Birth__c, Aadhar_No__c, Pan_No__c
            FROM Other_Applicants__c
            WHERE Booking_Form__c = :booking.Id
        ];
        
        return constructBookingWrapper(booking, otherApplicants);
    }
    
    @AuraEnabled(cacheable = true)
    public static paymentSummary getCustomerPaymentDetails(Id bookingId) {
        paymentSummary summaryWrapper = new paymentSummary();
        
        if (bookingId == null) {
            return summaryWrapper; // Return empty wrapper if bookingId is null
        }
        
        List<Booking_Form__c> bookingList = [
            SELECT Id, Sales_Document__c 
            FROM Booking_Form__c 
            WHERE Id = :bookingId
        ];
        
        if (bookingList.isEmpty()) {
            return summaryWrapper; // Return empty wrapper if no booking form found
        }
        
        Booking_Form__c bookDetail = bookingList[0];
        
        if (bookDetail.Sales_Document__c != null) {
            List<Booking_summary__c> customerPayment = [
                SELECT Id, Total_Cost_Net_Value__c, Received_Amount_Annexure__c, Total_Due_payable__c, Sales_Document__c 
                FROM Booking_Summary__c 
                WHERE Sales_Document__c = :String.valueOf(bookDetail.Sales_Document__c)
            ];
            
            if (!customerPayment.isEmpty()) {
                Booking_summary__c bookSummary = customerPayment[0];
                summaryWrapper.totalAmount = bookSummary.Total_Cost_Net_Value__c;
                summaryWrapper.amountPaid = bookSummary.Received_Amount_Annexure__c;
                summaryWrapper.dueAmount = bookSummary.Total_Due_payable__c;
            }
        }
        
        List<Payment__c> customerSummary = [
            SELECT Id, Booking_Form__c, Receipt_No__c, Description__c, Amount__c, Due_Date__c, Unpaid_Amount__c, Status__c
            FROM Payment__c 
            WHERE Booking_Form__c = :bookingId
        ];
        
        summaryWrapper.paymentDetails = customerSummary;
        
        return summaryWrapper;
    }
    
    public class paymentSummary {
        @AuraEnabled public decimal totalAmount;
        @AuraEnabled public decimal amountPaid;
        @AuraEnabled public decimal dueAmount;
        @AuraEnabled public List<Payment__c> paymentDetails;
    }
    
    private static BookingWrapper constructBookingWrapper(Booking_Form__c b, List<Other_Applicants__c> applicants) {
        BookingWrapper w = new BookingWrapper();
        
        w.bookingId = b.Booking_Id__c;
        w.unit = b.Unit__c;
        w.unitType = b.Unit_Type__c;
        w.projectName = b.Project_Name__c;
        w.bookingDate = b.Booking_Date__c;
        w.flatVilla = b.Flat_Villa__c;
        w.AreainSqft = b.Area_in_Sqft__c;
        w.CarParking = b.Car_Parking__c;
        w.OtherCharges = b.Other_Charges__c;
        w.CorpusFund = b.Corpus_Fund__c;
        w.DocCharges = b.Doc_Charges__c;
        w.totalAmount = b.Booking_Form_Grand_Total__c;
        
        w.firstName = b.First_Name__c;
        w.lastName = b.Last_Name__c;
        w.customerType = b.Customer_Type__c;
        w.gender = b.Gender__c;
        w.maritalStatus = b.Marital_Status__c;
        w.dob = b.DOB__c != null ? String.valueOf(b.DOB__c) : '';
        w.mobile = b.Mobile__c;
        w.email = b.Email__c;
        w.aadhar = b.Aadhar__c;
        w.pan = b.Pan_No__c;
        w.id = b.Id;
        
        w.applicants = new List<ApplicantWrapper>();
        if (applicants != null) {
            for (Other_Applicants__c oa : applicants) {
                ApplicantWrapper aw = new ApplicantWrapper();
                aw.firstName = oa.First_Name__c;
                aw.lastName = oa.Last_Name__c;
                aw.mobile = oa.Mobile__c;
                aw.email = oa.Email__c;
                aw.dob = oa.Date_of_Birth__c != null ? String.valueOf(oa.Date_of_Birth__c) : '';
                aw.aadhar = oa.Aadhar_No__c;
                aw.pan = oa.Pan_No__c;
                w.applicants.add(aw);
            }
        }
        
        return w;
    }
}