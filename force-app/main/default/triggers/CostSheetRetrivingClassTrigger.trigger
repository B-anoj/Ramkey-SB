trigger CostSheetRetrivingClassTrigger on Cost_Sheet__c (After insert) {

    if(trigger.isAfter && trigger.isInsert){
            CostSheetRetrivingClass.PaymentScheduleToCostSheet(trigger.new);
        }
}