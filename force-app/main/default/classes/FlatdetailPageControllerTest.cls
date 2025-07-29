@isTest
private class FlatdetailPageControllerTest {

    @isTest
    static void testFlatdetailPageController() {
        // Create test data
        Product2 product = new Product2(
            Name = 'Test Product'
            // Populate other required fields as needed
        );
        insert product;

        // Set up parameters
        ApexPages.currentPage().getParameters().put('recordIds', product.Id);

        // Instantiate the controller
        FlatdetailPageController controller = new FlatdetailPageController();

        // Test that searchResults is not null
        System.assertNotEquals(null, controller.searchResults);

        // Test other aspects of the controller behavior as needed
    }
}