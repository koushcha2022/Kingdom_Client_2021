public with sharing class MetadataInfoHandlerClass {

    public void getObjectInfo(List<String> sObjectList) {
        String[] arrObjectList = new String[sObjectList.size()]; 
        Integer ctr = 0;
        
        if(sObjectList.size() > 0)  {
            for(String obj : sObjectList) {
                arrObjectList[ctr] = obj;
                ctr++;
            }
        }

        if(arrObjectList.size() > 0)   {
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(arrObjectList);
            for(Schema.DescribeSObjectResult obj : descResult)  {
                system.debug(obj.getLabel());

                // Map<String,Schema.SObjectField> allFields = obj.fields.getMap(); 
                // Set<String> varMapSet = allFields.keySet(); 
                // for(String key : varMapSet) {
                //     system.debug(key + ':' + allFields.get(key));
                // }

                //Get all the Record Type Infos
                List<Schema.RecordTypeInfo> recTypeInfoList = obj.getRecordTypeInfos();
                for(Schema.RecordTypeInfo recType : recTypeInfoList)    {
                    system.debug('Rec Type ID: ' +  recType.getRecordTypeId() + ' , Name: ' + recType.getName());
                }
            }
            
        }
    }

    public void getAccountRecTypeInfo()    {
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' LIMIT 1];
        system.debug('Result: ' + rt);

        // Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
        // Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
        // Schema.RecordTypeInfo rtById =  rtMapById.get(rt.id);
        // Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        // Schema.RecordTypeInfo rtByName =  rtMapByName.get(rt.name);
        // system.debug('Rec Name: ' + rtByName);
    }
}