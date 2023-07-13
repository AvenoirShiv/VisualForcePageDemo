// editRecordPage.js
import { LightningElement, wire, api,track } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getsObjectFields from '@salesforce/apex/DynamicRecordEditFormController.getsObjectFields'
var FIELDS1 = [
    'Account.Name',
];
export default class EditRecordPage extends LightningElement {
  @api recordId;
  @api objectApiName;
  @api fieldApiNames;
  @track fieldApiNames1
  @track data1;

//   connectedCallback() {
//       this.getsObjectReledtedField();
//   }
//   getsObjectReledtedField(){
//       getsObjectFields()
//       .then(data => {
//           console.log('data --- : ' + JSON.stringify(data));
//           this.fieldApiNames1 = data;
//       })
//       .catch(error => {
//           console.log('Error');
//       })
//   }
  @wire(getsObjectFields) getsObjectReledtedField({data,error}){
      if(data){
        console.log('data --- : ' + JSON.stringify(data));
        this.fieldApiNames1 = data;
        }
        else if (error){
            console.log('Error');
        }
  }

//    @wire(getRecord, { recordId: '$recordId', fields: '$fieldApiNames1' })
//     wireContact({data, error}) {
//         if(data) {
//             console.log('data --- : ' + JSON.stringify(data));
//             this.record = data;
            
//         }
//         else if (error) {
//             console.log('error --- : ' + JSON.stringify(error));
//         }
//     }
  @wire(getRecord, { recordId: '$recordId', fields:FIELDS1})
  wiredRecord;

  check(){
      console.log('this is checking');
      console.log("data :--" + JSON.stringify(this.wiredRecord));
  }

  getFieldValue(fieldName) {
    if (this.wiredRecord.data) {
      return this.wiredRecord.data.fields[fieldName].value;
    }
    return undefined;
  }

  saveRecord() {
    const fields = {};
    fields['Id'] = this.recordId;
    this.fieldApiNames.forEach((fieldApiName) => {
      fields[fieldApiName] = this.getFieldValue(fieldApiName);
    });

    const recordInput = { fields };

    updateRecord(recordInput)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Record updated successfully',
            variant: 'success'
          })
        );
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: error.body.message,
            variant: 'error'
          })
        );
      });
  }
}