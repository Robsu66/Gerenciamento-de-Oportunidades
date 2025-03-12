import { LightningElement, wire, track } from "lwc"
import { ShowToastEvent } from "lightning/platformShowToastEvent"
import { NavigationMixin } from "lightning/navigation"

export default class OpportunityProductManager extends NavigationMixin(LightningElement) {
  spinner = false
  showChild = false;
  
  connectedCallback(){
    window.addEventListener('productmanager', this.handleProductManager);
  }

  handleProductManager = (event) =>{
    console.log(this.showChild);
    this.showChild = event.detail.showChild;
    console.log(this.showChild)
  }

  disconnectedCallback(){
    window.removeEventListener('productmanager', this.handleProductManager);
  }

  handleSubmit(){
    this.spinner = true;
  }

  handleSuccess(){
    const toastEvent = new ShowToastEvent({
            title: 'Registro Criado',
            message: 'Seu registro foi criado com sucesso',
            variant: 'success',
    });
    this.dispatchEvent(toastEvent);
    this.spinner = false;
  }

  handleError(){
    const toastEvent = new ShowToastEvent({
            title: 'Erro ao salvar registro',
            message: 'Houve um erro ao criar o registro',
            variant: 'error',
    });
    this.dispatchEvent(toastEvent);
    this.spinner = false;
  }
}