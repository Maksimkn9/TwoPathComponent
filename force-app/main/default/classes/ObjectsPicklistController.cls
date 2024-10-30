global with sharing class ObjectsPicklistController extends VisualEditor.DynamicPickList {
    
    // Returns the default value for the picklist
    global override VisualEditor.DataRow getDefaultValue() {
        return new VisualEditor.DataRow('', 'Select a Field');
    }

    // Returns the list of available objects for the picklist
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows dynamicPicklistValues = new VisualEditor.DynamicPickListRows();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

        for (Schema.SObjectType objType : globalDescribe.values()) {
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

            if (objDescribe.isAccessible()) {
                dynamicPicklistValues.addRow(createDataRow(objDescribe));
            }
        }

        return dynamicPicklistValues;
    }

    // Helper method to create a DataRow for the picklist
    private VisualEditor.DataRow createDataRow(Schema.DescribeSObjectResult objDescribe) {
        return new VisualEditor.DataRow(objDescribe.getName(), objDescribe.getLabel());
    }
}