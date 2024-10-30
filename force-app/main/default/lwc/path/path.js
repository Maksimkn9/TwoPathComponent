import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Path extends LightningElement {
    // Public properties that can be set from outside the component
    @api fieldApiName; 
    @api objectApiName; 
    @api recordId; 
    @api recordType; 
    @api hideUpdateButton = false; // Default to false to show the update button

    // Private properties
    recordTypeId; 
    objectInfo; 
    fieldValueList; 
    formattedFieldApiName; // Formatted field API name for picklist values

    selectedStep; // Currently selected step in the progress indicator
    currentStep; // Current step value in the record
    
    // Wire method to fetch record information
    @wire(getRecord, { recordId: '$recordId', layoutTypes: ["Full"], modes: ['View'] })
    recordInfoHandler({ data, error }) {
        if (data && data.fields[this.fieldApiName]) {
            // Set the current step and selected step from the record data
            this.currentStep = data.fields[this.fieldApiName].value;
            this.selectedStep = this.currentStep;
            // Format the field API name for picklist values
            this.formattedFieldApiName = `${data.apiName}.${this.fieldApiName}`;
            this.objectApiName = data.apiName;
            this.recordTypeId = data.recordTypeId;
        }
        if (error) {
            console.error('Error fetching record info:', error);
        }
    }

    // Wire method to fetch object information
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo;

    // Wire method to fetch picklist values
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$formattedFieldApiName' })
    picklistValuesHandler({ data, error }) {
        if (data) {
            // Map the picklist values to an array of values
            this.fieldValueList = data.values.map(step => step.value);
        }
        if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    // Event handler for step selection
    handleSelection(event) {
        this.selectedStep = event.target.label;
    }

    // Event handler for the update button click
    handleUpdate() {
        const fields = {
            Id: this.recordId,
            [this.fieldApiName]: this.selectedStep
        };
        const recordInput = { fields };

        // Check if the selected step is different from the current step
        if (this.selectedStep !== this.currentStep) {
            this.updatePicklistValue(recordInput);
        }
    }

    // Method to update the picklist value
    updatePicklistValue(recordInput) {
        updateRecord(recordInput)
            .then(() => {
                // Show success toast message
                this.showToast('Success', 'Picklist updated', 'success');
                // Update the current step to the selected step
                this.currentStep = this.selectedStep;
            })
            .catch(error => {
                // Show error toast message
                this.showToast('Error updating record', error.body.message, 'error');
            });
    }

    // Method to show a toast message
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant,
            }),
        );
    }

    // Getter method to dynamically set the heading of the card
    get heading() {
        return this.objectInfo?.data?.fields[this.fieldApiName]?.label || '';
    }
}