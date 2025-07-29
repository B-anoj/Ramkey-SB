@isTest
public class LeadFromGoogleTriggerTest {
    
    @isTest
    static void testDuplicateLeadDeletion() {
        // Test setup: create leads with 'Google' as Lead_Sub_Source__c
       List<Lead> leads = new List<Lead>();


leads.add(new Lead(LastName = 'Test1', Company = 'Test Company 1', Phone = '1234567890', Projects__c = 'Ramky One Symphony',  LeadSource='Digital Campaign', Lead_Sub_Source__c = 'Google'));
leads.add(new Lead(LastName = 'Test2', Company = 'Test Company 2', Phone = '1234567890', Projects__c = 'Ramky One Symphony',  LeadSource='Digital Campaign', Lead_Sub_Source__c = 'Google')); 
leads.add(new Lead(LastName = 'Test3', Company = 'Test Company 3', Phone = '1234567890', Projects__c = 'Ramky One Symphony',  LeadSource='Digital Campaign', Lead_Sub_Source__c = 'Google'));
leads.add(new Lead(LastName = 'Test4', Company = 'Test Company 4', Phone = '1234567890', Projects__c = 'Ramky One Symphony', LeadSource='Digital Campaign', Lead_Sub_Source__c = 'Google'));
        Test.startTest();
        // Insert leads
        insert leads;
        Test.stopTest();

        // Query the leads to verify the correct ones are deleted
        List<Lead> remainingLeads = [SELECT Id, LastName, Phone, Projects__c FROM Lead WHERE Lead_Sub_Source__c = 'Google'];
       

        
       
    }
}