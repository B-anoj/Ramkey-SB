/*
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
Author: Pundareeka S
Created on: 03-10-2024
Modified on: 04-10-2024 - Pundareeka S
Description : To update the product status and prevent the deletion of the booking form.
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
*/
public class BookingFormRevertProductStatusHandler {

    public static void handleBeforeDelete(List<Booking_Form__c> oldRecords) {
        Set<Id> productIdsToUpdate = new Set<Id>();

        // Iterate over the deleted Booking_Form__c records
        for (Booking_Form__c booking : oldRecords) {
            // Only update related Product2 if the Booking_Form_Status__c was 'Draft Save'
            // and if the Product2__c lookup field is populated
            if (booking.Booking_Form_Status__c == 'Draft Save' && booking.Product2__c != null) {
                productIdsToUpdate.add(booking.Product2__c);
            }
        }
        
        // If there are Product2 records to update, revert their status
        if (!productIdsToUpdate.isEmpty()) {
            revertProduct2Status(productIdsToUpdate);
        }
    }

    // Helper method to revert Product2 status to '08-Available unit'
    public static void revertProduct2Status(Set<Id> productIds) {
        List<Product2> productsToUpdate = new List<Product2>();

        // Fetch the Product2 records that need to be updated
        List<Product2> relatedProducts = [
            SELECT Id, Status__c 
            FROM Product2 
            WHERE Id IN :productIds
        ];

        for (Product2 product : relatedProducts) {
            // Revert the status to '08-Available unit'
            product.Status__c = '08-Available unit';
            productsToUpdate.add(product);
        }

        // Perform the update operation only for Product2 records that need to be reverted
        if (!productsToUpdate.isEmpty()) {
            update productsToUpdate;
        }
    }
}