global class BatchSAPPaymentDetails implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    List<Payment__c> collectedPayments = new List<Payment__c>();
    Set<String> allReceiptNos = new Set<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            'SELECT Id, Sales_Document__c FROM Booking_Form__c WHERE Sales_Document__c != null'
        );
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Booking_Form__c> bookingForms = (List<Booking_Form__c>) scope;
        
        for (Booking_Form__c form : bookingForms) {
            String docId = form.Sales_Document__c;
            
            try {
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                String baseUrl = Label.SAPPaymentEndPoint;
                String queryParams = '?$DocumentNumber=\'' + docId + '\'';
                req.setEndpoint(baseUrl + queryParams);
                req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(Label.SAPStatementAuth)));
                
                Http http = new Http();
                HttpResponse res = http.send(req);
                
                APILoggerController.fetchSAPResponse(res.getStatusCode(), res.getBody());

                if (res.getStatusCode() == 200) {
                    Object parsed = JSON.deserializeUntyped(res.getBody());
                    if (!(parsed instanceof Map<String, Object>)) continue;
                    
                    Map<String, Object> jsonResponse = (Map<String, Object>) parsed;
                    
                    if (!jsonResponse.containsKey('PaymentDetailsSet')) continue;
                    
                    Object paymentSetObj = jsonResponse.get('PaymentDetailsSet');

                    // Skip empty string or null
                    if (paymentSetObj == null || (paymentSetObj instanceof String)) {
                        continue;
                    }
                    
                    Map<String, Object> paymentSet = (Map<String, Object>) paymentSetObj;
                    
                    if (!paymentSet.containsKey('PaymentDetails')) continue;
                    
                    Object paymentsObj = paymentSet.get('PaymentDetails');
                    if (!(paymentsObj instanceof List<Object>)) continue;
                    
                    List<Object> payments = (List<Object>) paymentsObj;
                    
                    for (Object obj : payments) {
                        if (!(obj instanceof Map<String, Object>)) continue;
                        
                        Map<String, Object> pay = (Map<String, Object>) obj;
                        String receipt = (String) pay.get('ReceiptNo');
                        if (String.isBlank(receipt)) continue;
                        if (allReceiptNos.contains(receipt)) continue;

                        Payment__c p = new Payment__c();
                        p.Receipt_No__c = receipt;
                        p.Sales_Document__c = (String) pay.get('SalesDocument');
                        p.Booking_Form__c = form.Id;
                        p.Amount__c = parseDecimal(pay.get('Amount'));
                        p.Unpaid_Amount__c = parseDecimal(pay.get('UnPaidAmount'));
                        p.Due_Date__c = parseDate(pay.get('DueDate'));
                        p.Description__c = (String) pay.get('Description');
                        p.Status__c = (p.Unpaid_Amount__c == 0) ? 'Paid' : 'Unpaid';
                        
                        collectedPayments.add(p);
                        allReceiptNos.add(receipt);
                    }
                } else {
                    System.debug('SAP error for docId ' + docId + ' => ' + res.getBody());
                }
                
            } catch (Exception ex) {
                System.debug('Exception for Booking: ' + form.Id + ' => ' + ex.getMessage());
                APILoggerController.fetchSAPResponse(500, ex.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if (!collectedPayments.isEmpty()) {
            // Avoid inserting duplicates already present in DB
            Set<String> existingReceipts = new Set<String>();
            for (Payment__c existing : [
                SELECT Receipt_No__c FROM Payment__c WHERE Receipt_No__c IN :allReceiptNos
            ]) {
                existingReceipts.add(existing.Receipt_No__c);
            }
            
            List<Payment__c> toInsert = new List<Payment__c>();
            for (Payment__c p : collectedPayments) {
                if (!existingReceipts.contains(p.Receipt_No__c)) {
                    toInsert.add(p);
                }
            }
            
            if (!toInsert.isEmpty()) {
                insert toInsert;
                System.debug('✅ Total payments inserted: ' + toInsert.size());
            } else {
                System.debug('ℹ️ No new payments to insert (duplicates skipped).');
            }
        } else {
            System.debug('ℹ️ No payment data collected during batch.');
        }
        Database.executeBatch(new BatchSAPBookingDocuments(), 1);
        
        System.debug('✅ BatchSAPPaymentDetails finished successfully.');
    }
    
    private static Decimal parseDecimal(Object val) {
        try {
            return val != null ? Decimal.valueOf(String.valueOf(val)) : null;
        } catch (Exception e) {
            return null;
        }
    }
    
    private static Date parseDate(Object val) {
        try {
            String raw = String.valueOf(val);
            return raw != null && raw.length() == 8 && raw != '00000000'
                ? Date.newInstance(
                    Integer.valueOf(raw.substring(0, 4)),
                    Integer.valueOf(raw.substring(4, 6)),
                    Integer.valueOf(raw.substring(6, 8))
                ) : null;
        } catch (Exception e) {
            return null;
        }
    }
}