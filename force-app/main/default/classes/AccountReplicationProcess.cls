public with sharing class AccountReplicationProcess {

    //Public variable
    Public Static String instanceURL;
    Public Static String accessToken;

    //Wrapper Class
    public class AccountRecordFields  {
        @AuraEnabled
        Public String Name;     
        @AuraEnabled
        Public String AccountNumber;   
        @AuraEnabled
        Public String Industry;
        @AuraEnabled
        Public String AnnualRevenue;
        @AuraEnabled
        Public String Rating;
    }

    @AuraEnabled(Cacheable=true)
    public static void CloneToServer(){
        try {
            //Oauth 2.0 UserName and password Flow
            //=====================================

            //Make a REST call to access Oauth Token from Authentication Server using Connected App
            //Step 1: POST method calls
            //Step 2: HTTP Call - Send(HttpRequest) method which returns HTTpResponse
            String ConsumerKey = '3MVG9SemV5D80oBdYqCQuwdYbl.xN92s6FDlGtUbH5w0bUTsQnqTf6PVhw_vaXy5cNVgHLQk.qiW72W4ocyzB';
            String ConsumerSecret = 'AEB8A217A55ADCF0A2AED74A24D5D1AC8FBEBFDE859F5B75BD7879A0EC396680';
            String username = 'koushcha2010-d7kl@force.com';
            //password = password + Security Token 
            String password = 'KB@@Dec2021lvY3DUJGTNtX3r2AIxFlIsN1m';

            String endpointURL = 'https://login.salesforce.com/services/oauth2/token';
            endpointURL = endpointURL + '?grant_type=password&client_id=' + ConsumerKey + '&client_secret=' + ConsumerSecret + '&username=' +
                        username + '&password=' + password;
            system.debug('EndPoint: ' + endpointURL);

            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpointURL);
            //Set POST Method
            req.setMethod('POST');

            //For Basic authorization, create a BLOB type Authentication Header
            Blob headerValue = Blob.valueOf(username + ':' + password);
            //Converts a Blob to an unencoded String representing its normal form.
            String authorizationValue = 'BASIC' + EncodingUtil.base64Encode(headerValue);

            //Sets the contents of the request header
            req.setHeader('Authorization', authorizationValue);
            // Send the request, and return a response
            HttpResponse resp = h.send(req);
            system.debug('Response: ' + resp.getBody());

            System.JSONParser parser = JSON.createParser(resp.getBody());

            while(parser.nextToken() != NULL)	{
                if(parser.getCurrentToken() == System.JSONToken.FIELD_NAME && parser.getText() == 'access_token')	{
                    parser.nextToken();
                    accessToken = parser.getText();    
                }	   
                if(parser.getCurrentToken() == System.JSONToken.FIELD_NAME && parser.getText() == 'instance_url')	{
                    parser.nextToken();
                    instanceURL = parser.getText();    
                }
            }

            system.debug('Access Token :' + accessToken);
            system.debug('Instance URL :' + instanceURL);
            
    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static string replicateData(String pName, String pAccountNumber, String pIndustry, String pAnnualRevenue, String pRating)  {
        //try {
            String accId;

            //Get Access token and Instance URL
            AccountReplicationProcess.CloneToServer();

            //Instantiate Service Class
            soapAccountCreation.AccountCreationSOAPService AccCreationService = new soapAccountCreation.AccountCreationSOAPService();

            if(accessToken != NULL || accessToken != '')	{
                //Get SessionHeader Object to pass Session ID				
                soapAccountCreation.SessionHeader_element sessionHeaderObj = new soapAccountCreation.SessionHeader_element();
                sessionHeaderObj.sessionId = accessToken;   
                AccCreationService.SessionHeader = sessionHeaderObj;  

                if(instanceURL != NULL || instanceURL != '')    {
                    AccCreationService.endpoint_x = instanceURL + '/services/Soap/class/AccountCreationSOAPService';    
                }

                Account acc = new Account();
                acc.Name = pName;
                acc.AccountNumber = pAccountNumber;
                acc.Industry = pIndustry;
                acc.Rating = pRating;
                Double annualRevenueDbl;
                if(pAnnualRevenue != '' || pAnnualRevenue != NULL)  {
                    annualRevenueDbl = Decimal.valueOf(pAnnualRevenue);
                }
                system.debug('Acc: ' + acc);
                accId = AccCreationService.createNewAccount(acc.Name,acc.AccountNumber,annualRevenueDbl,acc.Industry,acc.Rating);   
                system.debug('Acc ID: ' + accId);
            }
            return accId;

        //} catch (Exception e) {
        //    throw new AuraHandledException(e.getMessage());
        //}
    }    
}
