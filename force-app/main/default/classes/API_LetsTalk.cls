@RestResource(urlMapping='/LetsTalk')
global class API_LetsTalk {
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
            List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE AccountId = :con.AccountId];
            Set<Id> oppIds = new Set<Id>();
            for (Opportunity o : opps) oppIds.add(o.Id);

            // Fetch Booking Forms
            List<Booking_Form__c> bookingForms = [
                SELECT Id, Project_Name__c 
                FROM Booking_Form__c 
                WHERE Opportunity__c IN :oppIds AND Project_Name__c != null
            ];

            Set<String> projectNames = new Set<String>();
            for (Booking_Form__c form : bookingForms) {
                projectNames.add(form.Project_Name__c);
            }

            // Fetch Metadata for projects
            List<Map<String, Object>> projectsList = new List<Map<String, Object>>();
            for (Ramky_Projects__mdt meta : [
                SELECT MasterLabel, Property_Address__c, Corporate_Address__c, 
                       CRM_Contact__c, Contact_Person__c, Email__c 
                FROM Ramky_Projects__mdt 
                WHERE MasterLabel IN :projectNames
            ]) {
                List<Map<String, Object>> propertyList = new List<Map<String, Object>>();

                // Property Address
                if (meta.Property_Address__c != null) {
                    propertyList.add(new Map<String, Object>{
                        'type' => 'Property Address',
                        'value' => meta.Property_Address__c,
                        'action_label' => 'Open Location on Maps',
                        'action_type' => 'location',
                        'action_url' => 'https://maps.google.com/?q=' + EncodingUtil.urlEncode(meta.Property_Address__c, 'UTF-8')
                    });
                }

                // Email
                if (meta.Email__c != null) {
                    propertyList.add(new Map<String, Object>{
                        'type' => 'Email',
                        'value' => meta.Email__c,
                        'action_label' => 'Email us',
                        'action_type' => 'email',
                        'action_url' => 'mailto:' + meta.Email__c
                    });
                }

                // CRM Contact (Contact Person : Phone)
                if (meta.Contact_Person__c != null || meta.CRM_Contact__c != null) {
                    String contactValue = '';
                    if (meta.Contact_Person__c != null) contactValue += meta.Contact_Person__c;
                    if (meta.CRM_Contact__c != null) contactValue += ' : ' + meta.CRM_Contact__c;
                    propertyList.add(new Map<String, Object>{
                        'type' => 'CRM Contact',
                        'value' => contactValue,
                        'action_label' => 'Call us',
                        'action_type' => 'phone',
                        'action_url' => meta.CRM_Contact__c != null ? 'tel:' + meta.CRM_Contact__c.replaceAll('[^0-9]', '') : ''
                    });
                }

                // Corporate Address
                if (meta.Corporate_Address__c != null) {
                    propertyList.add(new Map<String, Object>{
                        'type' => 'Corporate Address',
                        'value' => meta.Corporate_Address__c,
                        'action_label' => 'Open Location on Maps',
                        'action_type' => 'location',
                        'action_url' => 'https://maps.google.com/?q=' + EncodingUtil.urlEncode(meta.Corporate_Address__c, 'UTF-8')
                    });
                }

                projectsList.add(new Map<String, Object>{
                    'project_name' => meta.MasterLabel,
                    'property' => propertyList
                });
            }

            Map<String, Object> finalResponse = new Map<String, Object>{
                'projects' => projectsList
            };

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(finalResponse));
            res.addHeader('Content-Type', 'application/json');

        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Error: ' + e.getMessage());
        }
    }
}