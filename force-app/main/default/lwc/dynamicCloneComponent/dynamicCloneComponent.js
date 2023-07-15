import { LightningElement, api, track } from 'lwc';
import getApiToValue from '@salesforce/apex/DynamicCloneController.getApiToValue';
import cloneRecord from '@salesforce/apex/DynamicCloneController.cloneRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class DynamicCloneComponent extends NavigationMixin(LightningElement) {
    @track apiToValue;
    @api recordId;
    @api objectApiName;
    @track isShowModal = false;
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
    hideModalBox() {  
        this.isShowModal = false;
    }

    showModalBox() {  
        this.isShowModal = true;
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
    handleClone(){
        cloneRecord({
            apiToValue : JSON.stringify(this.dataToUpdate),
            recordId : this.recordId, 
            objectName: this.objectApiName,
            fieldSetName: 'Opportunity_FieldSet'
        })
        .then ( result => {
            console.log('result '+ result);
            this.dispatchEvent(
                new ShowToastEvent({
                  title: 'Success',
                  message: 'Record updated successfully',
                  variant: 'success'
                })
            );
            // this[NavigationMixin.Navigate]({
            //     type: 'standard__recordPage',
            //     attributes: {
            //         recordId: this.recordId,
            //         objectApiName: this.objectApiName,
            //         actionName: 'view'
            //     }
            // });
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