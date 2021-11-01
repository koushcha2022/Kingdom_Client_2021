public with sharing class PhoneVerificationAPI {

    Public Static PhoneResponse InvokeVeriphoneAPI(String phoneNumber)  {
        String veriphoneEndpoint = 'https://api.veriphone.io/v2/verify';
        String veriphoneAPIKey = 'CFDDCD33B3574FC78DF7A41C8987354A';
        PhoneResponse pResp;
        system.debug('Call from VerifyPhoneNumber Method');

        //https://api.veriphone.io/v2/verify?phone=2B49-15123577723&key=266B0091BC9547A2A40DD088795FA4C6
        veriphoneEndpoint += '?phone=' + phoneNumber + '&key=' + veriphoneAPIKey; 
        system.debug('Endpoint: ' + veriphoneEndpoint);

        Http h = new http();
        HttpRequest hreq = new HttpRequest();
        hreq.setEndpoint(veriphoneEndpoint);
        hreq.setMethod('GET');
        hreq.setTimeout(60000);

        HttpResponse resp = h.send(hreq);
        if(resp.getStatusCode() == 200) {
            pResp = (PhoneResponse)JSON.deserializeStrict(resp.getBody(), PhoneResponse.class);    
        }
        return pResp;
    }

    @InvocableMethod(label='Verify Phone Number' description='Makes API call to verify Phone Number')
    Public Static List<Boolean> VerifyPhoneNumber(List<String> phoneNumbers)   {
        List<Boolean> boolReturn = new List<Boolean>(); 
        PhoneResponse phoneResp = InvokeVeriphoneAPI(phoneNumbers[0]);
        If(phoneResp != NULL)   {
            // return new List<Boolean> {phoneResp.phone_valid}; 
            boolReturn.add(phoneResp.phone_valid);
        } else {
            boolReturn.add(false);
        }
        return boolReturn;
    }

    //Wrapper Class
    public class PhoneResponse    {
        Public String status;
        Public String phone;
        Public Boolean phone_valid;
        Public String phone_type;
        Public String phone_region;
        Public String country;
        Public String country_code;
        Public String country_prefix;
        Public String international_number;
        Public String local_number;
        Public String e164;
        Public String carrier;
    }
}
