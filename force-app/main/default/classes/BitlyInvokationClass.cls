public with sharing class BitlyInvokationClass {

    @InvocableMethod(label='Shorten URL' description='Generate Short URL with Birly API') 
    Public Static Void InvokeBitlyService(List<Id> CourseIds)    {
        System.debug('ID : ' + CourseIds[0]);
        InvokeBitlyServiceFuture(CourseIds);
    }    

    @future(callout=true)
    Public Static Void InvokeBitlyServiceFuture(List<Id> CourseIds)    {
        List<Udemy_Course__c> courseList = [SELECT Id, Name, Course_URL__c, Coupon_Code__c, Short_URL__c FROM Udemy_Course__c 
                                           WHERE Id IN :CourseIds];
        system.debug('Size :' + courseList.size());
        if(courseList.size() > 0)   {
            BitlyIntegrationService bServiceObj = new BitlyIntegrationService();
            for(Udemy_Course__c course : courseList)    {
                if(course.Short_URL__c == NULL || course.Short_URL__c == '')    {
                    String fullURL = course.Course_URL__c;
                    if(course.Coupon_Code__c != NULL)   {
                        fullURL +=  '?couponCode=' + course.Coupon_Code__c;   
                        System.debug('fullURL :' + fullURL);
                    }
                    String shortURL = bServiceObj.GenerateShortenURL(fullURL);
                    system.debug('shortURL : ' + shortURL);
                    course.Short_URL__c = shortURL;       
                }   
            }   
            Update courseList;
        }
    }

}
