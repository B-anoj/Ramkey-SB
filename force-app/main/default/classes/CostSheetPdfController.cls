public class CostSheetPdfController {
    public List<Cost_Sheet__c> costSheets { get; set; }
    public List<Cost_Sheet_Line_Items__c> csli { get; set; }
    public Id costSheetId { get; set; }
    
    public CostSheetPdfController(ApexPages.StandardController stdController) {
        costSheetId = stdController.getId();
        // Query Cost Sheet records including Opportunity__c field
        costSheets = [SELECT Id, Basic_Price__c, Cost_Sheet_Name__c, Car_Parking__c, Charges_for_Corner__c, 
                      Charges_for_Facing__c, Charges_for_Floor_Rise__c, Charges_for_View__c, Clubhouse_Charges__c, 
                      Corpus_Fund__c, Cost_of_the_Unit__c, CreatedDate, Electrical_Water_Charges__c, 
                      EV_Car_Charging_Point__c, Facing__c, Floor__c, GRAND_TOTAL__c, GST_5__c, 
                      Infrastructure_charges__c, Legal_and_Doc_Charges_GST_18__c, Maintenance_for_2Years_Rs_4_Per_Sq_ft__c, 
                      Name, No_Of_Parking__c, Note_1__c, Note_2__c, Note_3__c, Opportunity__c, OwnerId, 
                      Payement_Schedule_Type__c, PLC_Charges__c, Product__c, Project__c, Rate_Sq_Ft__c, 
                      S_No__c, Salable_Area_in_Sq_Ft__c, Second_Car_Parking__c, TOTAL_A__c, TOTAL_B__c, Tower__c, 
                      Type__c, Unit__c, Unit_No__c, UNIT_VALUE__c, Total_GST_Amount__c, Total_Installment_All__c, 
                      Total_Installment_Amount__c, Total_Amount__c, Total_B2__c, Grand_Total2__c, 
                      MaintananceTotalAmount__c, MaintananceAmountWithGST__c, Legal_DocumentationGstAmount__c, 
                      LegalDocumentTotalAmount__c, PLC_Charges2__c, Total_TDS_Value__c, Total_Net_Payable__c, 
                      ProdMaitananceFund__c, prodCorpusFund__c 
                      FROM Cost_Sheet__c 
                      WHERE Id=:costSheetId];

        // Query the Payment schedule records related to the Cost Sheet records
        Set<Id> costSheetIds = new Set<Id>();
        for (Cost_Sheet__c costSheetRecord : costSheets) {
            costSheetIds.add(costSheetRecord.Id);
        }
        csli = [SELECT Id, Amount__c, Amount_In_Local_Currency__c, Cost_Sheet__c, Name, Opportunity_Name__c, 
                Payment_Particulars__c, Payment_Schedule_Name__c, Payment_Schedule_Type__c, Project__c, S_No__c, 
                Sales_Office__c, Sales_Organization__c, GST__c, Total_Installment__c, GST_Amount__c, 
                Installment_Amount__c, Net_Payable__c, TDS_Amount__c 
                FROM Cost_Sheet_Line_Items__c 
                WHERE Cost_Sheet__c IN :costSheetIds ORDER BY S_No__c ASC];
    }
    
    public PageReference savePdfAsAttachment() {
        // Render the Visualforce page as a PDF
        PageReference pdfPage = Page.CostSheetPdfControllerPage;
        pdfPage.getParameters().put('id', costSheetId);
        Blob pdfBlob = pdfPage.getContentAsPDF();

        // Create a new attachment
        Attachment attachment = new Attachment();
        attachment.ParentId = costSheetId;
        attachment.Name = costSheets[0].Cost_Sheet_Name__c + '.pdf';
        attachment.Body = pdfBlob;
        attachment.ContentType = 'application/pdf';
        insert attachment;

        return null; // Stay on the same page
    }
}