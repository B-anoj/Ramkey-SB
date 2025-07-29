public class CostSheetRetrivingClass {
    
    public static void PaymentScheduleToCostSheet(List<Cost_Sheet__c> csList) {
        Set<Id> Ids = new set<Id>();
        for(Cost_Sheet__c cs:csList){
            Ids.add(cs.Opportunity__c);
        }
        
        
      /*  List<Payment_Schedule__c> psLineItems = [SELECT Id, Amount__c, Amount_In_Local_Currency__c, Payment_Particulars__c, Payment_Schedule_Type__c,
                                                 Project__c, Sales_Office__c, Sales_Organization__c, Opportunity__c
                                                             FROM Payment_Schedule__c
                                                             WHERE Opportunity__c =:Ids];
        system.debug('retriving data'+psLineItems);
        
        List<Cost_Sheet_Line_Items__c> CSLineItemsToInsert = new List<Cost_Sheet_Line_Items__c>();
        for(Cost_Sheet__c cs:csList){
            
            for (Payment_Schedule__c ps : psLineItems) {
                if(ps.Opportunity__c == cs.Opportunity__c){
                    Cost_Sheet_Line_Items__c csli = new Cost_Sheet_Line_Items__c(
                        Cost_Sheet__c =cs.Id,
                        Amount__c = ps.Amount__c,
                        Amount_In_Local_Currency__c = ps.Amount_In_Local_Currency__c,
                        Payment_Particulars__c = ps.Payment_Particulars__c,
                        Payment_Schedule_Type__c = ps.Payment_Schedule_Type__c,
                        Project__c = ps.Project__c,
                        Sales_Office__c = ps.Sales_Office__c,
                        Sales_Organization__c = ps.Sales_Organization__c,
                        Opportunity_Name__c = ps.Opportunity__c);      
                    CSLineItemsToInsert.add(csli);
                    system.debug('Cost Sheet Line Item added: ' + csli);
                }
            }
        }
        
        if (!CSLineItemsToInsert.isEmpty()) {
            insert CSLineItemsToInsert;
            system.debug('Cost Sheet Line Items inserted successfully');
        }*/
    }
}