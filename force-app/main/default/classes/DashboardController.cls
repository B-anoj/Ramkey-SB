@RestResource(urlMapping='/service')
Global without sharing class DashboardController {
    @HttpGet()
    global static void getServiceDetails() {
        try {
            List<Service__c> services = [
                SELECT Id, Name, Type__c, Phone__c,
                Address__Street__s, Address__City__s, Address__StateCode__s,
                Address__PostalCode__s, Address__CountryCode__s
                FROM Service__c
                
            ];
            
            List<ServiceWrapper> serviceList = new List<ServiceWrapper>();
            
            for (Service__c s : services) {
                ServiceWrapper sw = new ServiceWrapper();
                sw.service_title = s.Name != null ? s.Name : '';
                sw.service_item = s.Type__c != null ? s.Type__c : '';
                sw.address = 
                    (s.Address__Street__s != null ? s.Address__Street__s + ', ' : '') +
                    (s.Address__City__s != null ? s.Address__City__s + ', ' : '') +
                    (s.Address__StateCode__s != null ? s.Address__StateCode__s + ' ' : '') +
                    (s.Address__PostalCode__s != null ? s.Address__PostalCode__s + ', ' : '') +
                    (s.Address__CountryCode__s != null ? s.Address__CountryCode__s : '');
                
                sw.phone = s.Phone__c != null ? s.Phone__c : '';
                serviceList.add(sw);
            }
            
            // Wrap in root object
            ServiceResponseWrapper responseWrapper = new ServiceResponseWrapper();
            responseWrapper.services = serviceList;
            
            // Set JSON response
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statusCode = 200;
            
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            RestContext.response.responseBody = Blob.valueOf('{"error":"Internal server error"}');
            RestContext.response.statusCode = 500;
        }
    }
    
    // Root response wrapper
    public class ServiceResponseWrapper {
        public List<ServiceWrapper> services;
    }
    
    // Single service record wrapper
    public class ServiceWrapper {
        public String service_title;
        public String service_item;
        public String address;
        public String phone;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Construction_Update__c> getLastSixMonthsData() {
        try{
            Date today = Date.today();
            System.debug('today====>'+today);
            Date sixMonthsAgo = today.addMonths(-5).toStartOfMonth();
            System.debug('sixMonthsAgo====>'+sixMonthsAgo);
            List<Construction_Update__c> constructionUpdateList = [SELECT Percent__c, Update_Month__c,Project__c FROM Construction_Update__c 
                                                                   WHERE Update_Month__c >= :sixMonthsAgo ORDER BY Update_Month__c ASC];
            System.debug('constructionUpdateList====>'+constructionUpdateList);
            return constructionUpdateList;
        }
        catch(Exception e){
            System.debug('Error at Line Number======> ' + e.getLineNumber() + 'Error Message=====> ' + e.getMessage());
            return new List<Construction_Update__c>();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Construction_Update__c>> getLastSixMonthsData1() {
        Map<String, List<Construction_Update__c>> projectMap = new Map<String, List<Construction_Update__c>>();
        try {
            Date today = Date.today();
            Date sixMonthsAgo = today.addMonths(-5).toStartOfMonth();
            
            List<Construction_Update__c> allUpdates = [
                SELECT Id, Percent__c, Update_Month__c, Project__c
                FROM Construction_Update__c
                WHERE Update_Month__c >= :sixMonthsAgo
                AND Project__c != null
                ORDER BY Project__c, Update_Month__c,Percent__c];
            
            System.debug('All updates size===> ' + allUpdates.size());
            Set<String> uniqueProjects = new Set<String>();
            
            for (Construction_Update__c updates : allUpdates) {
                String projectKey = updates.Project__c.trim();
                uniqueProjects.add(projectKey);
                
                if (!projectMap.containsKey(projectKey)) {
                    projectMap.put(projectKey, new List<Construction_Update__c>());
                }
                projectMap.get(projectKey).add(updates);
            }
            System.debug('Unique Project__c values: ' + uniqueProjects);
            System.debug('Final grouped map===> ' + projectMap);
            
            // for (String key : projectMap.keySet()) {
            //     List<Construction_Update__c> updatesList = projectMap.get(key);
            //     updatesList.sort(new ConstructionUpdatePercentComparator());
            //     }
            
            
            return projectMap;
        } catch (Exception e) {
            System.debug('Error at Line Number======> ' + e.getLineNumber() + 'Error Message=====> ' + e.getMessage());
            return new Map<String, List<Construction_Update__c>>();
        }
    }
    
    // @AuraEnabled(cacheable=true)
    // public static List<BankWrapper> getBankingPartners() {
    //     try {
    //         List<Banking_Partner__c> banks = [
    //             SELECT Id, Name, Locality__c 
    //             FROM Banking_Partner__c
    //         ];
    //         List<Id> bankIds = new List<Id>();
    //         if(banks != null){
    //             for (Banking_Partner__c bp : banks) {
    //                 bankIds.add(bp.Id);
    //             }
    //         }
    //         List<BankWrapper> result = new List<BankWrapper>();
    //         for (Banking_Partner__c bp : banks) {
    //             result.add(new BankWrapper(bp.Id, bp.Name, bp.Locality__c, bp.Image_Url__c));
    //         }
    //         System.debug('result=====>'+result);
    //         return result;
    //     } catch (Exception e) {
    //         System.debug('Error at Line Number: ' + e.getLineNumber() + ' | Message: ' + e.getMessage());
    //         return new List<BankWrapper>();
    //     }
    // }
    
 @AuraEnabled(cacheable=true)
public static List<Banking_Partner__c> getBankingPartners() {
    try {
        List<Banking_Partner__c> banks = [
            SELECT Id, Name, Locality__c, Image_Url__c
            FROM Banking_Partner__c
        ];
        System.debug('Banking Partners => ' + banks);
        return banks;
    } catch (Exception e) {
        System.debug('Error: ' + e.getMessage());
        return new List<Banking_Partner__c>();
    }
}


    public class BankWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String locality;
        @AuraEnabled public String fileUrl;
        
        public BankWrapper(String id, String name, String locality, String fileUrl) {
            this.id = id;
            this.name = name;
            this.locality = locality;
            this.fileUrl = fileUrl;
        }
    }
    @AuraEnabled
    public static List<Ramky_Projects__mdt> getProjectDetails(String userEmail) {
        List<Ramky_Projects__mdt> metaList = new  List<Ramky_Projects__mdt>();
        try {
            List<Booking_Form__c> existMatchedDetails = [SELECT Id, Opportunity__r.Account.Email__c, Project_Name__c FROM Booking_Form__c WHERE Opportunity__r.Account.Email__c =:userEmail];
            System.debug('meexistMatchedDetailstaList=====>'+existMatchedDetails);
            Set<String> projectName = new Set<String>();
            if (existMatchedDetails != null) {
                for (Booking_Form__c iterateOpp : existMatchedDetails) {
                    projectName.add(iterateOpp.Project_Name__c);
                }
                System.debug('projectName=====>'+projectName);
                metaList = [
                    SELECT MasterLabel, imageURL__c
                    FROM Ramky_Projects__mdt
                    WHERE MasterLabel IN :projectName
                ];
                System.debug('metaList=====>'+metaList);
                System.debug('metaList imageurl size=====>'+metaList.size());
                System.debug('metaList imageurl=====>'+metaList[0].imageURL__c);
            } else {
                System.debug('Opportunity Not available Provided URL');
            }
        } Catch (Exception ex) {
            System.debug('Error at Line Number======> ' + ex.getLineNumber() + 'Error Message=====> ' + ex.getMessage());
        }
        return metaList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Service__c> getService() {
        try{
            List<Service__c> serviceList = [SELECT Id, Name, Type__c, Address__c, Phone__c,Address__Street__s, Address__City__s,
                                            Address__StateCode__s, Address__PostalCode__s, Address__CountryCode__s FROM Service__c];
            System.debug('serviceList======>'+serviceList);
            return serviceList;
        }catch (Exception e) {
            System.debug('Error at Line Number=====> ' + e.getLineNumber() + 'Error  Message====> ' + e.getMessage());
            return new List<Service__c>();
        }       
    }
}