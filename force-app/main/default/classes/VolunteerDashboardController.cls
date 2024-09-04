public with sharing class VolunteerDashboardController {
    @AuraEnabled(cacheable=true)
    public static List<Volunteer__c> getVolunteers() {
        return [SELECT Id, Name FROM Volunteer__c];
    }

    // @AuraEnabled(cacheable=true)
    // public static Map<String, Object> getVolunteerData(Id volunteerId) {
    //     Map<String, Object> result = new Map<String, Object>();

    //     // Fetch total hours contributed by the volunteer
    //     Volunteer__c volunteer = [SELECT Id, Total_Hours__c FROM Volunteer__c WHERE Id = :volunteerId LIMIT 1];
    //     result.put('totalHours', volunteer.Total_Hours__c != null ? volunteer.Total_Hours__c : 0);

    //     // Fetch upcoming events the volunteer is registered for
    //     List<Event__c> events = [
    //         SELECT Id, Name, Event_Date__c 
    //         FROM Event__c 
    //         WHERE Id IN (SELECT Event__c FROM Volunteer_Event__c WHERE Volunteer__c = :volunteerId) 
    //     ];
    //     result.put('upcomingEvents', events);

    //     // Prepare event options for feedback form
    //     List<Map<String, String>> eventOptions = new List<Map<String, String>>();
    //     for (Event__c event : events) {
    //         eventOptions.add(new Map<String, String>{
    //             'label' => event.Name,
    //             'value' => event.Id
    //         });
    //     }
    //     result.put('eventOptions', eventOptions);

    //     return result;
    // }

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

        // Insert feedback record
        Feedback__c feedback = new Feedback__c(
            Event__c = eventId,
            Rating__c = rating,
            Comments__c = comments
        );
        insert feedback;
    }

    public static Map<String, Object> getVolunteerData(Id volunteerId) {
        Map<String, Object> result = new Map<String, Object>();
    
        // Fetch total hours contributed by the volunteer
        Volunteer__c volunteer = [
            SELECT Id, Total_Hours__c 
            FROM Volunteer__c 
            WHERE Id = :volunteerId 
            LIMIT 1
        ];
        result.put('totalHours', volunteer.Total_Hours__c);
    
        // Fetch upcoming events with status 'Registered'
        List<Volunteer_Event__c> volunteerEvents = [
            SELECT Id, Event__c, Event__r.Name, Event__r.Event_Date__c, 
                   Event__r.Location__c, Event__r.Description__c
            FROM Volunteer_Event__c
            WHERE Volunteer__c = :volunteerId AND Status__c = 'Registered'
        ];
    
        // Prepare the list of events
        List<Map<String, Object>> events = new List<Map<String, Object>>();
        for (Volunteer_Event__c ve : volunteerEvents) {
            Map<String, Object> eventData = new Map<String, Object>();
            eventData.put('eventName', ve.Event__r.Name);
            eventData.put('eventDate', ve.Event__r.Event_Date__c);
            eventData.put('location', ve.Event__r.Location__c);
            eventData.put('description', ve.Event__r.Description__c);
            events.add(eventData);
        }
    
        result.put('upcomingEvents', events);
    
        return result;
    }
}
