@RestResource(urlMapping='/dashBoardDetails')
global class API_Customer_DashBoard {
    
    @HttpGet
    global static void fetchCustomerDetails() {
        RestResponse res = RestContext.response;
        String email = RestContext.request.params.get('userEmail');
        res.responseBody = Blob.valueOf(JSON.serialize(buildResponse(email)));
        res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');
    }
    
    public static DataWrapper buildResponse(String userEmail) {
        DataWrapper data = new DataWrapper();
        Set<String> projects = new Set<String>();
        List<Booking_Form__c> customerProjects = [
            SELECT Id, Project_Name__c, Opportunity__r.Account.Email__c
            FROM Booking_Form__c
            WHERE Opportunity__r.Account.Email__c = :userEmail
        ];
        for (booking_Form__c iterateProject : customerProjects) {
            if (!String.isBlank(iterateProject.Project_Name__c)) {
                projects.add(iterateProject.Project_Name__c);
            }
        }
        List<Ramky_Projects__mdt> metaList = [
            SELECT MasterLabel, Description__c, staticResourceName__c, Property_Address__c, imageUrl__c, Project_Percentage__c,Handover_Percent__c 
            FROM Ramky_Projects__mdt
            WHERE MasterLabel IN :projects
        ];
        
        List<ProjectDataWrapper> projectList = new List<ProjectDataWrapper>();
        for (Ramky_Projects__mdt m : metaList) {
            List<ConstructionStatus> statusList = new List<ConstructionStatus>();
            
            Date today = Date.today();
            Date sixMonthsAgo = today.addMonths(-5).toStartOfMonth(); 
            
            List<Construction_Update__c> updates = [SELECT Percent__c, Update_Month__c
                                                    FROM Construction_Update__c WHERE Project__c = :m.MasterLabel
                                                    AND Update_Month__c >= :sixMonthsAgo ORDER BY Update_Month__c ASC];
            System.debug('updates===>'+updates);
            
            Integer updateCount = updates.size();
            for (Integer i = 0; i < updateCount; i++) {
                Construction_Update__c cu = updates[i];
                Date updateDate = cu.Update_Month__c;
                
                DateTime dt = DateTime.newInstance(updateDate, Time.newInstance(0, 0, 0, 0));
                String month = dt.format('MMM', 'en_US'); 
                String year = String.valueOf(updateDate.year()).substring(2); 
                String monthLabel = month + year; 
                
                String percent = cu.Percent__c != null ? String.valueOf(cu.Percent__c) : '0';
                Boolean flag = (i == updateCount - 1); 
                
                statusList.add(new ConstructionStatus(monthLabel, percent, flag));
            }
            
            ProjectDataWrapper projectData = new ProjectDataWrapper();
            projectData.project_id = m.MasterLabel != null ? m.MasterLabel : '';
            projectData.propertyId = m.Id;
            projectData.project_name = m.MasterLabel != null ? m.MasterLabel : '';
            projectData.image_url = m.imageUrl__c != null ? m.imageUrl__c : '';
            projectData.construction_status = statusList;
            projectData.payment_completion_percentage = String.ValueOf(m.Project_Percentage__c);
            projectData.handover_completion_percentage = String.ValueOf(m.Handover_Percent__c);
            projectList.add(projectData);
        }
        data.projects_data = projectList;
        
        // Static completion percentages
        data.support_completion_percentage = '65'; 
        data.refer_completion_percentage = '75';
        
        return data;
    }
     
    // === Response Wrapper Classes ===
    
    global class DataWrapper {
        public List<ProjectDataWrapper> projects_data;
        public String support_completion_percentage;
        public String refer_completion_percentage;
    }
    
    global class ProjectDataWrapper {
        public String project_id;
        public String propertyId;
        public String project_name;
        public String image_url;
        public List<ConstructionStatus> construction_status;
        public String handover_completion_percentage;
        public String payment_completion_percentage;
    }
    
    global class ConstructionStatus {
        public String month;
        public String value;
        public Boolean flag;
        
        public ConstructionStatus(String m, String v, boolean f) {
            this.month = m;
            this.value = v;
            this.flag = f;
        }
    }
}