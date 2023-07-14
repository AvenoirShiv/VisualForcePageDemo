import { LightningElement, api, track } from 'lwc';
import getApiToValue from '@salesforce/apex/leadRecordEditController.getApiToValue';
import updateRecord from '@salesforce/apex/leadRecordEditController.updateRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class LeadRecordEditPage extends NavigationMixin(LightningElement) {
    @track apiToValue;
    @api recordId;
    @api objectApiName;
    isDataFound = false;
    @track dataToUpdate = {};
    @track isEditShowModal = false;

    hideModalBox() {  
        this.isEditShowModal = false;
    }

    showModalBox() {  
        this.isEditShowModal = true;
    }

    connectedCallback(){
        getApiToValue({objectName : this.objectApiName, recordId : this.recordId, fieldSetName :'LeadFieldset'})
        .then( result => {
            let data = JSON.parse(result);
            this.apiToValue = data;
            if(this.apiToValue) {
                this.isDataFound = true;
            }
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
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: this.objectApiName,
                    actionName: 'view'
                }
            });
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