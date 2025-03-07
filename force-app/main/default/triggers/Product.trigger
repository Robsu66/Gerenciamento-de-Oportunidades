trigger Product on Product__c (after insert, after update) {
    if(Trigger.isInsert || Trigger.isUpdate){
        if(ProductTriggerAfterInsert.isAfterInsert){
            return;
        }
        ProductTriggerAfterInsert.isAfterInsert = true;
        ProductTriggerAfterInsert.ProductTriggerHandlers(Trigger.newMap.keySet());
    }
}