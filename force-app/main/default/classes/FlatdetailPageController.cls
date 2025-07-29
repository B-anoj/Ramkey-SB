public with sharing class FlatdetailPageController {

    // Remove or rename this variable
    // public String searchResults { get; set; }

    public List<Product2> searchResults { get; set; }
  
    public FlatdetailPageController() {
        String recordIdsParam = ApexPages.currentPage().getParameters().get('recordIds');

        // Parse the comma-separated IDs
        List<String> recordIds = (recordIdsParam != null) ? recordIdsParam.split(',') : new List<String>();

        // Fetch the corresponding records based on the IDs
        if (!recordIds.isEmpty()) {
            searchResults = [SELECT Id, Advance_Maintenance__c, Alt_Unit_Measurement__c, Sublocation__c, Project__c, Amenities_Charges__c, Area_in_Sqft__c, Balcony__c, Base_Value__c,
                       Boundary_East__c, Boundary_South__c, Boundary_West__c, Floor__c, Status__c, Towers__c, Boundary_North__c, Car_Parking_Charges__c, Corpus_Fund__c, CreatedById, IsActive,
                       Direction_Facing__c, DisplayUrl, Dist_Channel__c, Electrical_Water_Charges__c, EV_Charges__c, ExternalDataSourceId, ExternalId, External_wall_area__c,
                       Facing__c, Floor_Number__c, Floor_Rise__c, Infra_Charges__c, LastModifiedById, Legal_Charges__c, Location__c, Material__c, Material_Description__c,
                       Material_No__c, Other_Charges__c, Parking_Area__c, Parking_No__c, Plant_Description__c, PLC1__c, Description_PLC1__c, PLC2__c, Description_PLC2__c,
                       PLC3__c, Description_PLC3__c, PLC4__c, Description_PLC4__c, PLC5__c, Description_PLC5__c, Pricing_Condition__c, Pricing_Sequence__c, ProductCode,
                       Description, Family, Name, StockKeepingUnit, QuantityUnitOfMeasure, Sale_Unit_Carpet_Area_in_SFT__c, Sale_Unit_Terrace_Area_in_SFT__c, Sales_Office__c,
                       Sales_Org__c, Sales_Organization__c, Square_Yards__c, Square_Yards_Price__c, Description__c, Total_Cost__c, UDS__c,
                       Undivided_share_of_Flat__c, Unit_Original_Status__c, Utility__c, Valid_from__c,Type__c,Unit__c FROM Product2 WHERE Id IN :recordIds ORDER BY Name ASC];
        } else {
            searchResults = new List<Product2>();
        }
    }
    
    
}