import { LightningElement, wire, track } from "lwc"
import getOpportunities from "@salesforce/apex/showOpportunityController.getOpportunities"
import getProducts from "@salesforce/apex/showOpportunityController.getProducts"

export default class showOpportunity extends LightningElement {
  @track allData = []
  @track opportunitiesWithProducts = []
  allProducts = []
  productsMap = new Map()
  showChild;
  
  constructor(){
    super();
    this.showChild = false;
  }

  onClick() {
    console.log('entrei');
    this.showChild = true;
    this.dispatchEvent(new CustomEvent('productmanager',{
        detail: {showChild: this.showChild},
        bubbles: true,
        composed: true
    }));
  }

  @wire(getOpportunities)
  wireData({ error, data }) {
    if (data) {
      this.allData = data
      const opportunityIds = []

      Object.values(this.allData).forEach((opportunity) => {
        opportunityIds.push(opportunity.Id)
      })

      this.fetchProducts(opportunityIds)
    } else if (error) {
      console.error("Error fetching opportunities:", error)
    }
  }

  async fetchProducts(opportunityIds) {
    try {
      this.allProducts = await getProducts({ opportunityIds: opportunityIds })

      this.productsMap.clear()

      for (let i = 0; i < this.allProducts.length; i++) {
        const opportunityId = this.allProducts[i].Opportunity__c
        const product = this.allProducts[i]

        if (opportunityId) {
          if (!this.productsMap.has(opportunityId)) {
            this.productsMap.set(opportunityId, [])
          }
          this.productsMap.get(opportunityId).push(product)
        }
      }

      this.opportunitiesWithProducts = this.allData.map((opp) => {
        return {
          ...opp,
          products: this.productsMap.get(opp.Id) || [],
        }
      })

    } catch (error) {
      console.error("Error fetching products:", error)
    }
  }
}
