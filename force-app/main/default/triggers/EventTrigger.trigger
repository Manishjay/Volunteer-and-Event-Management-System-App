trigger EventTrigger on Event__c (before update, after update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        EventTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        EventTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        EventTriggerHandler.preventCompletionWithNoShowVolunteers(Trigger.new);
    }
}