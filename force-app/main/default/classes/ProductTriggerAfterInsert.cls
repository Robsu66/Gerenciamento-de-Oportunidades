public with sharing class ProductTriggerAfterInsert {
    public static boolean isAfterInsert = false;
    
    public static void ProductTriggerHandlers(Set<Id> prodIds, Map<Id, Product__c> oldMap) {
        ProductTriggerHandlers.productTotalValueCalculator(prodIds, oldMap);
    }
}