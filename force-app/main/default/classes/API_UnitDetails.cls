@RestResource(urlMapping='/UnitDetails')
global class API_UnitDetails {
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String contactEmail = req.params.get('userEmail');
        String bookingIdParam = req.params.get('bookingId');

        if (String.isBlank(contactEmail)) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Missing userEmail in query parameters');
            return;
        }

        try {
            Contact con = [SELECT Id, Name, AccountId FROM Contact WHERE Email = :contactEmail LIMIT 1];
            
            List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE AccountId = :con.AccountId];
            Set<Id> oppIds = new Set<Id>();
            for (Opportunity opp : oppList) {
                oppIds.add(opp.Id);
            }

            List<Booking_Form__c> bookingForms = [
                SELECT Id, Opportunity__c, Sales_Document__c, Project_Name__c 
                FROM Booking_Form__c 
                WHERE Opportunity__c IN :oppIds
            ];

            // Build maps
            Map<String, Booking_Form__c> salesDocToFormMap = new Map<String, Booking_Form__c>();
            Set<String> salesDocNums = new Set<String>();

            for (Booking_Form__c form : bookingForms) {
                if (String.isNotBlank(form.Sales_Document__c)) {
                    try {
                        String docNum = form.Sales_Document__c;
                        salesDocNums.add(docNum);
                        salesDocToFormMap.put(docNum, form);
                    } catch (Exception e) {
                        System.debug('⚠️ Skipped non-numeric Sales_Document__c: ' + form.Sales_Document__c);
                    }
                }
            }

            List<Booking_Summary__c> summaries = [
                SELECT Id, Sales_Document__c, Project_Name__c, Unit_Number__c, Area_of_Sq_ft__c, Area_of_Sales_Date__c, 
                       Agreement_Sale_Value__c, Co_Applicant__c, Corpus_Fund__c, Advance_Maintenance__c, Legal_Charges__c, 
                       Modification_Charges__c, Interest_Payable__c, Transfer_fee__c, Additional_Charges_Total__c, 
                       Total_Cost_Net_Value__c, Total_Due_payable__c, GST_on_AOS_Value__c, Total_sale_value_with_GST__c, 
                       Received_Amount_Annexure__c, Due_Payable_as_per_Invoice_Amount__c, Invoice_Amount_Annexure__c, 
                       Customer_Name__c, Date_of_Statement__c
                FROM Booking_Summary__c 
                WHERE Sales_Document__c IN :salesDocNums
            ];

            // Get project metadata in bulk
            Set<String> projectNames = new Set<String>();
            for (Booking_Form__c form : bookingForms) {
                if (form.Project_Name__c != null) {
                    projectNames.add(form.Project_Name__c);
                }
            }

            Map<String, Ramky_Projects__mdt> metaMap = new Map<String, Ramky_Projects__mdt>();
            for (Ramky_Projects__mdt meta : [
                SELECT MasterLabel, Corporate_Address__c, Website__c, CRM_Contact__c, Property_Address__c, ImageUrl__c 
                FROM Ramky_Projects__mdt 
                WHERE MasterLabel IN :projectNames
            ]) {
                metaMap.put(meta.MasterLabel, meta);
            }

            List<Object> dataArray = new List<Object>();
            Map<String, Object> currentProject = new Map<String, Object>();

            for (Booking_Summary__c summary : summaries) {
                Booking_Form__c form = salesDocToFormMap.get(summary.Sales_Document__c);
                Ramky_Projects__mdt meta = metaMap.get(form.Project_Name__c);

                // For data[] section
                dataArray.add(new Map<String, Object>{
                    'name' => form.Project_Name__c,
                    'unit_number' => summary.Unit_Number__c,
                    'image_url' => meta != null ? meta.ImageUrl__c : '',
                    'address' => meta != null ? meta.Property_Address__c : '',
                    'booking_id' => form.Sales_Document__c
                });

                // For current_project section - match by bookingId param
                if (bookingIdParam != null && form.Sales_Document__c == bookingIdParam) {
                    currentProject.put('booking_id', form.Sales_Document__c);
                    currentProject.put('corporate_address', meta != null ? meta.Corporate_Address__c : '');
                    currentProject.put('phone_number', meta != null ? meta.CRM_Contact__c : '');
                    currentProject.put('website', meta != null ? meta.Website__c : '');
                    currentProject.put('project_name', summary.Project_Name__c);

                    currentProject.put('account_statement', new Map<String, Object>{
                        'customer_name' => summary.Customer_Name__c,
                        'co_applicant' => summary.Co_Applicant__c,
                        'date_of_statement' => String.valueOf(summary.Date_of_Statement__c),
                        'unit_number' => summary.Unit_Number__c,
                        'total_area_sq_ft' => summary.Area_of_Sq_ft__c,
                        'sale_date' => String.valueOf(summary.Area_of_Sales_Date__c),
                        'sale_value' => summary.Agreement_Sale_Value__c,
                        'gst_value' => summary.GST_on_AOS_Value__c,
                        'total_sale_value' => summary.Total_sale_value_with_GST__c
                    });

                    currentProject.put('additional_charges', new Map<String, Object>{
                        'corpus_fund' => summary.Corpus_Fund__c,
                        'advance_maintenance' => summary.Advance_Maintenance__c,
                        'legal_charges' => summary.Legal_Charges__c,
                        'modification_charges' => summary.Modification_Charges__c,
                        'interest_payable' => summary.Interest_Payable__c,
                        'transfer_fee' => summary.Transfer_fee__c,
                        'total_additional_charges' => summary.Additional_Charges_Total__c,
                        'total_charges' => summary.Total_Cost_Net_Value__c
                    });

                    currentProject.put('transaction_details', new Map<String, Object>{
                        'transaction_amount' => summary.Invoice_Amount_Annexure__c,
                        'received_amount' => summary.Received_Amount_Annexure__c,
                        'due_payable' => summary.Due_Payable_as_per_Invoice_Amount__c,
                        'interest_paid' => summary.Interest_Payable__c,
                        'total_due' => summary.Total_Due_payable__c
                    });
                }
            }

            Map<String, Object> jsonResponse = new Map<String, Object>{
                'data' => dataArray,
                'current_project' => currentProject
            };

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
            res.addHeader('Content-Type', 'application/json');

        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Error: ' + e.getMessage());
        }
    }
}