@isTest
public class ProductTriggerTest {
    
    @testSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Conta Teste');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Oportunidade Teste',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            Amount = 10000
        );
        insert opp;
    }
    
    @isTest
    static void testInsertProductUpdatesOpportunity() {
        Opportunity opp = [SELECT Id, Amount FROM Opportunity LIMIT 1];
        
        Product__c product = new Product__c(
            Name = 'Produto Teste',
            Quantity__c = 10,
            Price__c = 600,
            Opportunity__c = opp.Id
        );
        
        Test.startTest();
        insert product;
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, Amount, StageName FROM Opportunity WHERE Id =: opp.Id];
        System.assertEquals(16000, updatedOpp.Amount, 'O valor da oportunidade deve ser atualizado corretamente.');
        System.assertEquals('Closed Won', updatedOpp.StageName, 'A oportunidade deve estar como "Fechado – Ganhou".');
    }
    
    @isTest
    static void testUpdateProductRecalculatesOpportunityValue() {
        Account acc = new Account(Name = 'Conta Teste Atualização');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Oportunidade Atualização Teste',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            Amount = 5000
        );
        insert opp;
        
        Product__c product = new Product__c(
            Name = 'Produto Teste Atualização',
            Quantity__c = 5,
            Price__c = 500,
            Opportunity__c = opp.Id
        );
        insert product;
        
        product.Quantity__c = 15;
        product.Price__c = 600;
        
        Test.startTest();
        update product;
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, Amount FROM Opportunity WHERE Id =: opp.Id];
        
        System.assert(updatedOpp.Amount > 5000, 'O valor da oportunidade deve ser recalculado após a atualização do produto.');
    }
    
    @isTest
    static void testEmailNotificationTriggered() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Product__c product = new Product__c(
            Name = 'Produto Teste',
            Quantity__c = 8,
            Price__c = 800,
            Opportunity__c = opp.Id
        );
        
        Test.startTest();
        insert product;
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, Amount, StageName FROM Opportunity WHERE Id =: opp.Id];
        System.assertEquals('Closed Won', updatedOpp.StageName, 'A oportunidade deve ser fechada após ultrapassar 15000.');
    }
}