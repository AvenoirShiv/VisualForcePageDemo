public with sharing class sObjectDomain {
    public static List<Schema.FieldSetMember> getFields(String fieldSetName, String objectName) {
        // Get the SObjectType for the given object name
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        // Get the FieldSet for the given field set name and SObjectType
        Schema.FieldSet fieldSet = sObjectType.getDescribe().fieldSets.getMap().get(fieldSetName);
        return fieldSet.getFields();
    }

    public static string getApiToValue(String objectName, String recordId, String fieldSetName){
        List<Schema.FieldSetMember> fields = getFields(fieldSetName, objectName);
            sObject record =  getRecord(recordId,objectName, fieldSetName);
            Map<String , AllData> apiNameToOption = new Map<String, AllData>();
            for(Schema.FieldSetMember field : fields) {
                AllData data = new AllData();
                String dataType = getFieldDataType(objectName, field.getFieldPath());
                system.debug(dataType);
                if(dataType == 'PICKLIST'){
                   List<Option> options = getPickListOption(objectName, field.getFieldPath(), 
                        (string)record.get(field.getFieldPath()));
                   data.value = record.get(field.getFieldPath());
                   data.options = options;
                }
                else if (dataType == 'REFERENCE') {
                    String referenceObjectName = getParentObjectName(objectName, field.getFieldPath());
                    List<Option> options = getReferenceOption(referenceObjectName,
                        field.getFieldPath(), (String)record.get(field.getFieldPath()));
                    data.value = record.get(field.getFieldPath());
                    data.options = options;
                }
                // else if (dataType == 'BOOLEAN') {
                //     String referenceObjectName = getParentObjectName(objectName, field.getFieldPath());
                //     List<Option> options = getReferenceOption(referenceObjectName,
                //         field.getFieldPath(), (String)record.get(field.getFieldPath()));
                //     data.value = record.get(field.getFieldPath());
                //     data.options = options;
                // }
                else {
                    if(dataType == 'CURRENCY' || dataType == 'DOUBLE'){
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
    public static void updateRecord(String apiToValue, String recordId, 
            string objectName , string fieldSetName){
        sObject record = getRecord(recordId, objectName, fieldSetName);
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(apiToValue);
            
        for(String fieldName : params.keySet()) {
            if( fieldName != 'Name'){
                String dataType = getFieldDataType(objectName, fieldName);
                if(dataType == 'CURRENCY' || dataType == 'DOUBLE' || dataType == 'PERCENT'){
                    record.put(fieldName, Double.valueOf(params.get(fieldName)));
                }
                else if(dataType == 'BOOLEAN'){
                    record.put(fieldName, Boolean.valueOf(params.get(fieldName)));
                }
                else if (dataType == 'DATE') {
                    Integer year = Integer.valueOf(params.get(fieldName).toString().substring(0, 4));
                    Integer month = Integer.valueOf(params.get(fieldName).toString().substring(5, 7));
                    Integer day = Integer.valueOf(params.get(fieldName).toString().substring(8, 10));
                    Date convertedDate = Date.newInstance(year, month, day);
                    record.put(fieldName, convertedDate);
                }
                else {
                    record.put(fieldName, params.get(fieldName));
                }
            }
        }
        update record;
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

    public static sObject getRecordWithRecordId(string objectName, String recordId) {
        String query = 'SELECT id FROM ' + objectName + ' WHERE id = ' + '\'' + recordId + '\'';
        return database.query(query);
    }
    public static void deleteRecord(string objectName, String recordId) {
        delete getRecordWithRecordId(objectName,recordId);
    }

    public static List<Option> getReferenceOption(String objectName, string fieldName, String value){
        String query = 'SELECT Id, Name From ' + objectName + ' ORDER BY CreatedDate DESC';
        List<sObject> sobjects = database.query(query);
        //System.debug(sobjects);
        List<Option> optionsList = new List<Option>();
        for( sObject currentObject : sobjects){
            if(currentObject.get('Id') == value) {
                Option opt = new Option();
                opt.label =  (String)currentObject.get('Name');
                opt.value =  currentObject.get('Id');
                opt.isSelected = true;
                optionsList.add(opt);
            }
            else {
                Option opt1 = new Option();
                opt1.label =  (String)currentObject.get('Name');
                opt1.value =  currentObject.get('Id');
                optionsList.add(opt1);
            }
        }
        return optionsList;
    }

    public static String getParentObjectName(String objectName, String fieldName) {
        try {
            SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            if (objectType != null) {
                Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
                if (objectDescribe.fields.getMap().containsKey(fieldName)) {
                    Schema.DescribeFieldResult fieldDescribe = 
                        objectDescribe.fields.getMap().get(fieldName).getDescribe();
                    if (!fieldDescribe.getReferenceTo().isEmpty()) {
                        return fieldDescribe.getReferenceTo().get(0).getDescribe().getName();
                    }
                }
            }
        } catch (Exception e) {
            // Handle any exceptions
        }
        return null;
    }   
}