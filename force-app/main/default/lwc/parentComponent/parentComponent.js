import { LightningElement, api, track} from 'lwc';
import getFields from '@salesforce/apex/DynamicRecordEditFormController.getFields';
import updateRecord from '@salesforce/apex/DynamicRecordEditFormController.updateRecord';
export default class ParentComponent extends LightningElement {
    @api recordId; // Record Id passed from parent component or record page
    @track fields = []; // Array to store the fields from FieldSet
    @track dataNeedToUpdate;
    connectedCallback() {
        // Call Apex method to get the fields from FieldSet
        getFields({ fieldSetName: 'Account_Fieldset', objectName: 'Account', recordId: this.recordId})
            .then((result) => {
                //this.fields = result;
                console.log('running');
                //console.log('data -- : ' + 'recordId ' + this.recordId, JSON.parse(result));
                this.fields = JSON.parse(result);
                console.log(this.fields[0].recordDetails.AccountNumber);
                this.fields.forEach(fields => {
                    let apiName = fields.fieldApiName;
                    fields.Value = fields.recordDetails[apiName];
                });
                this.dataNeedToUpdate = this.fields[0].recordDetails;
            })
            .catch((error) => {
                console.error(error);
            });
    }
    handleChange(event){
         const index = event.target.dataset.index;
         let fieldAPIName = event.target.name;
         console.log(JSON.stringify(this.dataNeedToUpdate));
         this.dataNeedToUpdate[fieldAPIName] = event.target.value;
         console.log(JSON.stringify(this.dataNeedToUpdate)); 
    }
    getValue(event){
        const index = event.target.dataset.index;
        //return this.fields[0].recordDetails.apiName;
        //console.log('Index : ' + index);
    }

    handleUpdate(){
        // updateRecord({recordToUpdate: this.dataNeedToUpdate})
        // .then( result => {
        //     console.log('RecordUpdated');
        // })
        // .catch( error => {
        //     console.log('Error: ' + JSON.stringify(error));
        // })
    }
}