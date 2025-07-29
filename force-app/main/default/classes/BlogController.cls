/**
* @File Name : BlogController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : July 7, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | July 7, 2025 |   | Initial Version
**/
@RestResource(urlMapping='/blogs')
Global without sharing class BlogController {
    @HttpGet
    global static void fetchblogDetails() {
        try {
            List<Blog__c> bloglist =  [SELECT Id, Subject__c, Description__c, ImageUrl__c, CreatedDate, Subtitle__c 
                                       FROM Blog__c ORDER BY CreatedDate DESC];
            List<ServiceWrapper> wrapper = new List<ServiceWrapper>();
            for (Blog__c iterateData : blogList) {
                ServiceWrapper dataWrapper = new ServiceWrapper();
                dataWrapper.title = iterateData.Subtitle__c != null ? iterateData.Subtitle__c : '';
                dataWrapper.description = iterateData.Description__c != null ? iterateData.Description__c : '';
                dataWrapper.brand = 'Ramky Group';
                dataWrapper.subtitle = iterateData.subject__c != null ? iterateData.subject__c : '';
                dataWrapper.createdDate = Date.Valueof(iterateData.CreatedDate);
                dataWrapper.image_url = iterateData.ImageUrl__c;
                wrapper.add(dataWrapper);
            }
            blogsData responseWrapper = new blogsData();
            responseWrapper.blogs = wrapper;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statusCode = 200;
        } Catch (Exception ex) {
            RestContext.response.responseBody = Blob.valueOf(ex.getMessage());
            System.debug('Error Message =' + ex.getMessage());
        }
    }
    public class blogsData {
        public List<ServiceWrapper> blogs;
    }
    
    public class ServiceWrapper {
        public String title;
        public String description;
        public String brand;
        public Date createdDate;
        public String image_url;
        public String subtitle;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Blog__c> getBlogPosts() {
        try{
            List<Blog__c> bloglist =  [SELECT Id, Subject__c, Description__c, ImageUrl__c, CreatedDate 
                                       FROM Blog__c ORDER BY CreatedDate DESC];
            return bloglist;
        }catch(Exception e){
            System.debug('Error at Line Number======> ' + e.getLineNumber() + 'Error Message=====> ' + e.getMessage());
            return new List<Blog__c>();
        }
        
    } 
}