public without sharing class UNitDetails {

    public class BookingWrapper {
        @AuraEnabled public String projectName;
        @AuraEnabled public String customerName;
        @AuraEnabled public String coApplicant;
        @AuraEnabled public String unitNumber;
        @AuraEnabled public String areaSqFt;
        @AuraEnabled public String aosDate;
        @AuraEnabled public String aosValue;
        @AuraEnabled public String gstPercentage;
        @AuraEnabled public String totalSaleValueWithGST;
        @AuraEnabled public String corpusFund;
        @AuraEnabled public String advanceMaintenance;
        @AuraEnabled public String legalCharges;
        @AuraEnabled public String modificationCharges;
        @AuraEnabled public String interestPayable;
        @AuraEnabled public String transferFee;
        @AuraEnabled public String additionalChargesTotal;
        @AuraEnabled public String totalCostNet;
        @AuraEnabled public String invoiceAmount;
        @AuraEnabled public String receivedAmount;
        @AuraEnabled public String duePayableAmount;
        @AuraEnabled public String totalDuePayable;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public String corporateAddress;
        @AuraEnabled public String phone;
        @AuraEnabled public String website;
    }

    @AuraEnabled(cacheable=true)
    public static List<BookingWrapper> getMatchingBookingSummaries() {
        List<BookingWrapper> results = new List<BookingWrapper>();
        String contactEmail = 'dhayalan2531@gmail.com';
        try {
            Set<String> allowedProjects = new Set<String>();
            Map<String, Booking_Form__c> bookingMap = new Map<String, Booking_Form__c>();
            List<Booking_Form__c> customerBooking = [SELECT Id, Opportunity__r.Account.Email__c, Project_Name__c  FROM Booking_Form__c WHERE Opportunity__r.Account.Email__c =: contactEmail];
            for (Booking_Form__c book : customerBooking) {
                allowedProjects.add(book.Project_Name__c);
                bookingMap.put(book.Id, book);
            }
            Map<String, Ramky_Projects__mdt> metaMap = new Map<String, Ramky_Projects__mdt>();
            for (Ramky_Projects__mdt meta : [
                SELECT MasterLabel, staticResourceName__c, Corporate_Address__c, CRM_Contact__c
                FROM Ramky_Projects__mdt
                WHERE MasterLabel IN :allowedProjects
            ]) {
                metaMap.put(meta.MasterLabel, meta);
            }
            List<Booking_Summary__c> summaries = [
                SELECT 
                    Project_Name__c, Customer_Name__c, Co_Applicant__c, Unit_Number__c, Area_of_Sq_ft__c,
                    Agreement_Sale_Date__c, Agreement_Sale_Value__c, GST_on_AOS_Value__c, Total_sale_value_with_GST__c,
                    Corpus_Fund__c, Advance_Maintenance__c, Legal_Charges__c, Modification_Charges__c,
                    Interest_Payable__c, Transfer_fee__c, Additional_Charges_Total__c, Total_Cost_Net_Value__c,
                    Invoice_Amount_Annexure__c, Received_Amount_Annexure__c, Due_Payable_as_per_Invoice_Amount__c,
                    Total_Due_payable__c, Booking_Form__c
                FROM Booking_Summary__c
                WHERE Booking_form__c IN: bookingMap.keySet()
            ];

            for (Booking_Summary__c bs : summaries) {
                BookingWrapper bw = new BookingWrapper();

                bw.projectName = bs.Project_Name__c;
                bw.customerName = bs.Customer_Name__c;
                bw.coApplicant = bs.Co_Applicant__c;
                bw.unitNumber = bs.Unit_Number__c != null ? String.valueOf(bs.Unit_Number__c) : '';
                bw.areaSqFt = bs.Area_of_Sq_ft__c != null ? String.valueOf(bs.Area_of_Sq_ft__c) : '';
                bw.aosDate = bs.Agreement_Sale_Date__c != null ? String.valueOf(bs.Agreement_Sale_Date__c) : '';
                bw.aosValue = bs.Agreement_Sale_Value__c != null ? String.valueOf(bs.Agreement_Sale_Value__c) : '';
                bw.gstPercentage = bs.GST_on_AOS_Value__c != null ? String.valueOf(bs.GST_on_AOS_Value__c) : '';
                bw.totalSaleValueWithGST = bs.Total_sale_value_with_GST__c != null ? String.valueOf(bs.Total_sale_value_with_GST__c) : '';

                bw.corpusFund = String.valueOf(bs.Corpus_Fund__c);
                bw.advanceMaintenance = String.valueOf(bs.Advance_Maintenance__c);
                bw.legalCharges = String.valueOf(bs.Legal_Charges__c);
                bw.modificationCharges = String.valueOf(bs.Modification_Charges__c);
                bw.interestPayable = String.valueOf(bs.Interest_Payable__c);
                bw.transferFee = String.valueOf(bs.Transfer_fee__c);
                bw.additionalChargesTotal = String.valueOf(bs.Additional_Charges_Total__c);
                bw.totalCostNet = String.valueOf(bs.Total_Cost_Net_Value__c);

                bw.invoiceAmount = String.valueOf(bs.Invoice_Amount_Annexure__c);
                bw.receivedAmount = String.valueOf(bs.Received_Amount_Annexure__c);
                bw.duePayableAmount = String.valueOf(bs.Due_Payable_as_per_Invoice_Amount__c);
                bw.totalDuePayable = String.valueOf(bs.Total_Due_payable__c);

                // Add metadata
                if (metaMap.containsKey(bs.Project_Name__c)) {
                    Ramky_Projects__mdt meta = metaMap.get(bs.Project_Name__c);
                    bw.imageUrl = meta.staticResourceName__c;
                    bw.corporateAddress = meta.Corporate_Address__c;
                    bw.phone = meta.CRM_Contact__c;
                    bw.website = 'https://www.ramkyestates.com/';
                }
               
                results.add(bw);
            }

        } catch (Exception e) {
            System.debug('⚠️ Error in getMatchingBookingSummaries: ' + e.getMessage());
        }
        System.debug(results);
        return results;
    }
}