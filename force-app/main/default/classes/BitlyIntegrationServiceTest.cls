@isTest()
public class BitlyIntegrationServiceTest {
    
    @isTest()
    public static void GenerateShortenURLTest() {
        String courseLongURL = 'https://www.udemy.com/course/salesforce-integration-bydebasis/learn/lecture';

        test.startTest();

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setHeader('Content-Type','application/json');
        mock.setStaticResource('BitlyIntegrationTestJSON');
        mock.setStatusCode(200);
        test.setMock(HttpCalloutMock.class, mock);

        BitlyIntegrationService bitlyService = new BitlyIntegrationService();
        String shortUTL = bitlyService.GenerateShortenURL(courseLongURL);
        test.stopTest();

        system.assertEquals('https://www.bturl/343.com', shortUTL);
    }
}
