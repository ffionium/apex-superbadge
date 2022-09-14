/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-02-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class MaintenanceRequestHelperTest {
    
    // THIS IS MISSING A REQUIRED LOOKUP FIELD SOMEHWERE
    
    @isTest static void MaintenanceRequestTest() {
        // Test data setup
        Vehicle__c vehic = new Vehicle__c();
        Insert vehic;
        
        Product2 equip = new Product2();
        equip.Name = 'testEquipment';
        equip.Cost__c = 100;
        equip.Maintenance_Cycle__c = 15;
        equip.Replacement_Part__c = TRUE;
        insert equip;
               
        Case c = new Case(
            Status = 'New',
            Origin = 'Email',
            Type = 'Repair',
            Subject = 'Test Case',
            Vehicle__c = vehic.Id,
            ProductId = equip.Id
            
        );
        insert c;

        Equipment_Maintenance_Item__c maintItem = new Equipment_Maintenance_Item__c();
        maintItem.Equipment__c = equip.id;
        maintItem.Quantity__c = 10;
        maintItem.Maintenance_Request__c = c.id;
        insert maintItem;
        
        c.status = 'Closed';
        update c;
        
        // verify
        List<Case> caseList = [SELECT id FROM Case];
        system.assertEquals(2,caseList.size());
        
    }
}