trigger VolunteerEventTrigger on Volunteer_Event__c (before insert, before update, after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        VolunteerEventTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        VolunteerEventTriggerHandler.preventOverlappingRegistrations(Trigger.new);
    }
}