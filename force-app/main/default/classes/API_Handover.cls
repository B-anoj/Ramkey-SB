@RestResource(urlMapping='/handover')
global class API_Handover {
    
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String contactEmail = req.params.get('userEmail');
        if (String.isBlank(contactEmail)) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Missing userEmail');
            return;
        }
        
        try {
            Contact con = [SELECT Id, AccountId FROM Contact WHERE Email = :contactEmail LIMIT 1];
            if (con.AccountId == null) {
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('No Account associated with Contact');
                return;
            }
            
            List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE AccountId = :con.AccountId];
            Set<Id> oppIds = new Set<Id>();
            for (Opportunity opp : oppList) oppIds.add(opp.Id);
            
            List<Booking_Form__c> forms = [
                SELECT Id, Project_Name__c FROM Booking_Form__c
                WHERE Opportunity__c IN :oppIds AND Project_Name__c != null
            ];
            
            Set<String> projectNames = new Set<String>();
            for (Booking_Form__c form : forms) {
                projectNames.add(form.Project_Name__c.trim());
            }
            
            System.debug('🔍 Project Names: ' + projectNames);
            
            if (projectNames.isEmpty()) {
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{ 'projects' => new List<Object>() }));
                return;
            }
            
            Map<String, Ramky_Projects__mdt> metaMap = new Map<String, Ramky_Projects__mdt>();
            for (Ramky_Projects__mdt meta : [
                SELECT MasterLabel, Property_Address__c, imageUrl__c
                FROM Ramky_Projects__mdt
                WHERE MasterLabel IN :projectNames
            ]) {
                metaMap.put(meta.MasterLabel, meta);
            }
            
            System.debug('🔍 Metadata Map: ' + metaMap);
            
            List<Handover__c> handovers = [
                SELECT Id, Projects__c, Status__c, Action_Type__c, Total_Handover_Items__c,
                (SELECT Id, Description__c, Action__c, Remarks__c FROM Handover_Line_Items__r)
                FROM Handover__c
                WHERE Projects__c IN :projectNames
            ];
            
            System.debug('🔍 Handover Records: ' + handovers);
            
            Map<String, Map<String, Object>> projectToResponseMap = new Map<String, Map<String, Object>>();
            
            for (Handover__c ho : handovers) {
                if (!projectToResponseMap.containsKey(ho.Projects__c)) {
                    Ramky_Projects__mdt meta = metaMap.get(ho.Projects__c);
                    Map<String, Object> projMap = new Map<String, Object>{
                        'project_name' => ho.Projects__c,
                            'address' => meta != null ? meta.Property_Address__c : '',
                                'project_image_url' => meta != null ? meta.imageUrl__c : '',
                                    'project_Id' => meta.Id,
                                    'action_items' => new List<Map<String, Object>>()
                                    };
                                        projectToResponseMap.put(ho.Projects__c, projMap);
                }
                
                Map<String, Object> actionItem = new Map<String, Object>{
                    'action_name' => ho.Action_Type__c,
                        'status' => ho.Status__c,
                        'total_action_items' => ho.Total_Handover_Items__c,
                        'actions_data' => new List<Map<String, Object>>()
                        };
                            
                            for (Handover_Line_Items__c line : ho.Handover_Line_Items__r) {
                                Map<String, Object> lineItem = new Map<String, Object>{
                                    'action_title' => line.Description__c,
                                        'action_subtitle' => ho.Action_Type__c,
                                        'action' => line.Action__c,
                                        'remarks' => line.Remarks__c,
                                        'line_item_id' => line.Id
                                        };
                                            ((List<Map<String, Object>>) actionItem.get('actions_data')).add(lineItem);
                            }
                
                ((List<Map<String, Object>>) projectToResponseMap.get(ho.Projects__c).get('action_items')).add(actionItem);
            }
            
            List<Map<String, Object>> projectList = new List<Map<String, Object>>();
            projectList.addAll(projectToResponseMap.values());
            
            Map<String, Object> response = new Map<String, Object>{
                'projects' => projectList
                    };
                        
                        System.debug('🔍 Final Response: ' + JSON.serialize(response));
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.addHeader('Content-Type', 'application/json');
            
        } catch (Exception e) {
            System.debug('❌ Exception: ' + e.getMessage());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Error: ' + e.getMessage());
        }
    }
    
    
    @HttpPut
    global static void updateHandoverLineItems() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String jsonInput = req.requestBody.toString();
            Map<String, Object> input = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
            
            if (!input.containsKey('line_items')) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('{"status":"error","message":"Missing line_items"}');
                return;
            }
            
            List<Object> lineItemsInput = (List<Object>) input.get('line_items');
            List<Handover_Line_Items__c> itemsToUpdate = new List<Handover_Line_Items__c>();
            
            for (Object itemObj : lineItemsInput) {
                Map<String, Object> item = (Map<String, Object>) itemObj;
                
                if (!item.containsKey('line_item_id')) continue;
                
                Handover_Line_Items__c lineItem = new Handover_Line_Items__c(
                    Id = (String) item.get('line_item_id'),
                    Action__c = (String) item.get('action'),
                    Remarks__c = (String) item.get('remarks')
                );
                itemsToUpdate.add(lineItem);
            }
            
            if (!itemsToUpdate.isEmpty()) {
                update itemsToUpdate;
                Set<Id> handOverId = new Set<Id>();
                for(Handover_Line_Items__c lineItem : itemsToUpdate) {
                    handOverId.add(lineItem.handOver__c);
                }
                List<HandOver__c> updateStatus = [SELECT Id, Status__c FROM Handover__c WHERE Id IN: handOverId];
                for (HandOver__c hd : updateStatus) {
                    hd.Status__c = 'Completed';
                }
                update updateStatus;
            }
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('{"status":"success","message":"Line items updated successfully"}');
            
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"status":"error","message":"' + e.getMessage() + '"}');
        }
    }
}