public with sharing class OpportunityTriggerHandlers {
    public opportunityTotalValueCalculator(Set<Id> oppId) {

        Map<String, Decimal> opportunityMapToAmount = new Map<String, Decimal>();

        List<Product__c> products = [SELECT Id, Quantity__c, Price__c FROM Product__c WHERE Opportunity__r IN: oppId];
        
        
        for(Product__c prod : products){
            if(!opportunityMapToAmount.containsKey(prod.Opportunity__c)){
                opportunityMapToAmount.put(prod.Opportunity__c, prod.Quantity__c * prod.Price__c);
            }
            else{
                opportunityMapToAmount.put(p.Opportunity__c, (prod.Quantity__c * prod.Price__c) + opportunityMapToAmount.get(prod.Opportunity__c));
            }
        }

        List<Opportunity> OppsToUpdate = new List<Opportunity>();
        List<Opportunity> opps = [SELECT Id, Amount FROM Opportunity WHERE Id IN: opportunityMapToAmount.keySet()];

        for(Opportunity opp : opps){
            if(opportunityMapToAmount.containsKey(opp.Id)){
                opp.Amount = opportunityMapToAmount.get(opp.Id);
                opp.StageName = 'Closed Won';
            }
        }
        if(!oppsToUpdate.isEmpty()){
            update opps;
        }
    }


    private static void emailNotification(){

    }
}