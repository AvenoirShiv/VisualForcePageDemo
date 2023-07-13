import { LightningElement,api  } from 'lwc';
import Account from '@salesforce/schema/Account';

export default class DynamicRecordCompoent2 extends LightningElement {
    @api recordId;
    @api objectApiName;
}