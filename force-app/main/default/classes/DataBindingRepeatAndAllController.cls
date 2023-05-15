public class DataBindingRepeatAndAllController {
    public string sortBY{get; set;}
    public string sortingOrder{get; set;}
    public List<Account> sortAccounts{get; set;}
    public Boolean renderSortedAccount{get; set;}
    public DataBindingRepeatAndAllController (){
        renderSortedAccount = false;
    }
    public List<Account> getAccounts() {
        return [
            SELECT
            	Id,
            	Name,
            	Phone
            FROM
            	Account
        ];
    }
    
    public PageReference sortAccounts(){
        String sortBy = System.currentPageReference().getParameters().get('sortBy');
        String sortingOrder = System.currentPageReference().getParameters().get('sortingOrder');
        String query = 'SELECT Id, Name, Phone FROM Account ORDER BY ' + sortBy + ' ' + sortingOrder;
        sortAccounts = Database.query(query);
        if(sortAccounts.size() > 0) {
            renderSortedAccount = true;
        }
        return null;
    }

}