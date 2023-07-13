import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import deleteRecordUsingRecordId from '@salesforce/apex/recordDeleteController.deleteRecordUsingRecordId';

export default class RecordDeleteComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @track isDeleteShowModal = false;
    hideDeleteModalBox() {  
        this.isDeleteShowModal = false;
    }

    showDeleteModalBox() {  
        this.isDeleteShowModal = true;
    }
    handleDelete(event) {
        if(this.recordId){
            deleteRecordUsingRecordId({objectName: this.objectApiName, recordId: this.recordId})
            .then((result) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                );
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: this.objectApiName,
                        actionName: 'home',
                    },
                });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }
    }
}