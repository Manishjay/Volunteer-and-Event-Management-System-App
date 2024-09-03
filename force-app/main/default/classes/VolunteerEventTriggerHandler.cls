public with sharing class VolunteerEventTriggerHandler {
    
    // logic to 
    public static void handleAfterUpdate(List<Volunteer_Event__c> newVolunteerEvents, Map<Id, Volunteer_Event__c> oldVolunteerEventMap) {
        Set<Id> volunteerIds = new Set<Id>();
        List<Volunteer_Event__c> volunteersToEmail = new List<Volunteer_Event__c>();
        
        // Iterate through the updated Volunteer_Event__c records
        for (Volunteer_Event__c ve : newVolunteerEvents) {
            Volunteer_Event__c oldVE = oldVolunteerEventMap.get(ve.Id);
            
            // Check if the status has changed to 'Attended'
            if (ve.Status__c == 'Attended' && oldVE.Status__c != 'Attended') {
                volunteerIds.add(ve.Volunteer__c); // Collect Volunteer IDs for updating total hours
                volunteersToEmail.add(ve); // Collect records for sending thank-you emails
            }
        }

        // Update the total hours contributed for the affected volunteers
        if (!volunteerIds.isEmpty()) {
            updateVolunteerHours(volunteerIds);
        }
    
        // Send thank-you emails to volunteers who attended the event
        if (!volunteersToEmail.isEmpty()) {
            sendThankYouEmails(volunteersToEmail);
        }
    }
    
    private static void updateVolunteerHours(Set<Id> volunteerIds) {
        // Map to store the total hours contributed by each volunteer
        Map<Id, Decimal> volunteerHoursMap = new Map<Id, Decimal>();
    
        // Aggregate query to sum Hours_Contributed__c for each Volunteer__c across all attended events
        List<AggregateResult> results = [
            SELECT Volunteer__c, SUM(Hours_Contributed__c) totalHours
            FROM Volunteer_Event__c
            WHERE Volunteer__c IN :volunteerIds AND Status__c = 'Attended'
            GROUP BY Volunteer__c
        ];
    
        // Populate the map with total hours per volunteer
        for (AggregateResult ar : results) {
            volunteerHoursMap.put((Id)ar.get('Volunteer__c'), (Decimal)ar.get('totalHours'));
        }
    
        // List to hold Volunteer__c records to update
        List<Volunteer__c> volunteersToUpdate = new List<Volunteer__c>();
        for (Id volunteerId : volunteerHoursMap.keySet()) {
            volunteersToUpdate.add(new Volunteer__c(Id = volunteerId, Total_Hours__c = volunteerHoursMap.get(volunteerId)));
        }
    
        // Update the Volunteer__c records with the new total hours
        if (!volunteersToUpdate.isEmpty()) {
            update volunteersToUpdate;
        }
    }
    
    // Sending Thank You Email For Attending Event
    private static void sendThankYouEmails(List<Volunteer_Event__c> volunteerEvents) {

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Thank_You_Email'];
        
        // Iterate through the volunteer events and prepare emails
        for (Volunteer_Event__c ve : volunteerEvents) {
            
            if (ve.Volunteer__r.Email__c != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { ve.Volunteer__r.Email__c });
                
                // Set the email template ID (replace with your actual template developer name)
                email.setTemplateId(template.Id); 
                
                email.setTargetObjectId(UserInfo.getUserId()); // TargetObjectId is required when using a template
                email.setSaveAsActivity(false);
            }
        }
        
        // Send all prepared emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    public static void preventOverlappingRegistrations(List<Volunteer_Event__c> newVolunteerEvents) {
        Set<Id> volunteerIds = new Set<Id>();

        // Collect volunteer IDs from the incoming records
        for (Volunteer_Event__c ve : newVolunteerEvents) {
            volunteerIds.add(ve.Volunteer__c);
        }

        // Query existing events for the volunteers in the incoming records
        List<Volunteer_Event__c> existingVolunteerEvents = [
            SELECT Id, Volunteer__c, Event__c, Event__r.Event_Date__c
            FROM Volunteer_Event__c
            WHERE Volunteer__c IN :volunteerIds
        ];

        // Check for overlapping events on the same date
        for (Volunteer_Event__c newEvent : newVolunteerEvents) {
            for (Volunteer_Event__c existingEvent : existingVolunteerEvents) {
                if (existingEvent.Volunteer__c == newEvent.Volunteer__c &&
                    existingEvent.Event__r.Event_Date__c == newEvent.Event__r.Event_Date__c &&
                    existingEvent.Id != newEvent.Id) {
                    newEvent.addError('This volunteer is already registered for another event on the same date.');
                }
            }
        }
    }
}
