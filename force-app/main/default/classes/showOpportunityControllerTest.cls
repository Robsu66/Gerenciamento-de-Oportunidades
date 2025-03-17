@isTest
private class showOpportunityControllerTest {
    
    @TestSetup
    static void makeData() {
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
        List<Opportunity> result = showOpportunityController.getOpportunities();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'not null');
        System.assertEquals(1, result.size(), 'Deve ser igual');
        System.assertEquals('Test', result[0].Name, 'Deve ser igual');
        System.assertEquals('Prospecting', result[0].StageName, 'Deve ser igual');
        System.assertEquals(Date.today(), result[0].CloseDate, 'Deve ser igual');
        
        System.assertNotEquals(null, result[0].Products__r, 'not null');
        System.assertEquals(1, result[0].Products__r.size(), 'Deve ser igual');
        System.assertEquals('Test', result[0].Products__r[0].Name, 'Deve ser igual');
        System.assertEquals(2, result[0].Products__r[0].Quantity__c, 'Deve ser igual');
        System.assertEquals(500, result[0].Products__r[0].Price__c, 'Deve ser igual');
    }
}