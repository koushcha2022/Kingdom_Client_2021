trigger AccountTrigger on Account (before insert, before update) {
    if(Trigger.isInsert)    {

    } 
    else if(Trigger.isUpdate)   {
        
    }
}