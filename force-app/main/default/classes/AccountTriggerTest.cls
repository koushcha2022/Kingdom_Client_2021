@isTest
private class AccountTriggerTest {

    @isTest
    private static void AccountInsertTest()   {

        Account acc = New Account();
        acc.Name = 'Test Account';
        Test.startTest();
        Insert acc;
        Test.stopTest();

        Account accFound = [Select Id,Name,NumberOfEmployees From Account Where Id= :acc.Id Limit 1];
        System.assertEquals(1, accFound.NumberOfEmployees, 'Success');

        List<Contact> conList = [Select Id,LastName,AccountId From Contact Where AccountId= :acc.Id]; 
        system.assert(conList.size() > 0, 'Success');
    }
}
