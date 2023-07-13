import { LightningElement,track, api} from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class DynamicRecordEdit extends NavigationMixin(LightningElement) {
    
    @track showModal = false;
    @api recordId;
    @api objectApiName;
    @track isEditShowModal = false;
    @track isDeleteShowModal = false;

    showEditModalBox() {  
        this.isEditShowModal = true;
    }

    hideEditModalBox() {  
        this.isEditShowModal = false;
    }

    hideDeleteModalBox() {  
        this.isDeleteShowModal = false;
    }

    showDeleteModalBox() {  
        this.isDeleteShowModal = true;
    }

    handleEditSuccess(){
        this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record Edited',
                        variant: 'success'
                    })
        );
        this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Account',
                        actionName: 'home',
                    },
                });
        this.isEditShowModal = false;
    }
    handleDeleteRecord() {
        deleteRecord(this.recordId)
            .then(() => {
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
                        objectApiName: 'Account',
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