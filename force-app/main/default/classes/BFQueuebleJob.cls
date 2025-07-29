public class BFQueuebleJob implements Queueable, Database.AllowsCallouts{

    private List<Booking_Form__c> lstBF;
     Private Map<ID,list<ID>> BFMap = new Map<ID,list<ID>>();
    public BFQueuebleJob(List<Booking_Form__c> lsacc){
        this.lstBF = lsacc;
    }
    
    public void execute(QueueableContext context) {
        if(!lstBF.isEmpty()){
            for(Booking_Form__c BFIs:lstBF){
                string jsonString2 = JSON.serializePretty(BFIs);
            	BookingFormCreationEmailHandler.CreatePDF(jsonString2);
            }
        }
         
    }
    
    
}