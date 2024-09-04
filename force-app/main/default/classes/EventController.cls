public with sharing class EventController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getEvents() {
        List<Map<String, Object>> eventsWithRoles = new List<Map<String, Object>>();

        // Query to get Event details and related Volunteer_Event__c roles
        List<Event__c> events = [
            SELECT Id, 
                   Name, 
                   Location__c, 
                   (SELECT Id, Role__c FROM Volunteer_Events__r) 
            FROM Event__c 
        ];

        for (Event__c event : events) {
            // Get distinct roles associated with the event
            Set<String> roles = new Set<String>();
            for (Volunteer_Event__c volunteerEvent : event.Volunteer_Events__r) {
                roles.add(volunteerEvent.Role__c);
            }

            // Create a map for each event
            Map<String, Object> eventData = new Map<String, Object>{
                'eventId' => event.Id,
                'eventName' => event.Name,
                'location' => event.Location__c,
                'roles' => new List<String>(roles)
            };

            eventsWithRoles.add(eventData);
        }

        return eventsWithRoles;
    }
}
