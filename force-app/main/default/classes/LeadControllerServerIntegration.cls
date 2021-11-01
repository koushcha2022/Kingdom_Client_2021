Public with sharing class LeadControllerServerIntegration {
    //Global variables
    public static String accessToken;
    public static String instanceURL;

    public static void requestAccessToken() {
        Integration_Setup__c setupInfoparam = [SELECT Server_Name__c, Server_User_Name__c, Password__c, Client_ID__c, Client_Secret__c, EndPoints__c 
                                               FROM Integration_Setup__c WHERE Name = 'INT-001' LIMIT 1];

        String accessTokenEndPoint = setupInfoparam.EndPoints__c;
        accessTokenEndPoint +=  '?grant_type=password';
        accessTokenEndPoint += '&client_id=' + setupInfoparam.Client_ID__c;
        accessTokenEndPoint += '&client_secret=' + setupInfoparam.Client_Secret__c;
        accessTokenEndPoint += '&username=' + setupInfoparam.Server_User_Name__c;
        accessTokenEndPoint += '&password=' + setupInfoparam.Password__c;
        System.debug('token Endpoint: ' + accessTokenEndPoint);

        //Instantiate Http Class
        http h = new Http();
        //Instantiate HttpRequest Class
        HttpRequest req = new HttpRequest();
        //Set Request Endpoint using URL Encoded version
        req.setEndpoint(accessTokenEndPoint);
        //Set Post Method
        req.setMethod('POST');

        //For Basic authorization, create a BLOB type Authentication Header
        Blob headerValue = BLOB.valueOf(setupInfoparam.Server_User_Name__c + ':' + setupInfoparam.Password__c);
        String authorizationValue = 'BASIC' + EncodingUtil.base64Encode(headerValue);
        //Sets the contents of the request header.
        req.setHeader('Authorization', authorizationValue);

        //Finally make a Http Call with HttpRequest
        HttpResponse hResp = h.send(Req);

        if(hResp.getStatusCode() == 200)  {
            System.debug('Http Response :' + hResp.getBody());
            JSONParser jParser = JSON.createParser(hResp.getBody());
            while(jParser.nextToken() != NULL) {
                if(jParser.getCurrentToken() == JSONToken.FIELD_NAME && jParser.getText() == 'instance_url')    {
                    jParser.nextToken();
                    instanceURL = jParser.getText();    
                }

                if(jParser.getCurrentToken() == JSONToken.FIELD_NAME && jParser.getText() == 'access_token')    {
                    jParser.nextToken();
                    accessToken = jParser.getText();    
                    system.debug('Access token :' + accessToken);
                }
            }
        }
    }

    Public Static void JWTrequestAccessToken() {
        Integration_Setup__c setupInfoparam = [SELECT Server_Name__c, Server_User_Name__c, Client_ID__c, EndPoints__c, JWT_Certificate__c
                                              FROM Integration_Setup__c WHERE Name = 'INT-002' LIMIT 1];

        if(setupInfoparam.Server_User_Name__c != NULL)  {
            JWTIntegrationClass.JWTConfiguration jwtConfig = new JWTIntegrationClass.JWTConfiguration();
            jwtConfig.JWTUsername = setupInfoparam.Server_User_Name__c;
            jwtConfig.JWTConnectedAppConsumerKey = setupInfoparam.Client_ID__c;
            jwtConfig.JWTSignedCertName = setupInfoparam.JWT_Certificate__c;
            jwtConfig.JWTHostName = setupInfoparam.EndPoints__c;

            JWTIntegrationClass jwtClass = new JWTIntegrationClass(jwtConfig);
            Map<String,String> jwtResp= jwtClass.RequestAccessToken();
            accessToken = jwtResp.get('access_token');
            instanceURL = jwtResp.get('instance_url');
            system.debug('JWT Access token :' + accessToken);
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Lead> GetLeadRecords(String SearchTerm, String SelectOption){
        try {
            List<lead> leadSearchList = new List<lead>();
            if(SelectOption == 'option1')  {
                //How can I authenticate to get the Access Token which is used to assign Session ID
                requestAccessToken();
            }
            else if(SelectOption == 'option2')  {
                //Get JWT Access Token
                JWTrequestAccessToken();
            }
 
            if(accessToken != NULL) {
                //Access Token pass to access soem REST Resources from Server
                //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
                String leadHttpGetEndPoint = instanceURL + '/services/apexrest/LeadService/';
                leadHttpGetEndPoint += 'name=' + SearchTerm;
                system.debug('leadHttpGetEndPoint :' + leadHttpGetEndPoint);

                //Instantiate Http Class
                Http h = new Http();
                //Instantiate HttpRequest Class
                HttpRequest hReq = new HttpRequest();

                //Set Request Endpoint using URL Encoded version
                hReq.setEndpoint(leadHttpGetEndPoint);

                //Set GET Method
                hReq.setMethod('GET');
                
                //Set Header
                hReq.setHeader('Authorization', 'Bearer ' + accessToken);
                hReq.setHeader('Content-Type','application/json');

                //Finally make a Http Call with HttpRequest
                HttpResponse hResp = h.send(hReq);
                system.debug('Response :' + hResp.getBody());
                if(hResp.getStatusCode() == 200)    {
                    leadSearchList = (List<Lead>) JSON.deserialize(hResp.getBody(), List<Lead>.class);        
                    system.debug('Searched Lead List :' + leadSearchList);
                }
            }
        return leadSearchList;    

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String InsertLeadRecord(String fName, String lName, String leadCompany, String leadEmail, 
                                          String leadIndustry, String leadSource, String leadPhone)    {
        try {
            String returnValue;

            //How can I authenticate to get the Access Token which is used to assign Session ID
            requestAccessToken();
              
            if(accessToken != NULL) {
                //Access Token pass to access soem REST Resources from Server
                //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
                String leadHttpPostEndPoint = instanceURL + '/services/apexrest/LeadService/';
                
                //Instantiate Http Class
                Http h = new Http();
                //Instantiate HttpRequest Class
                HttpRequest hReq = new HttpRequest();

                //Set Request Endpoint using URL Encoded version
                hReq.setEndpoint(leadHttpPostEndPoint);

                //Set POST Method
                hReq.setMethod('POST');

                //Set Header
                hReq.setHeader('Authorization', 'Bearer ' + accessToken);
                hReq.setHeader('Content-Type','application/json');

                //Set Body
                JSONGenerator jGen = JSON.createGenerator(true);
                jGen.writeStartObject();
                jGen.writeStringField('fName', fName != NULL ? fName : '');
                jGen.writeStringField('lName',lName != NULL ? lName : '');
                jGen.writeStringField('leadCompany', leadCompany != NULL ? leadCompany : '');
                jGen.writeStringField('leadEmail', leadEmail != NULL ? leadEmail : '');
                jGen.writeStringField('leadIndustry', leadIndustry != NULL ? leadIndustry : '');
                jGen.writeStringField('leadSource', leadSource != NULL ? leadSource : '');
                jGen.writeStringField('leadPhone', leadPhone != NULL ? leadPhone : '');
                jGen.writeEndObject();
                
                //Returns the generated JSON content.
                String jsonString = jGen.getAsString(); 
                system.debug('Json Generator =>' + jsonString);
                hreq.setBody(jsonString);

                HttpResponse resp = h.send(hreq);
                if(resp.getStatusCode() == 200) {
                    returnValue = resp.getBody();       
                    system.debug('Response :' + returnValue);     
                }
            }    
        return returnValue;
        
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String DeleteLeadRecord(String LeadId){
        try {
            String returnMessage = '';

            //How can I authenticate to get the Access Token which is used to assign Session ID
            requestAccessToken();
              
            if(accessToken != NULL) {
                //Access Token pass to access soem REST Resources from Server
                //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
                String leadHttpDelEndPoint = instanceURL + '/services/apexrest/LeadService/';
                leadHttpDelEndPoint += 'Id=' + LeadId;

                //Instantiate Http Class
                Http h = new Http();
                //Instantiate HttpRequest Class
                HttpRequest hReq = new HttpRequest();

                //Set Request Endpoint using URL Encoded version
                hReq.setEndpoint(leadHttpDelEndPoint);

                //Set DELETE Method
                hReq.setMethod('DELETE');

                //Set Header
                hReq.setHeader('Authorization', 'Bearer ' + accessToken);
                hReq.setHeader('Content-Type','application/json');

                //Finally make a Http Call with HttpRequest
                HttpResponse hResp = h.send(hReq);
                system.debug('Response :' + hResp.getBody());
                returnMessage = (String)JSON.deserialize(hResp.getBody(),String.class);
            }
            return returnMessage;

        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }    

    @AuraEnabled
    public static String UpdateLeadRecord(String LeadId, String NewEmailId)   {
        try {
            String returnMessage = '';

            //How can I authenticate to get the Access Token which is used to assign Session ID
            requestAccessToken();
              
            if(accessToken != NULL) {
                //Access Token pass to access REST Resources from Server
                //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
                String leadHttpDelEndPoint = instanceURL + '/services/apexrest/LeadService/';
                leadHttpDelEndPoint += 'Id=' + LeadId;

                //Instantiate Http Class
                Http h = new Http();
                //Instantiate HttpRequest Class
                HttpRequest hReq = new HttpRequest();

                //Set Request Endpoint using URL Encoded version
                hReq.setEndpoint(leadHttpDelEndPoint);

                //Set PATCH Method
                hReq.setMethod('PATCH');

                //Set Header
                hReq.setHeader('Authorization', 'Bearer ' + accessToken);
                hReq.setHeader('Content-Type','application/json');

                //Set Body
                JSONGenerator jGen = JSON.createGenerator(true);
                jGen.writeStartObject();
                jGen.writeStringField('newEmail', NewEmailId != NULL ? NewEmailId : '');
                jGen.writeEndObject();
                
                //Returns the generated JSON content.
                String jsonString = jGen.getAsString(); 
                system.debug('Json Generator =>' + jsonString);
                hreq.setBody(jsonString);

                HttpResponse resp = h.send(hreq);
                if(resp.getStatusCode() == 200) {
                    returnMessage = resp.getBody();       
                    system.debug('Response :' + returnMessage);     
                }
            }
        return returnMessage;

        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }    
}
