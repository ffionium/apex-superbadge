/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-13-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class MaintenanceRequestHelper {

    public static void updateWorkOrders(List<Case> casesToProcess) {
        
        system.debug(casesToProcess);
    
        // Parent to child query to get Maint_request data. Do I need this bit?
        List<Case> casesWithData = [SELECT id, Type, Vehicle__c, ProductId, (SELECT id, Equipment__c, Maintenance_Request__c, Quantity__c FROM Equipment_Maintenance_Items__r) FROM Case WHERE id IN: casesToProcess];
    
        // List of string IDs to help with query below
        List<String> idStrings = new List<String>();
        For(Case c : casesToProcess){
            if(c.Type == 'Repair' || c.Type == 'Routine Maintenance'){
                if(c.Status == 'Closed'){
                    String s = String.valueOf(c.id);
                    idStrings.add(s);
                }
            }
        }
        
        // List of MI items related to the cases being processed. Use to create clones and query child to parent Equipment__c for maintenance cycle. Should copy 
        // exact number of records related to each maintenance request.
        List<Equipment_Maintenance_Item__c> equipItems = [SELECT id, Equipment__c, Equipment__r.Maintenance_Cycle__c, Maintenance_Request__c, Quantity__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN: idStrings];
                 
        // lists to contain new records
        List<Case> new_cases = New List<Case>();
        List<Equipment_Maintenance_Item__c> newMaintItems = new List<Equipment_Maintenance_Item__c>();
    
        // create new case for each one to be processed
        For(Case cs : casesWithData){
    
            // Integer MaintCycleDays = cs.ProductId.Maintenance_Cycle__c.IntValue();
    
            Case new_case = new Case(
                Type = 'Routine Maintenance',
                Status = 'New',
                Origin = 'Email',
                Subject = 'Routine Maintenance Request',
                Date_Reported__c = system.today(),
                Vehicle__c = cs.Vehicle__c,
                ParentId = cs.Id
                // Date_Due__c = system.today()+MaintCycleDays
                // Convert decimal to Integer
                
                //Maintenance request due date: calculated using maintenance cycle as defined on equipment records. 
                //If multiple involved, use the shortest date.
                //Date_Due__c = caseClosed + MaintCycleDays
                // convert DateTime to Date type
                // Date caseClosed = cs.ClosedDate.Date(); 
            );
    
            new_cases.add(new_case);
            
        } 
        
        insert new_cases;
    
        // create new maint items
        For(Equipment_Maintenance_Item__c MI : equipItems){
            Equipment_Maintenance_Item__c newMI = new Equipment_Maintenance_Item__c();
            newMI.Equipment__c = MI.Equipment__c;
            newMI.Quantity__c = MI.Quantity__c;
            newMI.Maintenance_Request__c = MI.Maintenance_Request__c;
            newMaintItems.add(newMI);
        }   
        
        
        // update maint items to pair them with the right case
        For(Case c : new_cases){
            For(Equipment_Maintenance_Item__c MI : newMaintItems){
                If(c.parentId == MI.Maintenance_Request__c){
                    MI.Maintenance_Request__c = c.id;
                    }
                }	        
        }
        insert newMaintItems;
    
        // query for lowest Maintenance_Cycle__c. Child to parent from Equipment_Maintenance_Item__c to Product2, where
        // Equipment_Maintenance_Item__c.maintenance_request__c in new_cases
        // AggregateResult[] shortestCycle = [SELECT id, Maintenance_Request__c, (SELECT id, MIN(Maintenance_Cycle__c) FROM Product2) FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :new_cases];
    
        For(Case c : new_cases){
            // Integer MaintCycleDays = c.ProductId.Maintenance_Cycle__c.IntValue();
        }
    }
    }