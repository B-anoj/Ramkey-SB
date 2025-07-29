global class BatchInvoiceDetails implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            'SELECT Id, Sales_Document__c FROM Booking_Form__c WHERE Sales_Document__c != null'
        );
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Booking_Form__c> bookingForms = (List<Booking_Form__c>) scope;
        for (Booking_Form__c booking : bookingForms) {
            String salesDocId = booking.Sales_Document__c;
            try {
                String baseUrl = Label.SAPInvoiceListEndPoint;
                String queryParams = '?$DocumentNumber=\'' + salesDocId + '\'&$format=json';
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint(baseUrl + queryParams);
                req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(Label.SAPStatementAuth)));
                Http http = new Http();
                HttpResponse res = http.send(req);
                APILoggerController.fetchSAPResponse(res.getStatusCode(), res.getBody());
                if (res.getStatusCode() == 200) {
                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    Map<String, Object> invoiceSet = (Map<String, Object>) jsonResponse.get('InvoiceDetailsSet');
                    
                    if (invoiceSet == null || !invoiceSet.containsKey('InvoiceDetails')) {
                        continue;
                    }
                    
                    List<Object> invoiceList = (List<Object>) invoiceSet.get('InvoiceDetails');
                    if (invoiceList == null || invoiceList.isEmpty()) {
                        continue;
                    }
                    
                    Map<String, Invoice__c> newInvoicesMap = new Map<String, Invoice__c>();
                    Set<String> receiptNos = new Set<String>();
                    
                    for (Object obj : invoiceList) {
                        Map<String, Object> invMap = (Map<String, Object>) obj;
                        
                        String receiptNo = (String) invMap.get('ReceiptNo');
                        if (String.isBlank(receiptNo)) continue; 
                        
                        String key = salesDocId + ':' + receiptNo;
                        receiptNos.add(receiptNo);
                        
                        Invoice__c inv = new Invoice__c();
                        inv.Sales_Document__c = salesDocId;
                        inv.Receipt_No__c = receiptNo;
                        inv.Invoice_No__c = (String) invMap.get('InvoiceID'); 
                        inv.Description__c = (String) invMap.get('Description');
                        inv.Amount__c = parseDecimal(invMap.get('Amount'));
                        inv.Unpaid_Amount__c = parseDecimal(invMap.get('UnPaidAmount'));
                        inv.Due_Date__c = parseDate(invMap.get('DueDate'));
                        inv.Payment_Date__c = parseDate(invMap.get('PaymentDate'));
                        inv.Booking_Form__c = booking.Id;
                        if(parseDecimal(invMap.get('UnPaidAmount')) == 0) {
                            inv.Status__c = 'Paid';
                        } else {
                            inv.Status__c = 'Pending';
                        }
                        newInvoicesMap.put(key, inv);
                    }
                    
                    List<Invoice__c> existingInvoices = [
                        SELECT Id, Sales_Document__c, Receipt_No__c
                        FROM Invoice__c
                        WHERE Sales_Document__c = :salesDocId
                        AND Receipt_No__c IN :receiptNos
                    ];
                    
                    Set<String> existingKeys = new Set<String>();
                    for (Invoice__c existing : existingInvoices) {
                        String key = existing.Sales_Document__c + ':' + existing.Receipt_No__c;
                        existingKeys.add(key);
                    }
                    
                    List<Invoice__c> toInsert = new List<Invoice__c>();
                    for (String key : newInvoicesMap.keySet()) {
                        if (!existingKeys.contains(key)) {
                            toInsert.add(newInvoicesMap.get(key));
                        }
                    }
                    
                    if (!toInsert.isEmpty()) {
                        insert toInsert;
                        System.debug('Inserted Invoices: ' + toInsert.size());
                    } else {
                        System.debug('No new invoices to insert for sales document: ' + salesDocId);
                    }
                    
                } else {
                    System.debug('SAP API Error - Status: ' + res.getStatus() + ', Body: ' + res.getBody());
                }
                
            } catch (Exception ex) {
                System.debug('Exception for Sales Document ' + salesDocId + ': ' + ex.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        //BatchSAPInvoiceAttachment batch = new BatchSAPInvoiceAttachment();
        Database.executeBatch(new BatchSAPInvoiceAttachment(), 1);
        System.debug('BatchInvoiceDetails completed.');
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