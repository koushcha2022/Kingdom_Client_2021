public with sharing class BitlyIntegrationService {

    //Pass URL as parameter and Same will pass to Bitly to shorten the URL 
    Public String  GenerateShortenURL(String courseURL) {
        String shortURL = '';
        //HTTP POST Call
        Http h = new Http();
        HttpRequest hReq = new HttpRequest();

        //Use named Credential to populate Callout endpoint : callout:Credential_Name + 'v4/shorten'
        hreq.setEndpoint('callout:BitlyIntegration/v4/shorten');

        //Set Http Header
        hreq.setHeader('Authorization','Bearer {!$Credential.Password}');
        hreq.setHeader('Accept','application/json');
        hreq.setHeader('Content-Type','application/json');
        
        //Set Post Method
        hreq.setMethod('POST');

        //Set Http Body
        Map<String, Object> httpBodyMap = new Map<String, Object>();
        httpBodyMap.put('long_url',courseURL);
        httpBodyMap.put('domain','bit.ly');
        httpBodyMap.put('group_guid','{!$Credential.Username}');
        hReq.setBody(JSON.serialize(httpBodyMap));
        System.debug('Body: ' + JSON.serialize(httpBodyMap));

        HttpResponse resp = h.send(hReq);

        system.debug('Response Code: ' + resp.getStatusCode());
        if(resp.getStatusCode() == 200) {
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody()); 
            shortURL = String.valueOf(responseMap.get('link'));
        }
        return shortURL;
    }
}
