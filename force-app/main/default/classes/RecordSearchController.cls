public with sharing class RecordSearchController {
    private static String previousTower;
    public class FlatsDetailWrapper {
        @AuraEnabled public Product2 flat;
        @AuraEnabled public String backgroundColor;
        @AuraEnabled public String towercss;
        @AuraEnabled public String towerline;
        @AuraEnabled public String digitsAfterHyphen;
        public FlatsDetailWrapper(Product2 flat, String backgroundColor, String towercss,String towerline,String digitsAfterHyphen) {
            this.flat = flat;
            this.backgroundColor = backgroundColor;
            this.towercss = towercss;
            this.towerline = towerline;
             this.digitsAfterHyphen = digitsAfterHyphen;
        }
    }

   @AuraEnabled
    public static List<FlatsDetailWrapper> searchFlats(String apexlocation, String apexproject, String apextower, String apexfacevalue, String apextype, String apexstatus) {
        List<FlatsDetailWrapper> flatsDetail = new List<FlatsDetailWrapper>();

  // Implement logic to query flats based on the provided input parameters
    String query = 'SELECT Id, Name, Location__c, Facing__c, Status__c, Project__c,Type__c,Towers__c FROM Product2 WHERE';
    if (String.isNotBlank(apexlocation)) {
        query += ' Location__c = :apexlocation';
    }
    if (String.isNotBlank(apexproject)) {
        query += ' AND Project__c = :apexproject';
    }
        if (String.isNotBlank(apextower)) {
        query += ' AND Towers__c = :apextower';
    }
    if (String.isNotBlank(apexfacevalue)) {
        query += ' AND Facing__c = :apexfacevalue';
    }
    if (String.isNotBlank(apextype)) {
        query += ' AND Type__c = :apextype';
    }
   
    if (String.isNotBlank(apexstatus)) {
        query += ' AND Status__c = :apexstatus';
    }
    query += ' ORDER BY Towers__c ASC, Name ASC';

    List<Product2> queriedFlats = Database.query(query);
            // Create a list of wrapper objects with a background color field
            for (Product2 flat : queriedFlats) {
    String name = flat.Name;
    String digitsAfterHyphen = extractDigitsAfterHyphen(name);
    FlatsDetailWrapper wrapper = new FlatsDetailWrapper(flat, determineBackgroundColor(flat.Status__c), determinetower(flat.Towers__c), determinetowerline(flat.Towers__c), digitsAfterHyphen);
    flatsDetail.add(wrapper);
}

        
        System.debug('Return list'+flatsDetail);
        return flatsDetail;

    }

    private static String extractDigitsAfterHyphen(String name) {
    String digitsAfterHyphen = '';
    Integer hyphenIndex = name.indexOf('-');
    if (hyphenIndex != -1 && hyphenIndex + 5 <= name.length()) {
        digitsAfterHyphen = name.substring(hyphenIndex + 1, hyphenIndex + 5);
    }
    return digitsAfterHyphen;
}

    private static String determineBackgroundColor(String picklistValue) {
        // Implement your logic to determine the background color based on picklist value
        // For example, you might use a switch statement or a mapping
        if (picklistValue == '09-Sold Unit') {
            return 'sold-icon';
        }
         else if (picklistValue == '08-Available Unit') {
            return 'available-icon';
        }
         else if (picklistValue == '22-Mortgaged Land Owner') {
            return 'landowner-icon';
        } 
        else if (picklistValue == '24-Block - Management') {
            return 'lease-icon';
        } 
        else if (picklistValue == '23-Mortgaged-Developer') {
             return 'hold-icon';
        } 
        else if (picklistValue == '10-Blocked for Sale') {
            return 'blocked-icon';
       } 
        else if (picklistValue == '12-BlockedforLandowner1') {
            return 'blockedland-icon';
       } 
        else {
            return 'blocked';
        }
    }

    private static String determinetower(String towerpicklistValue) {
        // Implement your logic to determine the background color based on picklist value
        // For example, you might use a switch statement or a mapping
        if (towerpicklistValue.length()>= 2) {
            return 'line-height:1; margin-top:-4px;';
        }
        else {
            return 'margin:-13px;';
        }
    }
    private static String determinetowerline(String flatstower) {
       
        if (previousTower == null || !previousTower.equals(flatstower)) {
            previousTower = flatstower;
          return 'true'; 
        }
        else {
            return '';
        }
    }
}