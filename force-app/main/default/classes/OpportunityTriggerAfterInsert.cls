public with sharing class OpportunityTriggerAfterInsert {
    public static boolean isAfterInsert = false;
    public static void OpportunityTriggerHandlers(Set<Id> oppId) {
        OpportunityTriggerHandlers.opportunityTotalValueCalculator(oppId);
    }
}