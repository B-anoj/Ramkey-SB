trigger TrackLeadOwnerChanges on Lead (before insert, before update) {
    if (Trigger.isInsert) {
        LeadOwnerChangeHandler.trackOwnerChangesOnInsert(Trigger.new);
    } else if (Trigger.isUpdate) {
        LeadOwnerChangeHandler.trackOwnerChangesOnUpdate(Trigger.new, Trigger.oldMap);
    }
}