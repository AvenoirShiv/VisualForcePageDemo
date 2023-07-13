public class DynamicRecordEditFormController {
    @AuraEnabled(cacheable=true)
    public static List<String> getsObjectFields(){
        SObjectType contactType = Schema.getGlobalDescribe().get('Account');
        Map<String,Schema.SObjectField> mfields = contactType.getDescribe().fields.getMap();
        
        List<String> sObjectDetailsList = new List<String>();
        for(String s : mfields.keySet()){
            sObjectDetailsList.add('Account.' + String.valueOf(mfields.get(s)));
        }
        return sObjectDetailsList;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getFields(String fieldSetName, String objectName, String recordId) {
        // Get the SObjectType for the given object name
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        
        // Get the FieldSet for the given field set name and SObjectType
        Schema.FieldSet fieldSet = sObjectType.getDescribe().fieldSets.getMap().get(fieldSetName);
        Sobject getRecord = getRecordDetails(objectName, recordId, fieldSet);
        System.debug('getRecord + ' + getRecord);
        // Return the list of fields from the FieldSet
        List<FieldWrapper> allFields = new List<FieldWrapper>();
        for(Schema.FieldSetMember field :fieldSet.getFields()) {
            if(String.valueOf(field.getType()) == 'PICKLIST'){
                FieldWrapper wrapper = new FieldWrapper();
                isFieldType isFieldType = new isFieldType();
                wrapper.fieldApiName = field.getFieldPath();
                wrapper.fieldType = String.valueOf(field.getType());
                wrapper.fieldLabel = field.getLabel();
                wrapper.option = getPickListOption(objectName,field.getFieldPath());
                isFieldType.isPickListComponent = true;
                wrapper.isFieldType= isFieldType;
                wrapper.recordDetails = getRecord;
                allFields.add(wrapper);
            }
            else if(String.valueOf(field.getType()) == 'STRING') {
                FieldWrapper wrapper = new FieldWrapper();
                isFieldType isFieldType = new isFieldType();
                wrapper.fieldApiName = field.getFieldPath();
                wrapper.fieldType = String.valueOf(field.getType());
                wrapper.fieldLabel = field.getLabel();
                wrapper.option = null;
                isFieldType.isTextComponent = true;
                wrapper.isFieldType= isFieldType;
                wrapper.recordDetails = getRecord;
                allFields.add(wrapper);
            }
        }
        System.debug('sss ' + allFields);
        return Json.serialize(allFields);
    }
    
    public static List<PickList> getPickListOption(String objectName, string fieldName){
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<PickList> options = new List<PickList>();
        for( Schema.PicklistEntry pickListVal : ple){
            options.add(new PickList(pickListVal.getLabel(), pickListVal.getValue()));
        }
        return options;
    }
    public static Sobject getRecordDetails(String objectName, String recordId, Schema.FieldSet fieldSet) {
        String query = 'SELECT ';
        for(Schema.FieldSetMember field :fieldSet.getFields()) {
            query += field.getFieldPath() + ', ';
        }
        query = query.substring(0,query.length()-2);
        query += ' FROM ' + objectName + ' WHERE id = ' + '\'' + recordId + '\'';
        System.debug('Query: ' + query);
        return Database.query(query);
    }

    @AuraEnabled
    public static void updateRecord (String recordToUpdate){
        system.debug('SObject ' + recordToUpdate);
        //update recordToUpdate;
    }
    public class FieldWrapper{
        @AuraEnabled
        public String fieldApiName;
        @AuraEnabled
        public String fieldType;
        @AuraEnabled
        public String fieldLabel;
        @AuraEnabled
        public Sobject recordDetails;
        @AuraEnabled
        public List<PickList> option;
        @AuraEnabled
        public isFieldType isFieldType;
    }
    public class PickList{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        
        PickList(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    public class isFieldType {
        @AuraEnabled
        public Boolean isTextComponent = false;
        @AuraEnabled
        public Boolean isCheckboxComponent = false;
        @AuraEnabled
        public Boolean isDateComponent = false;
        @AuraEnabled
        public Boolean isReferenceComponent = false;
        @AuraEnabled
        public Boolean isLongTextAreaComponent = false;
        @AuraEnabled
        public Boolean isPickListComponent = false;
    }
}