public with sharing class ProductTriggerHandlers {
    public static void productTotalValueCalculator(Set<Id> prodIds, Map<Id, Product__c> oldMap) {
        Map<Id, Decimal> opportunityMapToAmountDifference = new Map<Id, Decimal>();
        List<Id> emailIdList = new List<Id>();
        List<Product__c> newProducts = [SELECT Id, Quantity__c, Price__c, Opportunity__c FROM Product__c 
                                        WHERE Id IN :prodIds];
        
        for(Product__c newProd : newProducts) {
            if(newProd.Opportunity__c == null) {
                continue;
            }
            Decimal valueDifference = 0;
            
            if(oldMap == null || !oldMap.containsKey(newProd.Id)) {
                valueDifference = newProd.Quantity__c * newProd.Price__c;
            } 
            else {
                Product__c oldProd = oldMap.get(newProd.Id);
                
                if(newProd.Quantity__c != oldProd.Quantity__c) {
                    Decimal quantityDifference = newProd.Quantity__c - oldProd.Quantity__c;
                    valueDifference = quantityDifference * newProd.Price__c;
                }
                if(newProd.Price__c != oldProd.Price__c) {
                    valueDifference = valueDifference + (newProd.Price__c - oldProd.Price__c) * newProd.Quantity__c;
                }
            }
            
            if(valueDifference != 0) {
                if(!opportunityMapToAmountDifference.containsKey(newProd.Opportunity__c)) {
                    opportunityMapToAmountDifference.put(newProd.Opportunity__c, valueDifference);
                }
                else {
                    opportunityMapToAmountDifference.put(
                        newProd.Opportunity__c, 
                        valueDifference + opportunityMapToAmountDifference.get(newProd.Opportunity__c)
                    );
                }
            }
        }
        
        if(opportunityMapToAmountDifference.isEmpty()) {
            return;
        }
        List<Opportunity> opps = [SELECT Id, Amount, StageName FROM Opportunity 
                                  WHERE Id IN :opportunityMapToAmountDifference.keySet()];

        for(Opportunity opp : opps) {
            if(opportunityMapToAmountDifference.containsKey(opp.Id)) {
                if(opp.Amount != null) {
                    opp.Amount = opp.Amount + opportunityMapToAmountDifference.get(opp.Id);
                }
                else {
                    opp.Amount = opportunityMapToAmountDifference.get(opp.Id);
                }
                if(opp.Amount > 15000 && opp.StageName != 'Closed Won') {
                    opp.StageName = 'Closed Won';
                    emailIdList.add(opp.Id);
                }
            }
        }
        
        emailNotification(emailIdList);
        if(!opps.isEmpty()) {
            update opps;
        }
    }

    private static void emailNotification(List<Id> oppId) {
        List<Opportunity> oppList = [SELECT Id, Name, Amount, Owner.Email FROM Opportunity WHERE Id IN :oppId];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        if (!oppList.isEmpty()) {
            for (Opportunity opp : oppList) {
                if (opp.Owner.Email != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[]{opp.Owner.Email});
                    email.setSubject('Oportunidade ' + opp.Name + ' Fechada com Sucesso!');
                    email.setPlainTextBody('A oportunidade "' + opp.Name + '" atingiu um valor de ' + opp.Amount + 
                                           ' e foi marcada como "Fechado – Ganhou".');
                    emails.add(email);
                }
            }
        }
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
}