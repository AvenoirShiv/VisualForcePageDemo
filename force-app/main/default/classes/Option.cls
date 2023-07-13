public with sharing class Option {
    @AuraEnabled
    public string label;
    @AuraEnabled
    public object value;
    @AuraEnabled
    public boolean isSelected = false;
    public Option() {
        
    }
}