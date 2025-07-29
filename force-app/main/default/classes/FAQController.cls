/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-27-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
Global without sharing class FAQController {
     @AuraEnabled(cacheable=true)
    Global static Map<String, List<FAQ__c>> getFAQsByType() {
        Map<String, List<FAQ__c>> result = new Map<String, List<FAQ__c>>();
        for (FAQ__c faq : [SELECT Id, Question__c, Answer__c, Type__c, Active__c FROM FAQ__c WHERE Active__c = TRUE ]) {
            if (!result.containsKey(faq.Type__c)) {
                result.put(faq.Type__c, new List<FAQ__c>());
            }
            result.get(faq.Type__c).add(faq);
        } 
        return result;
    }
}