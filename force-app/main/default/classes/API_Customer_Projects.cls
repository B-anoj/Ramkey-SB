@RestResource(urlMapping='/projects')
global class API_Customer_Projects {
    
    @HttpGet
    global static void fetchProjects() {
        RestResponse res = RestContext.response;
        String email = RestContext.request.params.get('userEmail');
        ProjectResponseWrapper response = new ProjectResponseWrapper();
        List<Upcoming_Project__c> upcomingDetails = [SELECT id, Name, Description__c, Project_Image_Url__c, City__c FROM Upcoming_Project__c];
        List<UpcomingProject> upComingList = new List<UpcomingProject>();
        for (Upcoming_Project__c iterate : upcomingDetails) {
            UpcomingProject upComing = new UpcomingProject(iterate.Project_Image_Url__c, iterate.Name, iterate.Description__c, iterate.City__c);
            upComingList.add(upComing);
        }
        response.upcoming_projects = upComingList;
        List<Opportunity> matchedOpp = [SELECT Id, Projects__c FROM Opportunity WHERE Account.Email__c =: email];
        Set<String> proj = new Set<String>();
        for (Opportunity opp : matchedOpp) {
            proj.add(opp.Projects__c);
        }
        List<Ramky_Projects__mdt> metaData = [SELECT Id, MasterLabel, Description__c, imageUrl__c FROM Ramky_Projects__mdt WHERE MasterLabel IN: proj];
        List<ProjectItem> listProjectItem = new List<ProjectItem>();
        for (Ramky_Projects__mdt matchedProduct : metaData) {
            ProjectItem projItems = new ProjectItem(
                matchedproduct.MasterLabel != null ? matchedProduct.MasterLabel : '',
                matchedProduct.Description__c != null ? matchedProduct.Description__c : '', 
                matchedProduct.imageUrl__c != null ? matchedProduct.imageUrl__c:''
            );
            listProjectItem.add(projItems);
        }
        response.projects = listProjectItem;
        
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');
    }
    
    global class ProjectResponseWrapper {
        public List<UpcomingProject> upcoming_projects;
        public List<ProjectItem> projects;
    }
    
    global class UpcomingProject {
        public String banner_image_url;
        public String project_Name;
        public String description;
        public String city;
        
        public UpcomingProject(String imageUrl, String websiteUrl, String des, String city) {
            this.banner_image_url = imageUrl;
            this.project_Name = websiteUrl;
            this.description = des;
            this.city = city;
        }
    }
    
    global class ProjectItem {
        public String name;
        public String description;
        public String image_url;
        
        public ProjectItem(String name, String description, String imageUrl) {
            this.name = name;
            this.description = description;
            this.image_url = imageUrl;
        }
    }
}