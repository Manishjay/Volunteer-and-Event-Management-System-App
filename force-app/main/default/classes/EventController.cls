public with sharing class EventController {
    @AuraEnabled(cacheable=true)
    public static List<Event__c> getEvents() {
        return [SELECT Id, Name, Event_Date__c, Location__c, Description__c
                FROM Event__c
                WHERE Status__c = 'Open for Registration'];
    }
}