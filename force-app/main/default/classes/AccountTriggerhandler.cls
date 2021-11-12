public with sharing class AccountTriggerhandler {
    
    public void beforeInsert(List<Account> accList)  {
        for(Account acc : accList)    {
            system.debug('Inside beforeInsert Method : ' + acc);
            if(acc.NumberOfEmployees == 0 || acc.NumberOfEmployees == NULL)  {
                acc.NumberOfEmployees = 1;
            }
            system.debug('Outside beforeInsert Method Loop: ' + acc);
        }
    }

    public void afterInsert(List<Account> accList)  {
        List<Contact> conList = new List<Contact>();
        Integer counter = 1;

        for(Account acc : accList)  {
            System.debug('Account : ' + acc);
            while(counter <= acc.NumberOfEmployees) {
                Contact con = new Contact();    
                con.AccountId = acc.Id;
                con.LastName = acc.Name + counter;
                conList.add(con);
                counter++;
            }
        }

        System.debug('Contact List : ' + conList);
        if(conList.size() > 0)   {
            Insert conList;
        } 
    }    

}