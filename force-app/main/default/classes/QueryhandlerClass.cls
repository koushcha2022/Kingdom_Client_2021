public with sharing class QueryhandlerClass {

    public List<SObject> dynamicSelectQuery(String objectName)  {
        String varQuery = 'SELECT ';
        List<String> varListOfObjects = new List<String>();
        //Add Object in the varListOfObjects Collection
        varListOfObjects.add(objectName);

        List<Schema.DescribeSObjectResult> allObjResult = schema.describeSObjects(varListOfObjects);
        system.debug(allObjResult);
        for(Schema.DescribeSObjectResult objResult : allObjResult)  {
            system.debug(objResult.fields);
            Map<String, Schema.SObjectField> allFieldsName = objResult.fields.getMap();
            Set<String> allKeyName = allFieldsName.keySet();
            for(String fieldName : allKeyName)  {
                varQuery += fieldName + ',';
            }
        }
        varQuery = varQuery.removeEnd(',');
        varQuery += ' FROM ' + objectName;
        system.debug(varQuery);
        List<SObject> resultList = Database.query(varQuery);
        return resultList;
    }

    //************** Sharing Record by Code or Apex Class ************* */
    public void dynamicSharingRecord()  {
        //For this APEX Sharing scneraio, object API name will be <Object name>__Share
        //If Object name is Integration_Setup__c then sharing object name will be 	Integration_Setup__Share
        Integration_Setup__Share varSetup = new Integration_Setup__Share();
        
        //Retrive the Record ID which want to share to use for this sharing process
        Integration_Setup__c setupRec = [SELECT Id FROM Integration_Setup__c WHERE Setup_Name__c = 'JWT Bearer Flow for Server to Server Integration' 
                                        WITH SECURITY_ENFORCED LIMIT 1];
        if(setupRec.Id != NULL) {
            //Decide which record you want to share     
            varSetup.ParentId = setupRec.Id;

            //Get Recoerd Id of user to whom we want to share the Record
            User selectedUsr = [SELECT Id FROM User WHERE Username = 'koushikc2006@mygamil.dev' WITH SECURITY_ENFORCED LIMIT 1];
            if(selectedUsr.Id != NULL)  {
                //We can set single user or Public Group ID as well
                varSetup.UserOrGroupId = selectedUsr.Id; 

                //Decide which Access level we want to give permission (2 Options: Read/Edit)
                varSetup.AccessLevel = 'Read';
                Database.SaveResult resultList = Database.insert(varSetup, false);
            }

        }
    }
}
