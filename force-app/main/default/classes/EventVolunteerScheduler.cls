global class EventVolunteerScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        sendEncouragementEmails();
    }

    // Sending Email to all Acive Volunteers Registration 
    private void sendEncouragementEmails() {
        // Query active volunteers with email addresses
        List<Volunteer__c> activeVolunteers = [
            SELECT Id, Name, Email__c 
            FROM Volunteer__c 
            WHERE Status__c = 'Active' AND Email__c != null
        ];

        if (!activeVolunteers.isEmpty()) {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            // Get the ID of the email template
            EmailTemplate template = [
                SELECT Id 
                FROM EmailTemplate 
                WHERE DeveloperName = 'Event_Invitation' 
                LIMIT 1
            ];

            for (Volunteer__c volunteer : activeVolunteers) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { volunteer.Email__c });
                email.setTemplateId(template.Id);
                email.setTargetObjectId(UserInfo.getUserId()); // TargetObjectId is required when using a template
                email.setSaveAsActivity(false); 

                emails.add(email);
            }

            // Send all emails
            Messaging.sendEmail(emails);
        }
    }
}
