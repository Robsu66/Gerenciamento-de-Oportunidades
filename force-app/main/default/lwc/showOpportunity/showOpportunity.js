import { LightningElement, wire, track } from "lwc"
import { refreshApex } from "@salesforce/apex"
import getOpportunities from "@salesforce/apex/showOpportunityController.getOpportunities"
import getProducts from "@salesforce/apex/showOpportunityController.getProducts"

export default class ShowOpportunity extends LightningElement {
  allData = []
  opportunitiesWithProducts = []
  productsMap = new Map()
  showChild
  wiredOpportunitiesResult
  allProducts

  constructor() {
    super()
    this.showChild = false
    this.refresh = this.refresh.bind(this)
  }

  connectedCallback() {
    window.addEventListener("refresh", this.refresh)
  }

  refresh() {
    if (this.wiredOpportunitiesResult) {
      return refreshApex(this.wiredOpportunitiesResult)
        .then(() => {
          console.log("Atualizado")
        })
        .catch((error) => {
          console.error("Erro ao atualizar: ", error)
        })
    }
  }

  disconnectedCallback() {
    window.removeEventListener("refresh", this.refresh)
  }

  onClick() {
    this.showChild = true

    this.dispatchEvent(
      new CustomEvent("productmanager", {
        detail: { showChild: this.showChild },
        bubbles: true,
        composed: true,
      }),
    )
  }

  @wire(getOpportunities)
  wireData(result) {
    this.wiredOpportunitiesResult = result
    const { error, data } = result

    if (data) {
      this.allData = data
      const opportunityIds = []

      Object.values(this.allData).forEach((opportunity) => {
        opportunityIds.push(opportunity.Id)
      })

      this.fetchProducts(opportunityIds)
    } else if (error) {
      console.error("Error fetching opportunities: ", error)
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
      console.error("Error fetching products: ", error)
    }
  }
}