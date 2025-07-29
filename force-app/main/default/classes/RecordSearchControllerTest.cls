@isTest
private class RecordSearchControllerTest {
    @isTest
    static void testSearchFlats() {
        // Test data setup
        Product2 testProduct = new Product2(
            Name = 'Test Flat',
            Location__c = 'Hyderabad',
            Facing__c = 'EAST', // Ensure this value is valid for the Face__c picklist field
            Status__c = '10-Blocked for Sale',
            Project__c = 'Ramky One Astra',
            Type__c = '3 BHK',
            Towers__c = 'A'
            // Add other required fields as needed
        );
        insert testProduct;

        // Call the method under test
        List<RecordSearchController.FlatsDetailWrapper> result = RecordSearchController.searchFlats(
            'Hyderabad', 'Ramky One Astra', 'A', 'EAST', '3 BHK', '10-Blocked for Sale'
        );

        // Assert that the result is not null
        System.assertNotEquals(null, result);
        
        // Assert that the result contains at least one element
        System.assertNotEquals(0, result.size());

        // Assert that the wrapper object properties are correctly populated
        RecordSearchController.FlatsDetailWrapper wrapper = result[0];
        System.assertEquals('Test Flat', wrapper.flat.Name);
        // Add assertions for other properties as needed
    }
}