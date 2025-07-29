/**
* @File Name : ConstructionUpdatePercentComparator.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : July 14, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | July 14, 2025 |   | Initial Version
**/

public class ConstructionUpdatePercentComparator implements Comparator<Construction_Update__c> {
    public Integer compare(Construction_Update__c a, Construction_Update__c b) {
        if (a.Percent__c == null && b.Percent__c == null) return 0;
        if (a.Percent__c == null) return -1;
        if (b.Percent__c == null) return 1;

      return (a.Percent__c < b.Percent__c) ? -1 :
       (a.Percent__c > b.Percent__c) ? 1 : 0;

    }
}