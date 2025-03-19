trigger Product on Product__c (after insert, after update) {
    if(Trigger.isInsert || Trigger.isUpdate){
        if(ProductTriggerAfterInsert.isAfterInsert){
            return;
        }
        ProductTriggerAfterInsert.isAfterInsert = true;
        
        Set<Id> productIds = Trigger.newMap.keySet();
        Map<Id, Product__c> oldMap = Trigger.isUpdate ? Trigger.oldMap : null;
        
        ProductTriggerAfterInsert.ProductTriggerHandlers(productIds, oldMap);
    }
}