trigger LeadCompanyNameChangeTrigger on Lead (before insert, before Update) { 
     
    if (Trigger.isBefore && Trigger.isInsert) {
        LeadCompanyNameChangeHandler.updateLead(Trigger.new);
    }  
}