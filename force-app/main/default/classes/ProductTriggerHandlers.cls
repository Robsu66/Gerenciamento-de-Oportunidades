public with sharing class ProductTriggerHandlers {
    public static void productTotalValueCalculator(Set<Id> prodId) {
        Map<Id, Decimal> opportunityMapToAmount = new Map<Id, Decimal>();

        List<Product__c> products  = [SELECT Id, Quantity__c, Price__c, Opportunity__c FROM Product__c WHERE Id =: prodId];

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
                if(opp.Amount != null){
                    opp.Amount = opp.Amount + opportunityMapToAmount.get(opp.Id);
                }
                else{
                    opp.Amount = opportunityMapToAmount.get(opp.Id);
                }

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
        Opportunity opp = [SELECT Id, Owner.Email, Amount FROM Opportunity WHERE Id =: oppId];

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{opp.Owner.Email});
        email.setSubject('Oportunidade Fechada com Sucesso!');
        email.setPlainTextBody('A oportunidade ' + opp.Id + ' atingiu um valor de ' + opp.Amount + ' e foi marcada como "Fechado – Ganhou".');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}