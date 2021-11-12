trigger AccountTrigger on Account (before insert, after insert, before update) {
    if(Trigger.isInsert && Trigger.isBefore)    {
        AccountTriggerhandler handler = new AccountTriggerhandler();
        handler.beforeInsert(Trigger.new);
    } 
    else if(Trigger.isInsert && Trigger.isAfter)    {
        AccountTriggerhandler handler = new AccountTriggerhandler();
        handler.afterInsert(Trigger.new);
    }    
}