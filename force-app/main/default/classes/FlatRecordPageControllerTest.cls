@isTest
private class FlatRecordPageControllerTest {
    
    @isTest
    static void testFlatRecordPageController() {
        // Create a Product2 record for testing
        Product2 testProduct = new Product2(
            Name = 'Test Product'
            // Populate other required fields as needed
        );
        insert testProduct;

        // Set the recordId parameter
        ApexPages.currentPage().getParameters().put('recordIds', testProduct.Id);

        // Instantiate the controller
        FlatRecordPageController controller = new FlatRecordPageController();

        // Verify that the controller is instantiated
        System.assertNotEquals(null, controller);

        // Verify that the 'comm' property is populated with the expected Product2 record
        System.assertNotEquals(null, controller.comm);
        System.assertEquals(testProduct.Id, controller.comm.Id);
    }
}