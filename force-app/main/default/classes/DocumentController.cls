public without sharing class DocumentController {

    public class DocumentWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String documentType;
        @AuraEnabled public String documentLink;
        @AuraEnabled public String salesDocument;
    }

    public class ProjectWrapper {
        @AuraEnabled public String projectName;
        @AuraEnabled public List<DocumentWrapper> documents;
        @AuraEnabled public List<DocumentWrapper> propertyDocuments; // NEW
    }

    @AuraEnabled(cacheable=true)
    public static List<ProjectWrapper> getProjectNamesWithDocuments() {
        String userEmail = 'dhayalan2531@gmail.com';
        List<ProjectWrapper> result = new List<ProjectWrapper>();

        if (String.isBlank(userEmail)) return result;

        // Get Contact
        Contact con;
        try {
            con = [SELECT Id, AccountId FROM Contact WHERE Email = :userEmail LIMIT 1];
        } catch (Exception e) {
            return result;
        }
        if (con == null || con.AccountId == null) return result;

        // Get Opportunities
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE AccountId = :con.AccountId];
        if (opps.isEmpty()) return result;

        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : opps) oppIds.add(opp.Id);

        // Get Booking Forms
        List<Booking_Form__c> bookings = [
            SELECT Id, Project_Name__c 
            FROM Booking_Form__c 
            WHERE Opportunity__c IN :oppIds
        ];

        Map<Id, String> bookingIdToProject = new Map<Id, String>();
        Set<String> allProjects = new Set<String>();

        for (Booking_Form__c b : bookings) {
            if (String.isNotBlank(b.Project_Name__c)) {
                bookingIdToProject.put(b.Id, b.Project_Name__c);
                allProjects.add(b.Project_Name__c);
            }
        }

        // Get personal documents
        List<Document__c> docs = [
            SELECT Name, Document_Type__c, Document_Link__c, Sales_Document__c, Booking_Form__c 
            FROM Document__c 
            WHERE Booking_Form__c IN :bookingIdToProject.keySet()
        ];

        // Get property documents
        List<Document__c> propDocs = [
            SELECT Name, Document_Type__c, Document_Link__c, Project__c, Is_Property_Document__c 
            FROM Document__c 
            WHERE Is_Property_Document__c = TRUE AND Project__c != null
        ];

        // Group personal documents by project
        Map<String, List<DocumentWrapper>> projectToDocs = new Map<String, List<DocumentWrapper>>();
        for (Document__c doc : docs) {
            String projName = bookingIdToProject.get(doc.Booking_Form__c);
            if (String.isBlank(projName)) continue;

            if (!projectToDocs.containsKey(projName)) {
                projectToDocs.put(projName, new List<DocumentWrapper>());
            }

            DocumentWrapper d = new DocumentWrapper();
            d.name = doc.Name;
            d.documentType = doc.Document_Type__c;
            d.documentLink = doc.Document_Link__c;
            d.salesDocument = doc.Sales_Document__c;

            projectToDocs.get(projName).add(d);
        }

        // Group property documents by project
        Map<String, List<DocumentWrapper>> projectToPropertyDocs = new Map<String, List<DocumentWrapper>>();
        for (Document__c pd : propDocs) {
            String projName = pd.Project__c;
            if (String.isBlank(projName)) continue;

            if (!projectToPropertyDocs.containsKey(projName)) {
                projectToPropertyDocs.put(projName, new List<DocumentWrapper>());
            }

            DocumentWrapper pdWrap = new DocumentWrapper();
            pdWrap.name = pd.Name;
            pdWrap.documentType = pd.Document_Type__c;
            pdWrap.documentLink = pd.Document_Link__c;
            pdWrap.salesDocument = null;

            projectToPropertyDocs.get(projName).add(pdWrap);
        }

        // Final list assembly
        for (String proj : allProjects) {
            ProjectWrapper pw = new ProjectWrapper();
            pw.projectName = proj;
            pw.documents = projectToDocs.containsKey(proj) ? projectToDocs.get(proj) : new List<DocumentWrapper>();
            pw.propertyDocuments = projectToPropertyDocs.containsKey(proj) ? projectToPropertyDocs.get(proj) : new List<DocumentWrapper>();
            result.add(pw);
        }

        return result;
    }
}