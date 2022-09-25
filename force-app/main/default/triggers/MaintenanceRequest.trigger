trigger MaintenanceRequest on Case (after update, after insert) { 

    if(checkRecursive.runOnce()){

	MaintenanceRequestHelper.updateWorkOrders(trigger.new);
                    
    }

}