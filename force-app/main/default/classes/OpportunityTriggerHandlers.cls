public with sharing class OpportunityTriggerHandlers {
    public static void opportunityTotalValueCalculator(Set<Id> oppId) {

        Map<String, Decimal> opportunityMapToAmount = new Map<String, Decimal>();

        List<Product__c> products = [SELECT Id, Quantity__c, Price__c FROM Product__c WHERE Opportunity__c =: oppId];
        
        
        for(Product__c prod : products){
            if(!opportunityMapToAmount.containsKey(prod.Opportunity__c)){
                opportunityMapToAmount.put(prod.Opportunity__c, prod.Quantity__c * prod.Price__c);
            }
            else{
                opportunityMapToAmount.put(prod.Opportunity__c, (prod.Quantity__c * prod.Price__c) + opportunityMapToAmount.get(prod.Opportunity__c));
            }
        }

        List<Opportunity> opps = [SELECT Id, Amount FROM Opportunity WHERE Id IN: opportunityMapToAmount.keySet()];

        for(Opportunity opp : opps){
            if(opportunityMapToAmount.containsKey(opp.Id)){
                opp.Amount = opportunityMapToAmount.get(opp.Id);
                if(opp.Amount > 15000){
                    opp.StageName = 'Closed Won';
                    emailNotification(opp.Id);
                }
            }
        }
        if(!opps.isEmpty()){
            update opps;
        }
    }

    private static void emailNotification(Id oppId){
        Opportunity opp = [SELECT Id, Owner.Email FROM Opportunity WHERE Id =: oppId];

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{opp.Owner.Email});
        email.setSubject('Oportunidade Fechada com Sucesso!');
        email.setPlainTextBody('A oportunidade ' + opp.Id + ' atingiu um valor de ' + opp.Amount + ' e foi marcada como "Fechado – Ganhou".');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}