import { LightningElement, api, track } from 'lwc';
import getApiToValue from '@salesforce/apex/leadRecordEditController.getApiToValue';
import updateRecord from '@salesforce/apex/leadRecordEditController.updateRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LeadRecordEditPage extends LightningElement {
    @track apiToValue;
    @api recordId;
    @api objectApiName;
    isDataFound = false;
    @track dataToUpdate = {};
    connectedCallback(){
        console.log(this.recordId + "  " +this.objectApiName);
        getApiToValue({objectName : this.objectApiName, recordId : this.recordId, fieldSetName :'LeadFieldset'})
        .then( result => {
            let data = JSON.parse(result);
            this.apiToValue = data;
            if(this.apiToValue) {
                this.isDataFound = true;
            }
            console.log(JSON.stringify(this.apiToValue))
        })
        .catch(error => {

        })
    }

    handleChange(event) {
        this.dataToUpdate[event.target.name] = event.target.value;
    }
    handleUpdate(){
        updateRecord({
            apiToValue : JSON.stringify(this.dataToUpdate),
            recordId : this.recordId, 
            objectName: this.objectApiName,
            fieldSetName: 'LeadFieldset'
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