public with sharing class showOpportunityController {

    @AuraEnabled(cacheable = true)
    public static List<Opportunity> getOpportunities() {
        return [SELECT id, Name, Amount, StageName, CloseDate, (SELECT id, Name, Quantity__c, Price__c FROM Products__r) 
                FROM Opportunity];
    }
}