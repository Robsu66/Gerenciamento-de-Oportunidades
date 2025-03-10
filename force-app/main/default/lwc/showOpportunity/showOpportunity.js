import { LightningElement, api, wire, track } from 'lwc';
import getOpportunities from '@salesforce/apex/showOpportunityController.getOpportunities';
import getProducts from '@salesforce/apex/showOpportunityController.getProducts';

export default class OpportunityForm extends LightningElement {
    
    spinner = false;
    allData;
    allProducts = [];
    productsMap = new Map();

    @wire(getOpportunities)
    wireData({error, data}) {
        if (data) {
            this.allData = data;
            let opportunityIds = [];
            
            Object.values(this.allData).forEach(opportunity => {
                opportunityIds.push(opportunity.Id);
            });

            this.fetchProducts(opportunityIds);
        } else if (error) {
            console.error("Error fetching opportunities:", error);
        }
    }

    async fetchProducts(opportunityIds) {
        try {
            this.allProducts = await getProducts({ opportunityIds: opportunityIds });
            console.log("Products:", this.allProducts);
            console.log(opportunityIds);

            this.productsMap.clear();

            for (let i = 0; i < this.allProducts.length; i++) {
                let opportunityId = this.allProducts[i].Opportunity__c;
                let product = this.allProducts[i];

                if (opportunityId) {
                    if (!this.productsMap.has(opportunityId)) {
                        this.productsMap.set(opportunityId, []);
                    }
                    this.productsMap.get(opportunityId).push(product);
                }
            }

            console.log("Products grouped by Opportunity:", this.productsMap);

        } catch (error) {
            console.error("Error fetching products:", error);
        }
    }
}
