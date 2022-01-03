@isTest()
public class AccountReplicationProcessTest {

    @isTest()
    public static void CloneToServerTest()  {
        Test.startTest();

        //send this fake response by calling Mock Class which implements HttpCalloutMock
        test.setMock(HttpCalloutMock.class, new AccountReplicationRestMock());

        AccountReplicationProcess.CloneToServer();
        Test.stopTest();

        system.assertEquals('Fake_Response_Token', AccountReplicationProcess.accessToken);

    }

    @isTest()
    public static void replicateDataTest()  {
        Test.startTest();
        
        test.setMock(WebServiceMock.class, new AccountReplicationSoapMock());
        string accName ='Kuntal23'; 
        string accNumber = '34343433';
        string accIndustry = 'Chemicals';
        string accRating = 'Hot';     
        string annualRevenueDbl = '482100';
        String accId = AccountReplicationProcess.replicateData(accName, accNumber, accIndustry, annualRevenueDbl, accRating);
        test.stopTest();

        System.assertEquals('0015j000009jQ5VAAU', accId);
    }
}
