trigger TriggerOnCase on Case (after insert, after update, before insert, before update) {
 CaseTriggerHeper handlerInstance = CaseTriggerHeper.getInstance();
        
        if(trigger.isBefore && trigger.isInsert){
            handlerInstance.onBeforeInsert(trigger.new);
        }
}