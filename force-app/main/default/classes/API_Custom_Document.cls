@RestResource(urlMapping='/documents')
global without sharing class API_Custom_Document {
    
    @HttpGet
    global static void fetchCustomerDocuments() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String email = req.params.get('email');
        
        if (String.isBlank(email)) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Email parameter is required.');
            return;
        }
        
        List<Booking_Form__c> bookingForms = [
            SELECT Id, Project_Name__c, Opportunity__r.Account.Email__c
            FROM Booking_Form__c
            WHERE Opportunity__r.Account.Email__c = :email
        ];
        
        Set<String> projectNames = new Set<String>();
        Map<String, Id> projectToBookingIdMap = new Map<String, Id>();
        for (Booking_Form__c form : bookingForms) {
            if (form.Project_Name__c != null) {
                projectNames.add(form.Project_Name__c);
                if (!projectToBookingIdMap.containsKey(form.Project_Name__c)) {
                    projectToBookingIdMap.put(form.Project_Name__c, form.Id);
                }
            }
        }
        
        List<Document__c> customerDocs = [
            SELECT Id, Name, Document_Type__c, Document_Link__c, Booking_Form__r.Project_Name__c
            FROM Document__c
            WHERE Booking_Form__r.Opportunity__r.Account.Email__c = :email
        ];
        
        List<Ramky_Projects__mdt> allProjects = [
            SELECT MasterLabel, Property_Document_Link__c, QualifiedApiName
            FROM Ramky_Projects__mdt
            WHERE MasterLabel IN :projectNames
        ];
        
        Map<String, String> projectPropertyDocsMap = new Map<String, String>();
        Map<String, String> projectMetadataIdMap = new Map<String, String>();
        
        for (Ramky_Projects__mdt proj : allProjects) {
            projectPropertyDocsMap.put(proj.MasterLabel, proj.Property_Document_Link__c);
            projectMetadataIdMap.put(proj.MasterLabel, proj.QualifiedApiName); // Unique metadata name
        }
        
        List<Map<String, Object>> projectJsonList = new List<Map<String, Object>>();
        
        for (String projectName : projectNames) {
            List<Map<String, String>> myDocuments = new List<Map<String, String>>();
            List<Map<String, String>> propertyDocuments = new List<Map<String, String>>();
            
            for (Document__c doc : customerDocs) {
                if (doc.Booking_Form__r != null && doc.Booking_Form__r.Project_Name__c == projectName) {
                    Map<String, String> docMap = new Map<String, String>{
                        'id' => doc.Id,
                            'name' => doc.Name,
                            'view_url' => doc.Document_Link__c
                            };
                                myDocuments.add(docMap);
                }
            }
            
            String links = projectPropertyDocsMap.get(projectName);
            if (links != null) {
                List<String> linkList = links.split(',');
                Integer i = 1;
                for (String link : linkList) {
                    Map<String, String> propDoc = new Map<String, String>{
                        'id' => 'property_doc_' + String.valueOf(i),
                            'name' => 'Property Document ' + String.valueOf(i),
                            'view_url' => link.trim()
                            };
                                propertyDocuments.add(propDoc);
                    i++;
                }
            }
            
            String projectId = projectMetadataIdMap.containsKey(projectName)
                ? projectMetadataIdMap.get(projectName)
                : (projectToBookingIdMap.containsKey(projectName)
                   ? projectToBookingIdMap.get(projectName)
                   : '');
                       
                       Map<String, Object> projectMap = new Map<String, Object>{
                           'project_id' => projectId,
                               'project_name' => projectName,
                               'document_types' => new List<String>{'My Documents', 'Project Documents'},
                                   'documents' => new Map<String, Object>{
                                       'my_documents' => myDocuments,
                                           'property_documents' => propertyDocuments
                                           }
                       };
                           
                           projectJsonList.add(projectMap);
        }
        
        Map<String, Object> responseWrapper = new Map<String, Object>{
            'projects' => projectJsonList
                };
                    
                    res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
    }
}