@isTest
public class LeadCompanyNameChangeHandlerTest {

    @isTest
    public static void updateLeadWithFullNameTest() {
       
        Lead testLead = new Lead();
        testLead.FirstName = 'Rahul';
        testLead.LastName = 'Daggani';
        testLead.Company = 'Test Company';
        insert testLead;

        Test.startTest();
        LeadCompanyNameChangeHandler.updateLead(new List<Lead>{ testLead });
        Test.stopTest();  
        
        Lead updatedLead = [SELECT Id, Company FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Rahul Daggani', updatedLead.Company, 'Company name should be concatenated First Name and Last Name');
    }
    
    @isTest
    public static void updateLeadWithLastNameTest() {
       
        Lead testLead = new Lead();
        testLead.FirstName = null;
        testLead.LastName = 'Daggani';
        testLead.Company = 'Test Company';
        insert testLead;

        Test.startTest();
        LeadCompanyNameChangeHandler.updateLead(new List<Lead>{ testLead });
        Test.stopTest();  
        
        Lead updatedLead = [SELECT Id, Company FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Daggani', updatedLead.Company, 'Company name should be concatenated First Name and Last Name');
    }
}