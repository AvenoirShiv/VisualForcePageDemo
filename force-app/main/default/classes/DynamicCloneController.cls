public with sharing class DynamicCloneController {
    @AuraEnabled
    public static String getApiToValue(String objectName, String recordId, String fieldSetName){
        try {
            return sObjectDomain.getApiToValue(objectName, recordId,fieldSetName);
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
    }
    @AuraEnabled
    public static void cloneRecord(String apiToValue, String recordId, string objectName , string fieldSetName){
        try {
            sObjectDomain.cloneRecord(apiToValue, recordId, objectName ,fieldSetName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}