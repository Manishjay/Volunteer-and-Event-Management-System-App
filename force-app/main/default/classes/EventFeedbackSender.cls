public with sharing class EventFeedbackSender {
    @future(callout=true)
    public static void sendFeedbackRequest(Set<Id> volunteerIds, Id eventId) {
        // Query the volunteers with non-null email addresses
        List<Volunteer__c> volunteers = [
            SELECT Id, Name, Email__c 
            FROM Volunteer__c 
            WHERE Id IN :volunteerIds AND Email__c != null
        ];

        // Query the event details
        Event__c eventDetails = [
            SELECT Id, Name 
            FROM Event__c 
            WHERE Id = :eventId
            LIMIT 1
        ];

        if (!volunteers.isEmpty() && eventDetails != null) {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            for (Volunteer__c volunteer : volunteers) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                // Use the template ID by querying the template's DeveloperName
                Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Feedback_Request' LIMIT 1].Id;
                
                // Set the email template
                email.setTemplateId(templateId);
                
                // Since we can't use WhatId, ensure the template is set up to not require it
                // We directly set the ToAddresses for the email
                email.setToAddresses(new String[] { volunteer.Email__c }); 
                
                // Optionally, include the name and other fields as merge fields if needed
                email.setTargetObjectId(UserInfo.getUserId()); // Use current user's ID as a placeholder
                
                // Ensure the email is sent even if the template has no merge fields
                email.setSaveAsActivity(false);
                
                emails.add(email);
            }

            // Send the emails
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        }
    }
}


// Set<Id> volunteerIds = new Set<Id>{'001...'}; // Replace with actual Volunteer__c record Ids
// Id eventId = 'a0B...'; // Replace with an actual Event__c record Id
// EventFeedbackSender.sendFeedbackRequest(volunteerIds, eventId);