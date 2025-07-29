trigger VisitTrigger on Visit__c (After Update) {
    if (trigger.isAfter && trigger.IsUpdate) {
        API_Customer_Visit.importVisitQueries(trigger.new);
    }

}