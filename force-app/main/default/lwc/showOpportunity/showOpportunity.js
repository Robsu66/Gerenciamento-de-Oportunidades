import { LightningElement, wire, track } from "lwc"
import getOpportunities from "@salesforce/apex/showOpportunityController.getOpportunities"
import getProducts from "@salesforce/apex/showOpportunityController.getProducts"

export default class OpportunityForm extends LightningElement {
  spinner = false
  @track allData = []
  @track opportunitiesWithProducts = []
  allProducts = []
  productsMap = new Map()

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
      console.log(opportunityIds)

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

      // Create a new array with opportunities and their products
      this.opportunitiesWithProducts = this.allData.map((opp) => {
        return {
          ...opp,
          products: this.productsMap.get(opp.Id) || [],
        }
      })

      const arrayOfEntries = Array.from(this.productsMap.entries())
      console.log("" + arrayOfEntries)
    } catch (error) {
      console.error("Error fetching products:", error)
    }
  }
}

