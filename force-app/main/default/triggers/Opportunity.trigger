trigger Opportunity on Opportunity (after insert, after update) {
    if(Trigger.isInsert || Trigger.isUpdate){
        if(OpportunityTriggerAfterInsert.isAfterInsert){
            return;
        }
        OpportunityTriggerAfterInsert.isAfterInsert = true;
        OpportunityTriggerAfterInsert.OpportunityTriggerHandlers(Trigger.newMap.keySet());
    }
}