public with sharing class leadRecordEditController {
    public static List<Schema.FieldSetMember> getFields(String fieldSetName, String objectName) {
        // Get the SObjectType for the given object name
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        // Get the FieldSet for the given field set name and SObjectType
        Schema.FieldSet fieldSet = sObjectType.getDescribe().fieldSets.getMap().get(fieldSetName);
        return fieldSet.getFields();
    }

    @AuraEnabled
    public static String getApiToValue(String objectName, String recordId, String fieldSetName){
        try {
            List<Schema.FieldSetMember> fields = getFields(fieldSetName, objectName);
            sObject record =  getRecord(recordId,objectName, fieldSetName);
            Map<String , AllData> apiNameToOption = new Map<String, AllData>();
            for(Schema.FieldSetMember field : fields) {
                AllData data = new AllData();
                String dataType = getFieldDataType(objectName, field.getFieldPath());
                if(dataType == 'PICKLIST'){
                   List<Option> options = getPickListOption(objectName, field.getFieldPath(), (string)record.get(field.getFieldPath()));
                   data.value = record.get(field.getFieldPath());
                   data.options = options;
                }
                else {
                    if(dataType == 'CURRENCY'){
                        data.value = Double.valueOf(record.get(field.getFieldPath()));
                        data.options = null;
                    }
                    else {
                        data.value = record.get(field.getFieldPath());
                        data.options = null;
                    }
                }
                apiNameToOption.put(field.getFieldPath(),data);
            }
            return Json.serialize(apiNameToOption);
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
    }
    public static sObject getRecord(String recordId, String objectName, String fieldSetName){
        List<Schema.FieldSetMember> fields = getFields(fieldSetName, objectName );
        String query = 'SELECT ';
        for(Schema.FieldSetMember field : fields) {
            query += field.getFieldPath() + ', ';
        }
        query = query.substring(0,query.length()-2);
        query += ' FROM ' + objectName + ' WHERE id = ' + '\'' + recordId + '\'';
        return database.query(query);
            
    }
    @AuraEnabled
    public static void updateRecord(String apiToValue, String recordId, string objectName , string fieldSetName){
        try {
           System.debug(apiToValue);
            sObject record = getRecord(recordId, objectName, fieldSetName);
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(apiToValue);
            
            for(String fieldName : params.keySet()) {
                if( fieldName != 'Name'){
                    String dataType = getFieldDataType(objectName, fieldName);
                    if(dataType == 'CURRENCY' || dataType == 'DOUBLE'){
                        record.put(fieldName, Double.valueOf(params.get(fieldName)));
                    }
                    else {
                        record.put(fieldName, params.get(fieldName));
                    }
                }
            }
            update record;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static String getFieldDataType(String objectName, String fieldName) {
        try {
            SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            if (objectType != null) {
                Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
                if (objectDescribe.fields.getMap().containsKey(fieldName)) {
                    Schema.SObjectField field = objectDescribe.fields.getMap().get(fieldName);
                    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                    return String.valueOf(fieldDescribe.getType());
                }
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    public static List<Option> getPickListOption(String objectName, string fieldName, String value){
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<Option> optionsList = new List<Option>();
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.getValue() == value) {
                Option opt = new Option();
                opt.label =  pickListVal.getLabel();
                opt.value =  pickListVal.getValue();
                opt.isSelected = true;
                optionsList.add(opt);
            }
            else {
                Option opt1 = new Option();
                opt1.label =  pickListVal.getLabel();
                opt1.value =  pickListVal.getValue();
                optionsList.add(opt1);
            }
        }
        return optionsList;
    }
    public class AllData{
        @AuraEnabled
        public object value;
        @AuraEnabled
        public List<Option> options;

    }
    public class Option {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public object value;
        @AuraEnabled
        public boolean isSelected = false;
    } 
}