@isTest()
public class AccountReplicationSoapMock implements WebServiceMock {

    public void doInvoke(Object stub,
                         Object request,
                         Map<String, Object> response,
                         String endpoint,
                         String soapAction,
                         String requestName,
                         String responseNS,
                         String responseName,
                        String responseType)  {

      // start - specify the response you want to send                        
      soapAccountCreation.createNewAccountResponse_element response_x = new soapAccountCreation.createNewAccountResponse_element();
      response_x.result = '0015j000009jQ5VAAU';
      // end
      response.put('response_x',response_x);
    }
}
