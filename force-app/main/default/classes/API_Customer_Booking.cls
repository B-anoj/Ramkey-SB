@RestResource(urlMapping='/bookingDetails')
global class API_Customer_Booking {
    
    @HttpGet
    global static void fetchBookingDetails() {
        RestResponse res = RestContext.response;
        String email = RestContext.request.params.get('userEmail');
        String bookingId = RestContext.request.params.get('bookingId');
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('bookings', buildResponse(email).bookings);
        responseMap.put('booking_data', buildDetailedBookingData(bookingId));
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');
    }
    
    // Existing logic preserved
    private static BookingWrapper buildResponse(String email) {
        BookingWrapper wrapper = new BookingWrapper();
        Map<String, String> mapProject = new Map<String, String>();
        Contact matchedUser = [SELECT Id, AccountId, email FROM Contact WHERE email = :email limit 1];
        List<Ramky_Projects__mdt> customerProj = [SELECT Masterlabel, imageUrl__c FROM Ramky_Projects__mdt];
        for (Ramky_Projects__mdt metaIterate : customerProj) {
            mapProject.put(metaIterate.Masterlabel, metaIterate.imageUrl__c);
        }
        List<Booking_Form__c> matchedBooking = [
            SELECT Id, Name, Project_Name__c, Unit_Type__c 
            FROM Booking_Form__c 
            WHERE Opportunity__r.AccountId = :matchedUser.AccountId
        ];
        List<BookingDetail> bookingDetails = new List<BookingDetail>();
        for (Booking_Form__c booking : matchedBooking) {
            bookingDetails.add(
                new BookingDetail(
                    booking.Id,
                    mapProject.get(booking.Project_name__c),
                    booking.Project_Name__c,
                    booking.Unit_Type__c,
                    ''
                )
            );
        }
        wrapper.bookings = bookingDetails;
        return wrapper;
    }
    
    private static BookingData buildDetailedBookingData(String bookingId) {
        BookingData data = new BookingData();
        List<Document> wrapperDoc = new List<Document>();
        List<Booking_Form__c> matchedBooking = [
            SELECT Id, Name, First_Name__c, Last_Name__c, DOB__c, Mobile__c, Email__c, Aadhar__c, CreatedDate, Flat_Villa__c,Booking_Date__c,
            Pan_No__c, Project_Name__c, Booking_Form_Grand_Total__c, Area_in_Sqft__c, Unit__c, Unit_Type__c, Car_Parking__c, Towers__c,Sales_Document__c,
            (SELECT Id, First_Name__c, Last_Name__c, Date_of_Birth__c, Mobile__c, Email__c, Aadhar_No__c, Pan_No__c FROM Other_Applicants__r)
            FROM Booking_Form__c 
            WHERE Id = :bookingId
        ];
        Map<String, String> CustomerInvoice = new Map<String, String>();
        Map<String, String> customerDocuments = new Map<String, String>();
        String salesDocument;
        String salesDoc;
        if (!matchedBooking.isEmpty()) {
            for (Booking_Form__c booking : matchedBooking) {
                data.project = booking.Project_Name__c;
                data.booking_id = booking.Name;
                salesDocument = booking.Id;
                salesDoc = booking.Sales_Document__c;
                List<Applicant> allApplicants = new List<Applicant>();
                String fullName = 
                    (booking.First_Name__c != null ? booking.First_Name__c : '') + ' ' + 
                    (booking.Last_Name__c != null ? booking.Last_Name__c : '');
                
                String dob = booking.DOB__c != null ? booking.DOB__c.format() : '';
                
                for (Other_Applicants__c oa : booking.Other_Applicants__r) {
                    String otherFullName = 
                        (oa.First_Name__c != null ? oa.First_Name__c : '') + ' ' +
                        (oa.Last_Name__c != null ? oa.Last_Name__c : '');
                    
                    String otherDob = oa.Date_of_Birth__c != null ? oa.Date_of_Birth__c.format() : '';
                    
                    allApplicants.add(new Applicant(
                        'Co-Applicant',
                        otherFullName,
                        otherDob,
                        oa.Mobile__c != null ? oa.Mobile__c : '',
                        oa.Email__c != null ? oa.Email__c : '',
                        oa.Aadhar_No__c != null ? oa.Aadhar_No__c : '',
                        oa.Pan_No__c != null ? oa.Pan_No__c : ''
                    ));
                }
                
                data.applicants = allApplicants;
                data.booking_details = new BookingDetails(
                    booking.Booking_Date__c,
                    booking.Car_Parking__c,
                    booking.Flat_Villa__c,
                    booking.Towers__c,
                    booking.Unit_Type__c,
                    booking.Unit__c,
                    booking.Area_in_Sqft__c,
                    formatIndianCurrency(booking.Booking_Form_Grand_Total__c),
                    formatIndianCurrency(booking.Booking_Form_Grand_Total__c),
                    formatIndianCurrency(booking.Booking_Form_Grand_Total__c),
                    formatIndianCurrency(booking.Booking_Form_Grand_Total__c),
                    formatIndianCurrency(booking.Booking_Form_Grand_Total__c)
                );
            }
        } else {
            data.applicants = new List<Applicant>();
        }
        List<Invoice__c> customerInvoiceDetails = [SELECT Id,  Document_Link__c, Receipt_No__c FROM Invoice__c WHERE Booking_Form__c =:salesDocument];
        List<Payment__C> allInvoices = [
            SELECT Id,  Receipt_No__c, Amount__c, Due_Date__c,
            Unpaid_Amount__c, Status__c, Booking_Form__r.Project_Name__c, Description__c,
            Booking_Form__r.Name, Booking_Form__c, Booking_Form__r.Id
            FROM Payment__c
            WHERE Booking_Form__c =: bookingId
        ];
        List<Document__c> customerDoc = [SELECT Id,Name,Document_Type__c, Booking_form__c,Document_Link__c FROM Document__c WHERE booking_Form__c =: bookingId];
        List<PaymentItem> paymentItems = new List<PaymentItem>();
        for (Invoice__c customerInv : customerInvoiceDetails) {
            CustomerInvoice.put(customerInv.Receipt_No__c, customerInv.Document_Link__c);
        }
        data.documents = new List<Document>();
        data.documents = new List<Document>();
        for (Document__c DocIterate : customerDoc) {
            data.documents.add(new Document(
                DocIterate.Name,
                DocIterate.Document_Link__c,
                DocIterate.Document_Type__c
            ));
        }
        for (Payment__c invDetails : allInvoices) {
            paymentItems.add(
                new PaymentItem(
                    invDetails.Description__c != null ? invDetails.Description__c : '',
                    invDetails.Receipt_No__c != null ? invDetails.Receipt_No__c : '',
                    invDetails.Status__c != null ? invDetails.Status__c : '',
                    invDetails.Amount__c != null ? invDetails.Amount__c : 0,
                    invDetails.Due_Date__c,
                    invDetails.Unpaid_Amount__c != null ? invDetails.Unpaid_Amount__c : 0,
                    CustomerInvoice.get(invDetails.Receipt_No__c)
                )
            );
        }
        List<Booking_summary__c> customerPayment = [
            SELECT Id, Total_Cost_Net_Value__c, Received_Amount_Annexure__c, Total_Due_payable__c, Sales_Document__c 
            FROM Booking_Summary__c 
            WHERE Sales_Document__c = :salesDoc
        ];
        
        Decimal totalAmount;
        Decimal amountPaid;
        Decimal dueAmount;
        
        String totalAmountFormatted;
        String amountPaidFormatted;
        String dueAmountFormatted;
        
        for (Booking_summary__c StateAcc : customerPayment) {
            totalAmount = StateAcc.Total_Cost_Net_Value__c;
            amountPaid = StateAcc.Received_Amount_Annexure__c;
            dueAmount = StateAcc.Total_Due_payable__c;
            
            totalAmountFormatted = formatToLakhs(totalAmount);
            amountPaidFormatted = formatToLakhs(amountPaid);
            dueAmountFormatted = formatToLakhs(dueAmount);
        }
        
        data.payment_plan = new PaymentPlan(
            new PaymentSummary(
                totalAmountFormatted,
                amountPaidFormatted,
                dueAmountFormatted
                
            ),
            paymentItems
        );
        
        
        return data;
    }
    public static String formatIndianCurrency(Decimal value) {
        if (value == null) return '';
        
        String[] parts = String.valueOf(value.setScale(2)).split('\\.');
        String integerPart = parts[0];
        String decimalPart = parts.size() > 1 ? parts[1] : '00';
        
        String formatted = '';
        Integer len = integerPart.length();
        
        if (len > 3) {
            formatted = integerPart.substring(len - 3);
            integerPart = integerPart.substring(0, len - 3);
            
            while (integerPart.length() > 2) {
                formatted = integerPart.substring(integerPart.length() - 2) + ',' + formatted;
                integerPart = integerPart.substring(0, integerPart.length() - 2);
            }
            
            if (!String.isEmpty(integerPart)) {
                formatted = integerPart + ',' + formatted;
            }
        } else {
            formatted = integerPart;
        }
        
        return '₹' + formatted + '.' + decimalPart;
    }
    
    public static String formatToLakhs(Decimal amount) {
        if (amount == null) return '0.00L';
        Decimal lakhs = amount / 100000;
        return lakhs.setScale(2) + 'L';
    }
    
    
    
    // === EXISTING WRAPPER ===
    global class BookingWrapper {
        public List<BookingDetail> bookings;
    }
    
    global class BookingDetail {
        public String booking_id;
        public String image_url;
        public String banner_Heading;
        public String title;
        public String description;
        
        public BookingDetail(String id, String url, String heading, String title, String desct) {
            this.booking_id = id;
            this.image_url = url;
            this.banner_Heading = heading;
            this.title = title;
            this.description = desct;
        }
    }
    
    // === NEW DETAILED WRAPPERS ===
    global class BookingData {
        public String project;
        public String booking_id;
        public List<Applicant> applicants;
        public BookingDetails booking_details;
        public List<Document> documents;
        public PaymentPlan payment_plan;
    }
    
    global class Applicant {
        public String role;
        public String name;
        public String dob;
        public String mobile;
        public String email;
        public String adhaar;
        public String pan;
        
        public Applicant(String role, String name, String dob, String mobile, String email, String adhaar, String pan) {
            this.role = role;
            this.name = name;
            this.dob = dob;
            this.mobile = mobile;
            this.email = email;
            this.adhaar = adhaar;
            this.pan = pan;
        }
    }
    
    global class BookingDetails {
        public Date booking_date;
        public Decimal number_of_car_parks;
        public String flat_or_villa;
        public String tower_block_villa;
        public String unit_type;
        public String unit_number;
        public Decimal square_feet;
        public String property_value_gst_excluded;
        public String other_charges_gst_excluded;
        public String maintenance;
        public String corpus_fund;
        public String legal_documnetation_charges;
        
        public BookingDetails(Date dates, Decimal cars, String flat, String block, String unitType, String unitNo,
                              Decimal sqft, String value, String otherCharges, String maint, String corpus, String legal) {
                                  this.booking_date = dates;
                                  this.number_of_car_parks = cars;
                                  this.flat_or_villa = flat;
                                  this.tower_block_villa = block;
                                  this.unit_type = unitType;
                                  this.unit_number = unitNo;
                                  this.square_feet = sqft;
                                  this.property_value_gst_excluded = value;
                                  this.other_charges_gst_excluded = otherCharges;
                                  this.maintenance = maint;
                                  this.corpus_fund = corpus;
                                  this.legal_documnetation_charges = legal;
                              }
    }
    
    global class Document {
        public String document_title;
        public String document_url;
        public String document_id;
        
        public Document(String title, String url, String id) {
            this.document_title = title;
            this.document_url = url;
            this.document_id = id;
        }
    }
    
    global class PaymentPlan {
        public PaymentSummary payment_summary;
        public List<PaymentItem> payment_list;
        
        public PaymentPlan(PaymentSummary summary, List<PaymentItem> paymentData) {
            this.payment_summary = summary;
            this.payment_list = paymentData;
        }
    }
    
    global class PaymentSummary {
        public String total;
        public String amount_due;
        public String amount_paid;
        
        public PaymentSummary(String total, String due, String paid) {
            this.total = total;
            this.amount_due = due;
            this.amount_paid = paid;
        }
    }
    
    global class PaymentItem {
        public String payment_name;
        public String reciept_no;
        public String payment_status;
        public Decimal amount;
        public Date due_date;
        public Decimal unpaid_amount;
        public String receipt_url;
        
        public PaymentItem(String name, String receiptNo, String status, Decimal amount, Date due, Decimal unpaid, String url) {
            this.payment_name = name;
            this.reciept_no = receiptNo;
            this.payment_status = status;
            this.amount = amount;
            this.due_date = due;
            this.unpaid_amount = unpaid;
            this.receipt_url = url;
        }
    }
}