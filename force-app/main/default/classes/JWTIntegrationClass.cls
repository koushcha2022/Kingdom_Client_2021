Public with sharing class JWTIntegrationClass {
    //Global Variables
    Private JWTConfiguration JWTConfig;
    
    //Constructor
    public JWTIntegrationClass(JWTConfiguration JWTConfigParam) {
        this.JWTConfig = JWTConfigParam;
    }

    //Wrapper Class for JWT Configuration   
    Public Class JWTConfiguration   {
        Public String JWTUsername{get;set;}
        Public String JWTConnectedAppConsumerKey{get;set;}
        Public String JWTSignedCertName{get;set;}
        Public String JWTHostName{get;set;}
    }

    //Wrapper Class for JWT Header
    Public class JWTHeader {
        String alg;
        //Contructor
        Public JWTHeader(String algoParam)  {
            this.alg = algoParam;
        }
    }

    //Wrapper Class for JSON Claim Set
    Public Class JWTBody   {
        String iss;
        String aud;
        String prn;
        String exp;
        //Constructor
        Public JWTBody(String iss, String aud, String prn, String exp)    {
            this.iss = iss;
            this.aud = aud;
            this.prn = prn;
            this.exp = exp;
        }
    }

    //Wrapper for Exception
    Public class JWTException extends Exception   {
        
    }

    //Method to create JWT Access Token
    Public String CreateJWTAccessToken() {
        
        //Create JWT Headder in jSOn format  {"alg":"RS256"}
        String alg = 'RS256';
        JWTHeader header = new JWTHeader(alg);
        String headerJSON = JSON.serialize(header);
        system.debug('Header JSON: ' + headerJSON);
        //Base64URL Encoded JWT Header
        String encodedJWTHeader = this.base64URLSafe(Blob.valueOf(headerJSON));
        system.debug('encodedJWTHeader: ' + encodedJWTHeader);

        //Construct a JSON Claims Set Body
        String prn = this.JWTConfig.JWTUsername;
        String iss = this.JWTConfig.JWTConnectedAppConsumerKey;
        //authorization server
        String aud = 'https://' + this.JWTConfig.JWTHostName;
        String exp = String.valueOf(System.currentTimeMillis() + 60*60*60*1000);
        JWTBody body = new JWTBody(iss,aud,prn,exp);
        String bodyJSON = JSON.serialize(body); 
        system.debug('bodyJSON: ' + bodyJSON);    
        //Base64URL Encoded for JWT Claims Set Body 
        String encodedHWTbody = this.base64URLSafe(Blob.valueOf(bodyJSON));
        system.debug('encodedHWTbody: ' + encodedHWTbody);

        //Create a String with encoded JWT Header and the encoded JWT Claims Set 
        String accessToken = encodedJWTHeader + '.' + encodedHWTbody;

        //Sign the resulting string using RSA SHA256 Certificate
        //Crypto.signWithCertificate(algorithmName, input, certDevName), here algorithmName = 'RSA-SHA256'
        String signature = this.base64URLSafe(Crypto.signWithCertificate('RSA-SHA256', Blob.valueOf(accessToken), this.JWTConfig.JWTSignedCertName));
        System.debug('Signature: ' + signature);

        //Final Token = token + '.' + Token signature
        accessToken = accessToken + '.' + signature;
        return accessToken;
    }


    //Method to request Access Token from Server
    Public Map<String,String> RequestAccessToken() {
        String accessToken;

        http h = new http();
        HttpRequest req = new HttpRequest();
        //Set Header
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        //set Endpoint = https://login.salesforce.com/services/oauth2/token
        req.setEndpoint('https://' + this.JWTConfig.JWTHostName + '/services/oauth2/token');
        //Set POST Method
        req.setMethod('POST');
        //Set Timout
        req.setTimeout(60*1000);

        //Set Body
        Map<String,String> reqBodyMap = new Map<String,String>();
        reqBodyMap.put('grant_type','urn:ietf:params:oauth:grant-type:jwt-bearer');
        //Assertion  = JWT Token returned by method CreateJWTAccessToken()
        reqBodyMap.put('assertion',this.CreateJWTAccessToken());
        req.setBody(this.bodyEncode(reqBodyMap));

        //Send the Http request
        HttpResponse resp = h.send(req);
        system.debug('Status: ' + resp.getStatusCode());

        if(resp.getStatusCode() >= 200 && resp.getStatusCode() <= 300) {
            system.debug('JWT Response: ' + resp.getBody());
            Map<String,String> finalResp = new Map<String,String>();

            //Perse the Http Response to get the Access Token
            finalResp.put('access_token', this.extractJSONField(resp.getBody(),'access_token'));
            //Perse the Http Response to get the Instance URL
            finalResp.put('instance_url', this.extractJSONField(resp.getBody(),'instance_url'));
            
            return finalResp;
        }
        else {
            throw new JWTException(resp.getBody());
        }
    }    

    //Method to encode to Base64URL format
    Public String base64URLSafe(Blob b)  {
        return EncodingUtil.base64Encode(b).replace('+', '-').replace('/', '_');
    }

    Private String bodyEncode(Map<String,String> reqBodyMap) {
        String reqBody = '';
        //grant_type= urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=<TWT Token value>
        for(String key : reqBodyMap.keySet())   {
            if(reqBody.length() > 0)    {
                reqBody += '&';     
            }
            reqBody += key + '=' + EncodingUtil.urlEncode(reqBodyMap.get(key), 'UTF-8');
        }
        System.debug('Encoded reqBody: ' + reqBody);
        return reqBody;
    }

    Private String extractJSONField(String jsonStr, String fieldname)   {
        JSONParser jParser = JSON.createParser(jsonStr);
        while(jParser.nextToken() != NULL)  {
            if(jParser.getCurrentToken() == JSONToken.FIELD_NAME && jParser.getText() == fieldname) {
                jParser.nextToken();
                return jParser.getText();    
            }
        } 
        throw new JWTException(fieldname + ' not found in JSON Response');
    }
}
