import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class TwoPathComponent extends LightningElement {
    // Public properties
    @api lookupApiName; // JSON string containing field and parent information
    @api fieldApiName;
    @api recordId;
    @api fieldApiName2;
    @api objectApiName;
    @api recordType;
    @api hideUpdateButton = false; // Boolean to hide/show the update button, default is false (show button)

    // Private properties
    fieldAndParent; // Object to store parsed lookupApiName
    fields = []; // Array to store fields to be fetched
    parentIdValue;

    // Lifecycle hook: called after the component is inserted into the DOM
    connectedCallback() {
        try {
            // Parse the lookupApiName and set up fields to be fetched
            this.getSelectionFromConfigurator();
        } catch (error) {
            
            console.error('Error parsing lookupApiName:', error);
        }
    }

    // Wire service to fetch the record data
    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    getParentRecord({ error, data }) {
        if (data) {
            // If data is successfully fetched, set the parentIdValue
            this.parentIdValue = data.fields[this.fieldAndParent.fieldName].value;
        } else if (error) {
            
            console.error(error);
        }
    }

    // Method to parse the lookupApiName and set up fields to be fetched
    getSelectionFromConfigurator() {
        if (this.lookupApiName) {
            // Parse the JSON string into an object
            this.fieldAndParent = JSON.parse(this.lookupApiName);
            // Set the fields array to fetch the specified field from the parent object
            this.fields = [`${this.fieldAndParent.parentName}.${this.fieldAndParent.fieldName}`];
        }
    }

    // Getter to determine if the component is on an App Page
    get isAppPage() {
        return location.pathname.startsWith('/lightning/n/');
    }

    // Getter to determine if the component is on a Record Page
    get isRecordPage() {
        return location.pathname.startsWith('/lightning/r/');
    }

    // Getter to determine if the component is on the Home Page
    get isHomePage() {
        return location.pathname.startsWith('/lightning/page/home');
    }
}