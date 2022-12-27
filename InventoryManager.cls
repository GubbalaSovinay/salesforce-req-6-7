@RestResource(urlMapping='/B2B_Inventory__c/*')
global class InventoryManager {
        @HttpGet
        global static B2B_Inventory__c getInventory(){

            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;
            String InventoryId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);                
            B2B_Inventory__c result = [SELECT Id, status__c,Available_for_Purchase__c,Reserved__c FROM B2B_Inventory__c WHERE Product_Item__c =:InventoryId];
            return result;  
        } 
        @HttpPatch
        global static B2B_Inventory__c updateInventory()
        {
            RestRequest req = RestContext.request;
            String inventoryId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            B2B_Inventory__c inventory = [SELECT Id,Reserved__c FROM B2B_Inventory__c WHERE Product_Item__r.StockKeepingUnit = :inventoryId];
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
            for(String fieldName : params.KeySet())
            {
                Inventory.put(fieldName, params.get(fieldName));
            }
            update inventory;
            return inventory;
        }

}