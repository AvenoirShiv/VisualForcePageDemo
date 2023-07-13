public with sharing class recordDeleteController {
    @AuraEnabled
    public static void deleteRecordUsingRecordId(String objectName, String recordId){
       sObjectDomain.deleteRecord(objectName,recordId);
    }
}