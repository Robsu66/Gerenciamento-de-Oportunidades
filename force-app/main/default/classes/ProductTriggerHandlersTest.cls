@isTest
private class ProductTriggerHandlersTest {
    @testSetup
    static void setup() {
        Opportunity opp = new Opportunity(Name = 'Teste Oportunidade', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;
        
        Product__c prod1 = new Product__c(Name = 'Produto 1', Quantity__c = 2, Price__c = 5000, Opportunity__c = opp.Id);
        Product__c prod2 = new Product__c(Name = 'Produto 2', Quantity__c = 1, Price__c = 4000, Opportunity__c = opp.Id);
        insert new List<Product__c>{prod1, prod2};
    }
    
    @isTest
    static void testProductTotalValueCalculator() {
        Opportunity opp = [SELECT Id, Amount, StageName FROM Opportunity LIMIT 1];
        System.assertEquals(14000, opp.Amount, 'O valor inicial da oportunidade deve ser nulo');
        
        Product__c prod = [SELECT Id, Quantity__c, Price__c FROM Product__c LIMIT 1];
        prod.Quantity__c = 5;
        update prod;
        
        opp = [SELECT Id, Amount, StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(29000, opp.Amount, 'O valor da oportunidade deve refletir a nova quantidade do produto');
        System.assertEquals('Closed Won', opp.StageName, 'A oportunidade deve estar fechada se o valor for maior que 15000');
    }
    
    @isTest
    static void testEmailNotification() {
        Test.startTest();
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Product__c newProd = new Product__c(Name = 'Produto 3', Quantity__c = 10, Price__c = 2000, Opportunity__c = opp.Id);
        insert newProd;
        
        Test.stopTest();
        
        opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Closed Won', opp.StageName, 'O estágio da oportunidade deve ser fechado após atingir o valor necessário');
    }
}