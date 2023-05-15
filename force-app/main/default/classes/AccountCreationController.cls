public class AccountCreationController {
    public Account newAccount{get; set;}
    public Contact newRelatedContact{get; set;}
    
    public AccountCreationController() {
        newAccount = new Account();
        newRelatedContact = new Contact();
    }
    
    public PageReference saveAccount(){
        System.debug('Account : ' + newAccount);
        if(newAccount != null) {
            insert newAccount;
            PageReference pageRef = new PageReference('/'+newAccount.Id);
            return pageRef;
        }
        return null;
    }
    
    public PageReference createContact() {
        if(newRelatedContact != null) {
            insert newRelatedContact;
            PageReference pageRef = new PageReference('/'+newRelatedContact.Id);
            System.debug('pageRef : ' + pageRef);
            return pageRef;
		}
        return null;
	}
}