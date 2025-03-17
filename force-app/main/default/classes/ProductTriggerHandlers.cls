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

    private static void emailNotification(Id oppId) {
        List<Opportunity> oppList = [SELECT Id, Name, Amount, Owner.Email FROM Opportunity WHERE Id = :oppId];
        
        if (!oppList.isEmpty()) {
            Opportunity opp = oppList[0];
            if (opp.Owner.Email != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{opp.Owner.Email});
                email.setSubject('Oportunidade ' + opp.Name + ' Fechada com Sucesso!');
                email.setPlainTextBody('A oportunidade "' + opp.Name + '" atingiu um valor de ' + opp.Amount + 
                                       ' e foi marcada como "Fechado – Ganhou".');

                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            }
        }
    }
}