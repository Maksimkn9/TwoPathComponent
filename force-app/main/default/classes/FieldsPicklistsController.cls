global with sharing class FieldsPicklistsController extends VisualEditor.DynamicPickList {
    // The context of the design-time page, which includes information about the current entity (e.g., object) being edited.
    private VisualEditor.DesignTimePageContext context;

    // Constructor to initialize the context when the class is instantiated.
    global FieldsPicklistsController(VisualEditor.DesignTimePageContext context) {
        this.context = context;
    }

    // Method to provide the default value for the picklist.
    // This is the value that will be selected by default when the picklist is first displayed.
    global override VisualEditor.DataRow getDefaultValue() {
        // Return a default row with an empty value and a placeholder label.
        return new VisualEditor.DataRow('', 'Select a Field');
    }

    // Method to provide the list of values for the picklist.
    global override VisualEditor.DynamicPickListRows getValues() {
        // Initialize a new collection to hold the picklist values.
        VisualEditor.DynamicPickListRows dynamicPicklistValues = new VisualEditor.DynamicPickListRows();
        
        // Get the SObjectType (e.g., Account, Contact) based on the entity name from the context.
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(context.entityName);

        // If the object type is not found, return an empty picklist.
        if (objType == null) {
            return dynamicPicklistValues;
        }

        // Get a map of all fields for the object type.
        Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();

        // Iterate over each field in the field map.
        for (Schema.SObjectField field : fieldMap.values()) {
            // Get the field's metadata (describe result).
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            
            // Check if the field is a picklist and if it is accessible to the user.
            if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST && fieldDescribe.isAccessible()) {
                // Add the field to the picklist values with its label and API name.
                dynamicPicklistValues.addRow(new VisualEditor.DataRow(fieldDescribe.getLabel(), fieldDescribe.getName()));
            }
        }

        // Return the collection of picklist values.
        return dynamicPicklistValues;
    }
}