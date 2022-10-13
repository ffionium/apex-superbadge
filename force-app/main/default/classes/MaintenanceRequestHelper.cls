public with sharing class MaintenanceRequestHelper {

    public static void updateWorkOrders(List<Case> casesFromTrigger) {
           
        // Filter cases from trigger by status and type, and Parent to Child query to get Equipment_Maintenance_Items__c data. 
        List<Case> casesToProcess = [SELECT id, Type, Vehicle__c, ProductId, (SELECT id, Equipment__c, Maintenance_Request__c, Quantity__c FROM Equipment_Maintenance_Items__r) FROM Case WHERE id IN: casesFromTrigger AND (Type = 'Repair' OR Type = 'Routine Maintenance') AND Status = 'Closed'];
       
    
        // List of string IDs to help with query below
        List<String> idStrings = new List<String>();
        For(Case c : casesToProcess){
            String s = String.valueOf(c.id);
            idStrings.add(s);
                }
            
        
        
        // List of MI items related to the cases being processed. Use to create clones and query child to parent Equipment__c for maintenance cycle. Should copy 
        // exact number of records related to each maintenance request. Do I need this? Yes because need a list of Equipment_Maintenance_Items__r sObjects. Maybe doesn't need to be parent>child in the above?
        List<Equipment_Maintenance_Item__c> equipItems = [SELECT id, Equipment__c, Equipment__r.Maintenance_Cycle__c, Maintenance_Request__c, Quantity__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN: idStrings];
                 
        // lists to contain new records
        List<Case> new_cases = New List<Case>();
        List<Equipment_Maintenance_Item__c> newMaintItems = new List<Equipment_Maintenance_Item__c>();
    
        // create new case for each one to be processed
        For(Case cs : casesToProcess){
    
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
    
        // create new maint items. Sets parent case of new case as Maint_req
        For(Equipment_Maintenance_Item__c MI : equipItems){
            Equipment_Maintenance_Item__c newMI = new Equipment_Maintenance_Item__c();
            newMI.Equipment__c = MI.Equipment__c;
            newMI.Quantity__c = MI.Quantity__c;
            newMI.Maintenance_Request__c = MI.Maintenance_Request__c;
            newMaintItems.add(newMI);
        }   
        
        
        // update maint items to pair them with the right case via the parentID of the related case
        For(Case c : new_cases){
            For(Equipment_Maintenance_Item__c MI : newMaintItems){
                If(c.parentId == MI.Maintenance_Request__c){
                    MI.Maintenance_Request__c = c.id;
                    }
                }	        
        }
        insert newMaintItems;
    
        // map to use to query for lowest maintenance cycle for each case (which has multiple EMIs related)
        Map<Id,List<Equipment_Maintenance_Item__c>> mapOfList = new Map<Id,List<Equipment_Maintenance_Item__c>>();

        // common design pattern for Map<ID,List<SObject>> : https://redargyle.com/improving-apex-fluidity-using-streams/
        For(Equipment_Maintenance_Item__c e : newMaintItems){
            system.debug(e.maintenance_request__c);
            if(!mapOfList.containsKey(e.maintenance_request__c)){
                mapOfList.put(e.maintenance_request__c, new List<Equipment_Maintenance_Item__c>());
            }
            mapOfList.get(e.Maintenance_Request__c).add(e);
        }

        system.debug(mapOfList);

    
        For(Case c : new_cases){
            
            // Integer MaintCycleDays = c.ProductId.Maintenance_Cycle__c.IntValue();
        }
    }
}