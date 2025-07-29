public without sharing class HandoverChecklistController {

    public class HandoverLineItemWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String description;
        @AuraEnabled public String action;
        @AuraEnabled public String remarks;
        @AuraEnabled public String activity;
    }

    public class HandoverGroupWrapper {
        @AuraEnabled public String actionType; 
        @AuraEnabled public String status;
        @AuraEnabled public String totalActionItems;
        @AuraEnabled public List<HandoverLineItemWrapper> items;
    }

    public class ProjectMetadataWrapper {
        @AuraEnabled public String projectName;
        @AuraEnabled public String propertyAddress;
        @AuraEnabled public String email;
        @AuraEnabled public String crmContact;
        @AuraEnabled public String corporateAddress;
        @AuraEnabled public String contactPerson;

        @AuraEnabled public List<HandoverGroupWrapper> handoverData;
    }

    @AuraEnabled(cacheable=true)
    public static List<ProjectMetadataWrapper> getProjectMetadataForLoggedInUser() {
        String contactEmail = 'dhayalan2531@gmail.com'; // Replace with dynamic logic if needed

        // Step 1: Get Contact
        List<Contact> contacts = [
            SELECT Id, AccountId 
            FROM Contact 
            WHERE Email = :contactEmail 
            LIMIT 1
        ];

        if (contacts.isEmpty() || contacts[0].AccountId == null) {
            return new List<ProjectMetadataWrapper>();
        }

        Id accountId = contacts[0].AccountId;

        // Step 2: Get Projects from Booking_Form__c via Opportunities
        List<Opportunity> oppList = [
            SELECT Id, (SELECT Id, Project_Name__c FROM Booking_Form__r)
            FROM Opportunity
            WHERE AccountId = :accountId
        ];

        Set<String> projectNames = new Set<String>();
        for (Opportunity opp : oppList) {
            for (Booking_Form__c form : opp.Booking_Form__r) {
                if (!String.isBlank(form.Project_Name__c)) {
                    projectNames.add(form.Project_Name__c.trim());
                }
            }
        }

        if (projectNames.isEmpty()) {
            return new List<ProjectMetadataWrapper>();
        }

        // Step 3: Get Custom Metadata
        Map<String, Ramky_Projects__mdt> projectMetaMap = new Map<String, Ramky_Projects__mdt>();
        for (Ramky_Projects__mdt m : [
            SELECT MasterLabel, Property_Address__c, Email__c, CRM_Contact__c, Corporate_Address__c, Contact_Person__c, staticResourceName__c
            FROM Ramky_Projects__mdt
            WHERE MasterLabel IN :projectNames
        ]) {
            projectMetaMap.put(m.MasterLabel, m);
        }

        // Step 4: Get Handover__c Records
        List<Handover__c> handoverList = [
            SELECT Id, Projects__c, Action_Type__c, Status__c, Total_Handover_Items__c
            FROM Handover__c
            WHERE Projects__c IN :projectNames
        ];

        Map<Id, Handover__c> handoverById = new Map<Id, Handover__c>();
        Map<String, List<Handover__c>> handoversByProject = new Map<String, List<Handover__c>>();

        for (Handover__c h : handoverList) {
            handoverById.put(h.Id, h);
            if (!handoversByProject.containsKey(h.Projects__c)) {
                handoversByProject.put(h.Projects__c, new List<Handover__c>());
            }
            handoversByProject.get(h.Projects__c).add(h);
        }

        // Step 5: Get Handover Line Items
        Map<Id, List<Handover_Line_Items__c>> handoverToLineItemsMap = new Map<Id, List<Handover_Line_Items__c>>();
        if (!handoverById.isEmpty()) {
            for (Handover_Line_Items__c item : [
                SELECT Id, Description__c, Action__c, Remarks__c, Handover__c, Activity__c
                FROM Handover_Line_Items__c
                WHERE Handover__c IN :handoverById.keySet()
            ]) {
                if (!handoverToLineItemsMap.containsKey(item.Handover__c)) {
                    handoverToLineItemsMap.put(item.Handover__c, new List<Handover_Line_Items__c>());
                }
                handoverToLineItemsMap.get(item.Handover__c).add(item);
            }
        }

        // Step 6: Construct Final Result
        List<ProjectMetadataWrapper> results = new List<ProjectMetadataWrapper>();

        for (String project : projectNames) {
            Ramky_Projects__mdt meta = projectMetaMap.get(project);
            List<Handover__c> handovers = handoversByProject.get(project);

            ProjectMetadataWrapper wrapper = new ProjectMetadataWrapper();
            wrapper.projectName = project;
            wrapper.propertyAddress = meta != null ? meta.Property_Address__c : '';
            wrapper.email = meta != null ? meta.Email__c : '';
            wrapper.crmContact = meta != null ? meta.CRM_Contact__c : '';
            wrapper.corporateAddress = meta != null ? meta.Corporate_Address__c : '';
            wrapper.contactPerson = meta != null ? meta.Contact_Person__c : '';

            List<HandoverGroupWrapper> handoverGroupList = new List<HandoverGroupWrapper>();
            Map<String, HandoverGroupWrapper> apartmentTypeMap = new Map<String, HandoverGroupWrapper>();

            if (handovers != null) {
                for (Handover__c handover : handovers) {
                    if (handoverToLineItemsMap.containsKey(handover.Id)) {
                        String aptType = handover.Action_Type__c != null ? handover.Action_Type__c : 'Unknown';

                        if (!apartmentTypeMap.containsKey(aptType)) {
                            HandoverGroupWrapper groupWrapper = new HandoverGroupWrapper();
                            groupWrapper.actionType = aptType;
                            groupWrapper.status = handover.Status__c;
                            groupWrapper.items = new List<HandoverLineItemWrapper>();
                            apartmentTypeMap.put(aptType, groupWrapper);
                        }

                        for (Handover_Line_Items__c item : handoverToLineItemsMap.get(handover.Id)) {
                            HandoverLineItemWrapper line = new HandoverLineItemWrapper();
                            line.id = item.Id;
                            line.description = item.Description__c;
                            line.action = item.Action__c;
                            line.remarks = item.Remarks__c;
                            line.activity = item.Activity__c;
                            apartmentTypeMap.get(aptType).items.add(line);
                        }
                    }
                }

                for (HandoverGroupWrapper groupWrapper : apartmentTypeMap.values()) {
                    groupWrapper.totalActionItems = String.valueOf(groupWrapper.items.size());
                    handoverGroupList.add(groupWrapper);
                }
            }

            wrapper.handoverData = handoverGroupList;
            results.add(wrapper);
        }

        return results;
    }
    @AuraEnabled(cacheable=true)
public static void updateHandoverLineItems(List<HandoverLineItemWrapper> updatedItems) {
    if (updatedItems == null || updatedItems.isEmpty()) return;

    List<Handover_Line_Items__c> itemsToUpdate = new List<Handover_Line_Items__c>();

    for (HandoverLineItemWrapper wrapper : updatedItems) {
        if (String.isBlank(wrapper.id)) continue;

        Handover_Line_Items__c item = new Handover_Line_Items__c(
            Id = wrapper.id,
            Description__c = wrapper.description,
            Action__c = wrapper.action,
            Remarks__c = wrapper.remarks,
            Activity__c = wrapper.activity
        );

        itemsToUpdate.add(item);
    }

    if (!itemsToUpdate.isEmpty()) {
        try {
            update itemsToUpdate;
        } catch (Exception ex) {
            throw new AuraHandledException('Failed to update items: ' + ex.getMessage());
        }
    }
}

}