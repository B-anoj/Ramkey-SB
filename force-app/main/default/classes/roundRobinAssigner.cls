public without sharing class roundRobinAssigner {

    @InvocableMethod(label='Assign objects')
    public static void assign(List<RoundRobinAssignment> rras) {
        
        // What was the last user index?
        List<RoundRobin__c> RRSettings = [SELECT Id, GroupName__c, FieldName__c, Object__c, IndexOfLastUsed__c FROM RoundRobin__c];
        
        Map<String, List<GroupMember>> usersByGroup = new Map<String, List<GroupMember>>();
        List<SObject> objectList = new List<SObject>();
        Set<String> phoneNumbers = new Set<String>();
          Set<id> leadId = new Set<id>();
        Set<String> projectNames = new Set<String>{'Ramky One Astra', 'Ramky One Odyssey'};
            
        // Collect all phone numbers for the records to be processed
        for (RoundRobinAssignment rra : rras) {
            if (rra.objectType == 'Lead' && rra.phone != null && (rra.projectName == 'Ramky One Astra' || rra.projectName == 'Ramky One Odyssey')) {
                phoneNumbers.add(rra.phone);
                leadId.add(rra.recordId);
            }
        }

        // Query existing leads with matching phone numbers
        Map<String, Lead> existingLeadsByPhone = new Map<String, Lead>();
        if (!phoneNumbers.isEmpty()) {
            for (Lead lead : [SELECT Id, Phone,Projects__c, OwnerId FROM Lead WHERE Phone IN :phoneNumbers AND Projects__c IN:projectNames AND Id NOT IN:leadId]) {
                existingLeadsByPhone.put(lead.Phone, lead);
            }
        }

        // Process each assignment
        for (RoundRobinAssignment rra : rras) {
            if (rra.fieldName == null) {
                rra.fieldName = 'OwnerId';
            }

            List<GroupMember> groupUsers = new List<GroupMember>();
            // See if we have it already in our map
            if (usersByGroup.get(rra.groupName) == null) {
                // Fetch users who are not on leave
                groupUsers = [SELECT Group.Name, GroupId, UserOrGroupId 
                              FROM GroupMember 
                              WHERE Group.Name = :rra.groupName 
                              AND UserOrGroupId IN (SELECT Id FROM User WHERE On_leave__c = false)];
                
                // Store in the map so we don't have to query about this group again
                usersByGroup.put(rra.groupName, groupUsers);
            } else {
                groupUsers = usersByGroup.get(rra.groupName);
            }

            // Check if a lead with the same phone number and matching project name exists
            if (rra.objectType == 'Lead' && rra.phone != null && (rra.projectName == 'Ramky One Astra' || rra.projectName == 'Ramky One Odyssey') && existingLeadsByPhone.containsKey(rra.phone)) {
                // Get the existing lead
                Lead existingLead = existingLeadsByPhone.get(rra.phone);

                // Create a new lead record
                Id rId = Id.valueOf(rra.recordId); 
                SObject so = rId.getSObjectType().newSObject(rId);
                
                // Update the new lead's owner with the owner of the existing lead
                so.put(rra.fieldName, existingLead.OwnerId);
                objectList.add(so);
            } else {
                // Perform round-robin assignment
                Id rId = Id.valueOf(rra.recordId);
                String Obj = rId.getSObjectType().getDescribe().getName();
                RoundRobin__c matchingRR = recordMatcher(RRSettings, rra.fieldName, Obj, rra.groupName);

                SObject so = rId.getSObjectType().newSObject(rId);
                Integer nextIndex = getNextIndex(matchingRR, groupUsers);
                so.put(rra.fieldName, groupUsers[nextIndex].UserOrGroupId);
                
                matchingRR.IndexOfLastUsed__c = nextIndex;

                // Update or insert the custom setting
                boolean isNew = true;
                for (RoundRobin__c rr : RRSettings) {
                    if (rr.Id == matchingRR.Id) {
                        rr.IndexOfLastUsed__c = matchingRR.IndexOfLastUsed__c;
                        isNew = false;
                    }
                }
                if (isNew) {
                    RRSettings.add(matchingRR);
                }
                
                objectList.add(so);
            }
        }
        
        update objectList;
        update RRSettings;
    }

    public static Integer getNextIndex(RoundRobin__c match, List<GroupMember> groupUsers) {
        if (match.IndexOfLastUsed__c == null) {
            return 0;
        } else if (match.IndexOfLastUsed__c >= groupUsers.size() - 1) {
            return 0;
        } else {
            return Integer.valueOf(match.IndexOfLastUsed__c + 1);
        }
    }

    public static RoundRobin__c recordMatcher(List<RoundRobin__c> records, String fieldName, String obj, String groupName) {
        for (RoundRobin__c rr : records) {
            if (rr.FieldName__c == fieldName && rr.Object__c == obj && rr.GroupName__c == groupName) {
                return rr;
            }
        }

        RoundRobin__c rrNew = new RoundRobin__c();
        rrNew.FieldName__c = fieldName;
        rrNew.Object__c = obj;
        rrNew.GroupName__c = groupName;
        rrNew.Name = obj + '-' + fieldName + '-' + groupName;
        insert rrNew;
        return rrNew;
    }

    public class RoundRobinAssignment {
        @InvocableVariable(required=true label='group name')
        public String groupName;
        
        @InvocableVariable(required=true label='recordId')
        public String recordId;

        @InvocableVariable(required=true label='object type')
        public String objectType;

        @InvocableVariable(required=false label='phone')
        public String phone;

        @InvocableVariable(required=false label='project name')
        public String projectName;
        
        @InvocableVariable(required=false label='field name (default = ownerId)')
        public String fieldName;

        @InvocableVariable(required=false label='record owner Id')
        public String recordOwnerId;
    }
}