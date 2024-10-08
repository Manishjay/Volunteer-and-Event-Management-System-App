public with sharing class EventRegistrationController {
    @AuraEnabled(cacheable=true)
    public static List<Event__c> getAvailableEvents() {
        return [SELECT Id, Name, Event_Date__c, Location__c, Description__c FROM Event__c WHERE Status__c = 'Open For Registration'];
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getRolePicklistValues() {
        Map<String, String> roleOptions = new Map<String, String>();
        
        // Describe the field to get picklist values
        Schema.DescribeFieldResult fieldResult = Volunteer_Event__c.Role__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        // Populate the map with picklist label as the key and value as the value
        for (Schema.PicklistEntry entry : picklistEntries) {
            roleOptions.put(entry.getLabel(), entry.getValue());
        }
        
        return roleOptions;
    }

    @AuraEnabled
    public static void registerVolunteer(Id eventId, String role, Id VolunteerId ) {
        Volunteer_Event__c volunteerEvent = new Volunteer_Event__c();
        volunteerEvent.Volunteer__c = VolunteerId;
        volunteerEvent.Event__c = eventId;
        volunteerEvent.Role__c = role;
        volunteerEvent.Status__c = 'Registered';
        insert volunteerEvent;
    }
}