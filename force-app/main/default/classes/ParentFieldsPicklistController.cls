global with sharing class ParentFieldsPicklistController extends VisualEditor.DynamicPickList {
    // The context of the current page in the Lightning App Builder
    private VisualEditor.DesignTimePageContext context;

    // Constructor to initialize the context
    global ParentFieldsPicklistController(VisualEditor.DesignTimePageContext context) {
        this.context = context;
    }

    // Method to provide the default value for the picklist
    global override VisualEditor.DataRow getDefaultValue() {
        // Returns a default row with an empty value and a placeholder label
        return new VisualEditor.DataRow('', 'Select A Field');
    }

    // Method to provide the dynamic values for the picklist
    global override VisualEditor.DynamicPickListRows getValues() {
        // Initialize the collection to hold the dynamic picklist values
        VisualEditor.DynamicPickListRows dynamicPicklistValues = new VisualEditor.DynamicPickListRows();
        
        // Get the SObjectType for the current entity (e.g., Account, Contact, etc.)
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(context.entityName);

        // If the SObjectType is not found, return an empty picklist
        if (objType == null) {
            return dynamicPicklistValues;
        }

        // Get a map of all fields for the SObjectType
        Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        
        // Iterate over each field in the field map
        for (String fieldName : fieldMap.keySet()) {
            // Get the field metadata
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            // Skip fields that are not of type 'Reference' (i.e., not lookup fields)
            if (fieldDescribe.getType() != Schema.DisplayType.Reference) {
                continue;
            }

            // Iterate over the parent objects that this lookup field references
            for (Schema.SObjectType parentObjType : fieldDescribe.getReferenceTo()) {
                // Get the name of the parent object
                String parentName = parentObjType.getDescribe().getName();
                
                // Serialize the field name and parent object name into a JSON string
                String jsonString = JSON.serialize(new Map<String, String>{
                    'fieldName' => fieldDescribe.getLocalName(),
                    'parentName' => parentName
                });
                
                // Add a new row to the dynamic picklist with the field name as the label and the JSON string as the value
                dynamicPicklistValues.addRow(new VisualEditor.DataRow(fieldDescribe.getLocalName(), jsonString));
            }
        }

        // Return the collection of dynamic picklist values
        return dynamicPicklistValues;
    }
}