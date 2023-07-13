// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
String test = '{"AnnualRevenue":null,"Country":"USA","City":null,"CleanStatus":"Pending","Company":"Cadinal Inc.","Email":"brenda@cardinal.net","Fax":null,"Industry":null,"FirstName":"Brenda","Name":"Brenda Mcclure","LastName":"Mcclure","MobilePhone":null,"Status":"Closed - Not Converted"}';
//leadRecordEditController.updateRecord(test,'00Q2w00000SwETLEA3', 'Lead');
//System.debug(leadRecordEditController.getPickListOption('Lead', 'Status', 'Closed - Not Converted'));
System.debug(leadRecordEditController.getApiToValue('Lead','00Q2w00000SwETLEA3'));