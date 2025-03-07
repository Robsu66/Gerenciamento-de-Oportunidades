public with sharing class OpportunityProductController {
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities() {
        return [
            SELECT Id, Name, StageName, Amount, CloseDate
            FROM Opportunity
            ORDER BY CreatedDate DESC
            LIMIT 100
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Product__c> getOpportunityProducts(String opportunityId) {
        return [
            SELECT Id, Name, Price__c, Quantity__c, Opportunity__c
            FROM Product__c
            WHERE Opportunity__c = :opportunityId
            ORDER BY CreatedDate DESC
        ];
    }
}

