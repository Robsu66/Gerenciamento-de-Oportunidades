@isTest
private class showOpportunityControllerTest {
    
    @TestSetup
    static void makeData(){
        Opportunity opp = new Opportunity(
            Name = 'Test',
            StageName = 'Prospecting',
            Amount = 1000,
            CloseDate = Date.today()
        );
        insert opp;
        
        Product__c prod = new Product__c(
            Name = 'Test',
            Quantity__c = 2,
            Price__c = 500,
            Opportunity__c = opp.Id
        );
        insert prod;
    }
    
    @isTest
    static void getOpportunitiesTest() {
        
        Test.startTest();
        List<Opportunity> result = new List<Opportunity> (showOpportunityController.getOpportunities());
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'not null');
        System.assertEquals('Test', result[0].Name, 'Deve ser igual');
        System.assertEquals('Prospecting', result[0].StageName, 'Deve ser igual');
        System.assertEquals(Date.today(), result[0].CloseDate, 'Deve ser igual');
    }
    
    @isTest
    static void getProductsTest() {
        List<Opportunity> testOpp = new List<Opportunity> ([SELECT Id FROM Opportunity LIMIT 1]);
        List<Id> testOppId = new List<Id>{testOpp[0].Id};
        
        Test.startTest();
        List<Product__c> result = new List <Product__c> (showOpportunityController.getProducts(testOppId));
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'not null');
        System.assertEquals('Test', result[0].Name, 'Deve ser igual');
        System.assertEquals(2, result[0].Quantity__c, 'Deve ser igual');
        System.assertEquals(500, result[0].Price__c, 'Deve ser igual');
        System.assertEquals(testOpp[0].Id, result[0].Opportunity__c, 'Deve ser igual');
    }
}