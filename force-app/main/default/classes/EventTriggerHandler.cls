public with sharing class EventTriggerHandler {

    // To update Event Status within 30 days
    public static void handleBeforeUpdate(List<Event__c> newEvents, Map<Id, Event__c> oldEventMap) {
        for (Event__c event : newEvents) {
            Event__c oldEvent = oldEventMap.get(event.Id);
            if (event.Event_Date__c != null && event.Status__c == 'Planned' && 
                event.Event_Date__c <= Date.today().addDays(30) && 
                oldEvent.Status__c != 'Open for Registration') {
                event.Status__c = 'Open for Registration';
            }
        }
    }
    
    // For sending Email when event is within 3 days
    public static void handleAfterUpdate(List<Event__c> newEvents, Map<Id, Event__c> oldEventMap) {
        List<Id> eventIds = new List<Id>();
        for (Event__c event : newEvents) {
            Event__c oldEvent = oldEventMap.get(event.Id);
            if (event.Status__c == 'Open for Registration' && oldEvent.Status__c != 'Open for Registration' && event.Event_Date__c <= Date.today().addDays(3)) {
                eventIds.add(event.Id);
            }
        }
        if (!eventIds.isEmpty()) {
            sendReminderEmails(eventIds);
        }
    }

    // Event Reminder Method within 3 days
    private static void sendReminderEmails(List<Id> eventIds) {

    // Query Volunteer_Event__c records that are associated with the given eventIds
    List<Volunteer_Event__c> volunteerEvents = [
        SELECT Volunteer__c, Volunteer__r.Email__c, Event__r.Name 
        FROM Volunteer_Event__c 
        WHERE Event__c IN :eventIds AND Status__c = 'Registered'
    ];

    Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Event_Reminder' LIMIT 1].Id;

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    for (Volunteer_Event__c ve : volunteerEvents) {
        if (ve.Volunteer__r.Email__c != null) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { ve.Volunteer__r.Email__c });
            email.setTemplateId(templateId); 
            email.setTargetObjectId(UserInfo.getUserId());
            email.setSaveAsActivity(false);
            
            emails.add(email);
        }
    }

    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }
}

// prevents marking the event as complete when status of volunteer Event is No Show
public static void preventCompletionWithNoShowVolunteers(List<Event__c> events) {
    Set<Id> eventIds = new Set<Id>();

    // Collect the event IDs being processed
    for (Event__c event : events) {
        if (event.Status__c == 'Completed') {
            eventIds.add(event.Id);
        }
    }

    if (eventIds.isEmpty()) {
        return;
    }

    // Query for related Volunteer_Event__c records with 'No-Show' status
    List<Volunteer_Event__c> noShowVolunteers = [
        SELECT Id, Event__c 
        FROM Volunteer_Event__c
        WHERE Event__c IN :eventIds AND Status__c = 'No-Show'
    ];

    // If any "No-Show" volunteers exist, prevent the event from being marked as completed
    for (Event__c event : events) {
        if (event.Status__c == 'Completed') {
            for (Volunteer_Event__c noShowVolunteer : noShowVolunteers) {
                if (noShowVolunteer.Event__c == event.Id) {
                    event.addError('This event cannot be marked as "Completed" because there are volunteers with a "No-Show" status.');
                }
            }
        }
    }
}

// logic for feedback trigger
// public static void handleEventStatusChange(List<Event__c> newEvents, Map<Id, Event__c> oldEventMap) {
//     Set<Id> attendedEventIds = new Set<Id>();
//     Set<Id> volunteerIds = new Set<Id>();

//     // Iterate over the new event records
//     for (Event__c event : newEvents) {
//         Event__c oldEvent = oldEventMap.get(event.Id);
        
//         // Check if the status has changed to "Attended"
//         if (event.Status__c == 'Completed' && oldEvent.Status__c != 'Completed') {
//             attendedEventIds.add(event.Id);

//             // Query for volunteers related to the attended event
//             // Replace with the actual field and relationship
//             List<Volunteer__c> relatedVolunteers = [
//                 SELECT Id FROM Volunteer__c WHERE Event__r = :event.Id
//             ];
//             for (Volunteer__c volunteer : relatedVolunteers) {
//                 volunteerIds.add(volunteer.Id);
//             }
//         }
//     }

//     // Call the future method to send feedback requests
//     if (!attendedEventIds.isEmpty() && !volunteerIds.isEmpty()) {
//         EventFeedbackSender.sendFeedbackRequest(volunteerIds, attendedEventIds);
//     }
// }

}