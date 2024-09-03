public with sharing class VolunteerDashboardController {
    @AuraEnabled(cacheable=true)
    public static List<Volunteer__c> getVolunteers() {
        return [SELECT Id, Name FROM Volunteer__c];
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getVolunteerData(Id volunteerId) {
        Map<String, Object> result = new Map<String, Object>();

        // Fetch total hours contributed by the volunteer
        Volunteer__c volunteer = [SELECT Id, Total_Hours__c FROM Volunteer__c WHERE Id = :volunteerId LIMIT 1];
        result.put('totalHours', volunteer.Total_Hours__c);

        // Fetch upcoming events the volunteer is registered for
        List<Event__c> events = [
            SELECT Id, Name, Event_Date__c 
            FROM Event__c 
            WHERE Id IN (SELECT Event__c FROM Volunteer_Event__c WHERE Volunteer__c = :volunteerId) 
        ];
        result.put('upcomingEvents', events);

        // Fetch event options for feedback form
        List<SelectOption> eventOptions = new List<SelectOption>();
        for (Event__c event : events) {
            eventOptions.add(new SelectOption(event.Id, event.Name));
        }
        result.put('eventOptions', eventOptions);

        return result;
    }

    @AuraEnabled
    public static void submitFeedback(Id eventId, String rating, String comments) {
        // Ensure rating is a valid picklist value
        Schema.DescribeFieldResult fieldResult = Feedback__c.Rating__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        Set<String> validRatings = new Set<String>();
        for (Schema.PicklistEntry entry : picklistEntries) {
            validRatings.add(entry.getValue());
        }

        if (!validRatings.contains(rating)) {
            throw new AuraHandledException('Invalid rating value. Please select a valid rating.');
        }

        Feedback__c feedback = new Feedback__c(
            Event__c = eventId,
            Rating__c = rating,          // Use picklist value as String
            Comments__c = comments        // Use comments as String
        );
        insert feedback;
    }
}