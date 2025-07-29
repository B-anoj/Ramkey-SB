global class BatchSAPStatementAccountBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            'SELECT Id, Sales_Document__c FROM Booking_Form__c WHERE Sales_Document__c != null'
        );
    }

    global void execute(Database.BatchableContext BC, List<Booking_Form__c> scope) {
        Map<String, Booking_Summary__c> existingSummariesMap = new Map<String, Booking_Summary__c>();
        Set<String> salesDocIds = new Set<String>();

        for (Booking_Form__c form : scope) {
            salesDocIds.add(form.Sales_Document__c);
        }

        // Query existing summaries to avoid duplicates
        for (Booking_Summary__c summary : [
            SELECT Id, Sales_Document__c FROM Booking_Summary__c
            WHERE Sales_Document__c IN :salesDocIds
        ]) {
            existingSummariesMap.put(summary.Sales_Document__c, summary);
        }

        List<Booking_Summary__c> summariesToUpsert = new List<Booking_Summary__c>();

        for (Booking_Form__c form : scope) {
            String docId = form.Sales_Document__c;

            try {
                String baseUrl = Label.SAPStatementCustomer;
                String queryParams = '?$DocumentNumber=\'' + docId + '\'&$format=json';
                HttpRequest req = new HttpRequest();
                req.setEndpoint(baseUrl + queryParams);
                req.setMethod('GET');
                String auth = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(Label.SAPStatementAuth));
                req.setHeader('Authorization', auth);

                Http http = new Http();
                HttpResponse res = http.send(req);
                          APILoggerController.fetchSAPResponse(res.getStatusCode(), res.getBody());

                if (res.getStatusCode() == 200) {
                    SoaWrapper wrapper = (SoaWrapper) JSON.deserialize(res.getBody(), SoaWrapper.class);
                    SoaData d = wrapper.d;

                    Booking_Summary__c booking;
                    if (existingSummariesMap.containsKey(d.SalesDocument)) {
                        booking = existingSummariesMap.get(d.SalesDocument);
                    } else {
                        booking = new Booking_Summary__c();
                        booking.Sales_Document__c = d.SalesDocument;
                    }

                    booking.Project_Name__c = d.SalesOfficeDescription;
                    booking.Customer_Name__c = d.CustomerName;
                    booking.Co_Applicant__c = d.CoApplicant1;
                    booking.Date_of_Statement__c = parseDate(d.DateOfStatement);
                    booking.Unit_Number__c = safeDecimal(d.UnitNumber);
                    booking.Area_of_Sq_ft__c = safeDecimal(d.Area);
                    booking.Area_of_Sales_Date__c = parseDate(d.AgreementOfSaleDate);
                    booking.Agreement_Sale_Value__c = safeDecimal(d.AgreementOfSaleValue);
                    booking.GST_on_AOS_Value__c = safeDecimal(d.GSTOnAOS.replace('%', ''));
                    booking.Total_sale_value_with_GST__c = safeDecimal(d.TotalSaleValue);
                    booking.Advance_Maintenance__c = safeDecimal(d.AdvanceMaintenance);
                    booking.Corpus_Fund__c = safeDecimal(d.CorpusFund);
                    booking.Legal_Charges__c = safeDecimal(d.LegalCharges);
                    booking.Modification_Charges__c = safeDecimal(d.ModificationCharges);
                    booking.Interest_Payable__c = safeDecimal(d.InterestPayable);
                    booking.Transfer_fee__c = safeDecimal(d.TransferFee);
                    booking.Additional_Charges_Total__c = safeDecimal(d.AdditionalChargesTotal);
                    booking.Total_Cost_Net_Value__c = safeDecimal(d.TotalCost);
                    booking.Invoice_Amount_Annexure__c = safeDecimal(d.InvoiceAmount);
                    booking.Received_Amount_Annexure__c = safeDecimal(d.ReceivedAmmount);
                    booking.Due_Payable_as_per_Invoice_Amount__c = safeDecimal(d.DuePayable);
                    booking.Total_Due_payable__c = safeDecimal(d.TotalDue);
                    booking.Booking_Form__c = form.Id;

                    summariesToUpsert.add(booking);

                    APILoggerController.fetchSAPResponse(res.getStatusCode(), res.getBody());
                } else {
                    System.debug('Failed for docId ' + docId + ': ' + res.getStatus() + ' => ' + res.getBody());
                    APILoggerController.fetchSAPResponse(res.getStatusCode(), res.getBody());
                }
            } catch (Exception e) {
                System.debug('Error processing docId ' + docId + ': ' + e.getMessage());
            }
        }

        if (!summariesToUpsert.isEmpty()) {
            upsert summariesToUpsert;
        }
    }

    global void finish(Database.BatchableContext BC) {
       Database.executeBatch(new BatchSAPPaymentDetails(), 1);
    }

    // Supporting classes and methods
    public class SoaWrapper {
        public SoaData d;
    }

    public class SoaData {
        public String SalesDocument;
        public String SalesOffice;
        public String SalesOfficeDescription;
        public String CustomerID;
        public String CustomerName;
        public String CoApplicant1;
        public String CoApplicant2;
        public String CoApplicant3;
        public String CoApplicant4;
        public String DateOfStatement;
        public String UnitNumber;
        public String Area;
        public String AgreementOfSaleDate;
        public String AgreementOfSaleValue;
        public String GSTOnAOS;
        public String TotalSaleValue;
        public String AdvanceMaintenance;
        public String CorpusFund;
        public String LegalCharges;
        public String ModificationCharges;
        public String InterestPayable;
        public String TransferFee;
        public String AdditionalChargesTotal;
        public String TotalCost;
        public String InvoiceAmount;
        public String ReceivedAmmount;
        public String DuePayable;
        public String InterestAmount;
        public String TotalDue;
    }

    private static Date parseDate(String yyyymmdd) {
        if (String.isNotBlank(yyyymmdd) && yyyymmdd.length() == 8) {
            try {
                return Date.newInstance(
                    Integer.valueOf(yyyymmdd.substring(0, 4)),
                    Integer.valueOf(yyyymmdd.substring(4, 6)),
                    Integer.valueOf(yyyymmdd.substring(6, 8))
                );
            } catch (Exception e) {
                System.debug('Invalid date format: ' + yyyymmdd);
            }
        }
        return null;
    }

    private static Decimal safeDecimal(String val) {
        try {
            if (String.isNotBlank(val)) {
                val = val.trim().replace(',', '');
                return Decimal.valueOf(val);
            }
        } catch (Exception e) {
            System.debug('Error parsing decimal: ' + val);
        }
        return null;
    }
}