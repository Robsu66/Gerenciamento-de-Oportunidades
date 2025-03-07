public with sharing class ProductTriggerAfterInsert {
    public static boolean isAfterInsert = false;
    public static void ProductTriggerHandlers(Set<Id> prodId) {
        ProductTriggerHandlers.productTotalValueCalculator(prodId);
    }
}