import { LightningElement, api, track } from 'lwc';
import getApiToValue from '@salesforce/apex/leadRecordEditController.getApiToValue';
import updateRecord from '@salesforce/apex/leadRecordEditController.updateRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ChildComponent extends LightningElement {
    @track apiToValue;
    @api recordId;
    @api objectApiName;
    isDataFound = false;
    @track dataToUpdate = {};
    connectedCallback(){
        getApiToValue({objectName : this.objectApiName, recordId : this.recordId, fieldSetName :'Opportunity_FieldSet'})
        .then( result => {
            let data = JSON.parse(result);
            this.apiToValue = data;
            if(this.apiToValue) {
                this.isDataFound = true;
            }
            console.log('Data : ' + JSON.stringify(this.apiToValue));
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                  title: 'Error',
                  message: error.body.message,
                  variant: 'error'
                })
            );
        })
    }

    handleChange(event) {
        if(event.target.type == 'checkbox') {
            if(event.target.checked) {
                this.dataToUpdate[event.target.name] = true;
            }
            else {
                this.dataToUpdate[event.target.name] = false; 
            }
        }
        else {
            this.dataToUpdate[event.target.name] = event.target.value;
        }
    }
    handleUpdate(){
        updateRecord({
            apiToValue : JSON.stringify(this.dataToUpdate),
            recordId : this.recordId, 
            objectName: this.objectApiName,
            fieldSetName: 'Opportunity_FieldSet'
        })
        .then ( result => {
            this.dispatchEvent(
                new ShowToastEvent({
                  title: 'Success',
                  message: 'Record updated successfully',
                  variant: 'success'
                })
            );
        })
        .catch (error => {
            this.dispatchEvent(
                new ShowToastEvent({
                  title: 'Error',
                  message: error.body.message,
                  variant: 'error'
                })
            );
        })
    }
}