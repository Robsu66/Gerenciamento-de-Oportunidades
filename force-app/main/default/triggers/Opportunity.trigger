trigger Opportunity on SOBJECT (after insert, after update) {
    if(Trigger.isInsert || Trigger.isUpdate){
        OpportunityTriggerHandler(Trigger.newMap.keySet())
    }
}