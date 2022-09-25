/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-13-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger MaintenanceRequest on Case (after update, after insert) { 
    
    // define which cases would need processing by status and type. Similar to query in class - swap or reduce?
    List<Case> getCases = [SELECT id, Vehicle__c, ProductId, (SELECT id, Equipment__c, Maintenance_Request__c, Quantity__c FROM Equipment_Maintenance_Items__r) FROM Case WHERE (Type = 'Repair' OR Type = 'Routine Maintenance') AND Status = 'Closed'];
    
    // List<Id> caseIds = new List<Id>();
    // List<Case> casesToProcess = new List<Case>();

    // // single out cases that need processing from cases in trigger.new
    // For(Case c : getCases){
    //     caseIds.add(c.id);
    // }
    // For(Case c : trigger.new){
    //     if(caseIds.contains(c.id)){
    //         casesToProcess.add(c);
    //     }
    // }

	MaintenanceRequestHelper.updateWorkOrders(getCases);                

}