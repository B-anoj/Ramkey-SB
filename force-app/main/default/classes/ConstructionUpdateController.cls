public without sharing class ConstructionUpdateController {

    public class ProjectCardWrapper {
        @AuraEnabled public String projectName;
        @AuraEnabled public String description;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public String propertyAddress;
    } 

    public class MonthUpdateWrapper {
        @AuraEnabled public String month;
        @AuraEnabled public List<String> imageUrls;
    }

    @AuraEnabled(cacheable=true)
    public static List<ProjectCardWrapper> getAllowedProjectsForUser() {
        String contactEmail = 'dhayalan2531@gmail.com';

        Contact con = [
            SELECT Account.Projects__c
            FROM Contact
            WHERE Email = :contactEmail
            LIMIT 1
        ];
        List<Booking_Form__c> customerBooking = [SELECT id, Project_Name__c FROM Booking_Form__c WHERE Opportunity__r.Account.Email__c =: contactEmail];
        Set<String> projectList = new Set<String>();
        for (Booking_Form__c iterateProjs : customerBooking) {
            projectList.add(iterateProjs.Project_Name__c);
        }

        if (con.Account == null || String.isBlank(con.Account.Projects__c)) {
            return new List<ProjectCardWrapper>();
        }
        List<Ramky_Projects__mdt> metaList = [
            SELECT MasterLabel, Description__c, staticResourceName__c, Property_Address__c
            FROM Ramky_Projects__mdt
            WHERE MasterLabel IN :projectList
        ];

        String baseUrl = URL.getOrgDomainUrl().toExternalForm();

        List<ProjectCardWrapper> result = new List<ProjectCardWrapper>();
        for (Ramky_Projects__mdt m : metaList) {
            ProjectCardWrapper p = new ProjectCardWrapper();
            p.projectName = m.MasterLabel;
            p.description = m.Description__c;
            p.propertyAddress = m.Property_Address__c;
            p.imageUrl = !String.isBlank(m.staticResourceName__c)
                ? baseUrl + '/resource/' + m.staticResourceName__c
                : '';
            result.add(p);
        }

        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<MonthUpdateWrapper> getUpdatesByProject(String projectName) {
        // Step 1: Fetch construction update records
        List<Construction_Update__c> updates = [
            SELECT Id, Update_Month__c, Image_Url__c
            FROM Construction_Update__c
            WHERE Project__c =:projectName
            AND Update_Month__c >= :Date.today().addMonths(-4)
            ORDER BY Update_Month__c ASC
        ];

        
        if (updates.isEmpty()) return new List<MonthUpdateWrapper>();
        
        // Step 2: Group by month using Image_Url__c
        Map<String, List<String>> monthToImages = new Map<String, List<String>>();
        
        for (Construction_Update__c cu : updates) {
            if (cu.Update_Month__c == null) continue;
            
            String monthLabel = getMonthName(cu.Update_Month__c.month()) + ' ' + cu.Update_Month__c.year();
            
            if (!monthToImages.containsKey(monthLabel)) {
                monthToImages.put(monthLabel, new List<String>());
            }
            
            List<String> imgList = monthToImages.get(monthLabel);
            
            if (!String.isBlank(cu.Image_Url__c)) {
                List<String> urls = cu.Image_Url__c.split(',');
                for (String url : urls) {
                    String trimmed = url.trim();
                    if (!String.isBlank(trimmed)) {
                        imgList.add(trimmed);
                    }
                }
            }
        }
        
        // Step 3: Wrap into MonthUpdateWrapper
        List<MonthUpdateWrapper> result = new List<MonthUpdateWrapper>();
        for (String month : monthToImages.keySet()) {
            MonthUpdateWrapper mw = new MonthUpdateWrapper();
            mw.month = month;
            mw.imageUrls = monthToImages.get(month);
            result.add(mw);
        }
        
        return result;
    }


    private static String getMonthName(Integer monthNum) {
        List<String> names = new List<String>{
            '', 'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        };
        return (monthNum != null && monthNum > 0 && monthNum < names.size() ) ? names[monthNum] : 'Unknown';
    }


        @AuraEnabled(cacheable=true)
         public static List<Upcoming_Project__c> getUpcomingProjects() {
        try{
            List<Upcoming_Project__c> upcomingprojectlist =  [SELECT Id, Name, City__c, Description__c, Project_Image_Url__c FROM Upcoming_Project__c];
            System.debug('upcomingprojectlist===>'+upcomingprojectlist);
            return upcomingprojectlist;
        }
          catch(Exception e){
            System.debug('Error at Line Number======> ' + e.getLineNumber() + 'Error Message=====> ' + e.getMessage());
            return new List<Upcoming_Project__c>();
        }
        }

}