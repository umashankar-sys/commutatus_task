trigger AccountTrigger on Account (before insert, after insert, after update) {
    if (trigger.isAfter) {
        if (trigger.isInsert) {
            AccountTriggerHandler.populateUniqueId(trigger.new);
        }
        if(trigger.isupdate){
            AccountTriggerHandler.profileUpdated(Trigger.new, trigger.oldMap);
        }
    }
}