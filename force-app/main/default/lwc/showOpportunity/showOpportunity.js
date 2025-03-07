import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpportunityForm extends LightningElement {
    
    spinner = false;

    handleSubmit(event) {
        this.spinner = true;
        event.preventDefault();
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        const toastEvent = new ShowToastEvent({
            title: 'Sucesso',
            message: 'Produto adicionado com sucesso',
            variant: 'success',
        });
        this.dispatchEvent(toastEvent);
        this.spinner = false;
        
    }
}