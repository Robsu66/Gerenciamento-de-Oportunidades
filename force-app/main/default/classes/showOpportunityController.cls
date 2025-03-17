public with sharing class showOpportunityController {

    @AuraEnabled(cacheable = true)
    public static List<Opportunity> getOpportunities(Integer pageSize, Integer pageNumber) {
        Integer offset = (pageNumber - 1) * pageSize;
        return [SELECT id, Name, Amount, StageName, CloseDate, (SELECT id, Name, Quantity__c, Price__c FROM Products__r) 
                FROM Opportunity ORDER BY Name ASC LIMIT : (pageSize + 1) OFFSET: offset];
    }
}