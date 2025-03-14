import { LightningElement, wire, track } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getOpportunities from "@salesforce/apex/showOpportunityController.getOpportunities";

export default class ShowOpportunity extends LightningElement {
    @track allData = [];
    @track filteredData = [];
    showChild;
    wiredOpportunitiesResult;

    searchName;
    startDate;
    endDate;
    searchStage;

    constructor(){
      super()
      this.showChild = false;
      this.searchName = '';
      this.startDate = '';
      this.endDate = '';
      this.searchStage = '';
      this.refresh = this.refresh.bind(this);
    }

    stageOptions = [
        { label: 'All', value: '' },
        { label: 'Prospecting', value: 'Prospecting' },
        { label: 'Qualification', value: 'Qualification' },
        { label: 'Need Analysis', value: 'Need Analysis' },
        { label: 'Value Proposition', value: 'Value Proposition' },
        { label: 'Id. Decision Makers', value: 'Id. Decision Makers' },
        { label: 'Perception Analysis', value: 'Perception Analysis' },
        { label: 'Proposal', value: 'Proposal' },
        { label: 'Negotiation', value: 'Negotiation' },
        { label: 'Approved', value: 'Approved' },
        { label: 'Closed Won', value: 'Closed Won' },
        { label: 'Closed Lost', value: 'Closed Lost' }
    ];

    connectedCallback() {
        window.addEventListener("refresh", this.refresh);
    }

    disconnectedCallback() {
        window.removeEventListener("refresh", this.refresh);
    }

    refresh() {
        if (this.wiredOpportunitiesResult) {
            return refreshApex(this.wiredOpportunitiesResult)
                .then(() => console.log("Atualizado"))
                .catch((error) => console.error("Erro ao atualizar: ", error));
        }
    }

    @wire(getOpportunities)
    wireData(result) {
        this.wiredOpportunitiesResult = result;
        const { error, data } = result;

        if (data) {
            this.allData = data.map(opp => ({
                ...opp,
                Products__r: opp.Products__r || []
            }));
            this.applyFilters();
        } else if (error) {
            console.error("Error fetching opportunities: ", error);
        }
    }

    handleSearchName(event) {
        this.searchName = event.target.value.toLowerCase();
        this.applyFilters();
    }

    handleStartDate(event) {
        this.startDate = event.target.value;
        this.applyFilters();
    }

    handleEndDate(event) {
        this.endDate = event.target.value;
        this.applyFilters();
    }

    handleSearchStage(event) {
        this.searchStage = event.target.value;
        this.applyFilters();
    }

    applyFilters() {
        this.filteredData = this.allData.filter(opp => {
            let matchesName = this.searchName ? opp.Name.toLowerCase().includes(this.searchName) : true;
            let matchesStartDate = this.startDate ? new Date(opp.CloseDate) >= new Date(this.startDate) : true;
            let matchesEndDate = this.endDate ? new Date(opp.CloseDate) <= new Date(this.endDate) : true;
            let matchesStage = this.searchStage ? opp.StageName === this.searchStage : true;

            return matchesName && matchesStartDate && matchesEndDate && matchesStage;
        });
    }

    onClick() {
      this.showChild = true;
      this.dispatchEvent
        (new CustomEvent("productmanager", {
          detail: { showChild: this.showChild },
          bubbles: true, 
          composed: true }));
    }
}