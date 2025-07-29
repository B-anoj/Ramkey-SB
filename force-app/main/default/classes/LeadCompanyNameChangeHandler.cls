public class LeadCompanyNameChangeHandler {
    
    public static void updateLead(List<Lead> leadList) {
        for(Lead led: leadList) {           
            if(led.FirstName != null && led.LastName != null) {     
                led.Company = led.FirstName + ' ' + led.LastName;
            } else if(led.FirstName == null && led.LastName != null) {
                led.Company = led.LastName;
            }           
        } 
    }
}