@isTest
private class CalculatorTestClass {

    @isTest
    private static void addTest()   {
        //Actual Test
        Test.startTest();
        CalculatorClass c1 = new CalculatorClass();
        double result = c1.Addition(10, 5);
        system.assertEquals(15, result,'success');
        Test.stopTest();
    }

    @isTest
    private static void substractTest()   {
        //Actual Test
        Test.startTest();
        CalculatorClass c1 = new CalculatorClass();
        double result = c1.Substraction(10, 5);
        system.assertEquals(5, result,'success');
        Test.stopTest();
    }

    @isTest
    private static void multiTest()   {
        //Actual Test
        Test.startTest();
        CalculatorClass c1 = new CalculatorClass();
        double result = c1.Multiplication(10, 5);
        system.assertEquals(50, result,'success');
        Test.stopTest();
    }

    @isTest
    private static void divisionTest()  {
        Test.startTest();
        CalculatorClass c1 = new CalculatorClass();
        double result = c1.Division(10, 5);
        system.assertEquals(2, result,'success');
        Test.stopTest();
    }
}
