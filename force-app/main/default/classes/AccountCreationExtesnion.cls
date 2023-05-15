public class AccountCreationExtesnion {
    public Account newAccount{get; set;}
    
    public AccountCreationExtesnion(ApexPages.StandardController controller) {
        newAccount = new Account();
    }
    
    public PageReference save(){
        //System.debug('Account : ' + newAccount);
        if(newAccount != null) {
            newAccount.AccountNumber = '232131231212';
            insert newAccount;
            PageReference pageRef = new PageReference('/'+newAccount.Id);
            return pageRef;
        }
        return null;
    }


}