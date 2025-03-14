public with sharing class showOpportunityController {
    
    @AuraEnabled(cacheable = true)
    public static List<Opportunity> getOpportunities() {
        return [SELECT id, Name, Amount, StageName, CloseDate, (SELECT id, Name, Quantity__c, Price__c FROM Products__r) 
                FROM Opportunity];
    }

    // @AuraEnabled(cacheable = true)
    // public static List<Product__c> getProducts(List<Id> opportunityIds) {
    //     return [SELECT Id, Name, Quantity__c, Price__c, Opportunity__c 
    //             FROM Product__c WHERE Opportunity__c IN :opportunityIds];
    // }
}