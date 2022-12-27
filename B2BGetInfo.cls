public with sharing class B2BGetInfo {

  @AuraEnabled(cacheable=true)

  public static ConnectApi.ProductDetail getProduct(

    String communityId,

    String productId,

    String effectiveAccountId

  ) {

    // Lookup the webstore ID associated with the community

    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);



    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods

    return ConnectApi.CommerceCatalog.getProduct(

      webstoreId,

      productId,

      effectiveAccountID,

      null,

      false,

      null,

      false,

      true,

      false

    );

  }

  @AuraEnabled(cacheable=true)

  public static Boolean checkProductIsInStock(String productId) {

    /*

     * The following is an example of calling an external API.

     * The example API provided is extremely simple: It takes in a product id

     * and returns a true or false value for inStock based on whether the 15th char is odd or even.

     *

     * To access this endpoint on your org, go to Remote Site Settings in Setup as an admin user

     * click "New Remote Site" and provide "https://inventorymanagerdemo.herokuapp.com" for the "Remote Site URL" field

     */

    try{

      Http http = new Http();

      HttpRequest request = new HttpRequest();

      String endpoint = Url.getOrgDomainUrl().toExternalForm() +'/services/apexrest/B2B_Inventory__c/' + productId;

      request.setEndpoint(endpoint);

      request.setMethod('GET');

      request.setHeader('Authorization', 'Bearer '+UserInfo.getSessionID());

      request.setHeader('Content-Type', 'application/json');

     

      HttpResponse response = http.send(request);

      // If the request is successful, parse the JSON response.

      //decimal stck =2.0;

      if (response.getStatusCode() == 200) {

        // Deserialize the JSON string into collections of primitive data types.

        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(

          response.getBody()

        );

        //return (Boolean)results.get('Available_For_Purchase__c');

        String cval = String.ValueOf(results.get('status__c'));

        if(cval == 'InStock'){

          return true;

        }

        else{

          return false;

        }

      }

      else{

        return false;

      }



    }

    catch(Exception e){

      throw new AuraHandledException('there is no Associated Inventory for this Product' + e.getMessage());

    }

  }


  @AuraEnabled

  public static ConnectApi.CartSummary getCartSummary(

    String communityId,

    String effectiveAccountId

  ) {

    // Lookup the webstore ID associated with the community

    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);



    //'current' is available in version 50.0 and later and indicates a cart with a status that isn’t Closed or PendingDelete

    //This is important for the product detail page since we are using the cart summary to check if the status is "Processing" or "Checkout"

    String activeCartOrId = 'current';



    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm

    return ConnectApi.CommerceCart.getCartSummary(

      webstoreId,

      effectiveAccountId,

      activeCartOrId

    );

  }



  @AuraEnabled

  public static ConnectApi.CartItem addToCart(

    String communityId,

    String productId,

    String quantity,

    String effectiveAccountId

  ) {

    // Lookup the webstore ID associated with the community

    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);



    ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();

    cartInput.productId = productId;

    cartInput.quantity = quantity;

    cartInput.type = ConnectApi.CartItemType.PRODUCT;



    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods

    return ConnectApi.CommerceCart.addItemToCart(

      webstoreId,

      effectiveAccountId,

      'active',

      cartInput

    );

  }



  @AuraEnabled

  public static ConnectApi.Wishlist createAndAddToList(

    String communityId,

    String productId,

    String wishlistName,

    String effectiveAccountId

  ) {

    // Lookup the webstore ID associated with the community

    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);



    // Store the product in a WishlistItemInput to pass to the Wishlist

    ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();

    wishlistItemInput.productId = productId;



    //Create a wishlistInput to be created

    ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();

    wishlistInput.name = wishlistName;

    wishlistInput.products = new List<ConnectApi.WishlistItemInput>{

      wishlistItemInput

    };



    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_static_methods

    return ConnectApi.CommerceWishlist.createWishlist(

      webstoreId,

      effectiveAccountId,

      wishlistInput

    );

  }



  @AuraEnabled(cacheable=true)

  public static ConnectApi.ProductPrice getProductPrice(

    String communityId,

    String productId,

    String effectiveAccountId

  ) {

    // Lookup the webstore ID associated with the community

    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);



    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods

    return ConnectApi.CommerceStorePricing.getProductPrice(

      webstoreId,

      productId,

      effectiveAccountId

    );

  }



  // when user click on 'notify when available' case will be created for that user

  @AuraEnabled

    public static Case insertCase(String descr, String userId){

         User cname = [SELECT Id, ContactId from User WHERE Id=:userId];

         Contact Cntname  = [SELECT Id, AccountId, Name from Contact WHERE Id=:cname.ContactId];

        Case cs = new Case();

        try {

            cs.Description = descr;

            //cs.OwnerId = '00GDS00000B43Fk2AJ';

            cs.ContactId = Cntname.Id;

            cs.AccountId = Cntname.AccountId;

            insert cs;

            return cs;

           

        } catch (Exception e) {

            throw new AuraHandledException(e.getMessage());

        }

    }


    @AuraEnabled(cacheable=true)
     public static Void reservedInventory(String sku, Decimal reservedQuantity, String productId)
    {
     system.debug(productId);
     Map<String, Object> getdatamp = getInventoryData(productId);
    Decimal oldReservedQty = (Decimal)getdatamp.get('Reserved__c');
    if(oldReservedQty!=null)
    {
    reservedQuantity += oldReservedQty;
    }
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/B2B_Inventory__c/'+sku);
    request.setBody('{"Reserved__c":'+reservedQuantity+'}');
    request.setMethod('PATCH');
    request.setHeader('Authorization','Bearer '+UserInfo.getSessionId());
    request.setHeader('Content-Type', 'application/json');
    HttpResponse response = http.send(request);
    System.debug(response);
    }
    
    

  //query for the available qty from b2b Inventory

  @AuraEnabled(cacheable=true)

  public static Map<String,Object> getInventoryData(String productId){

    try {

      system.debug('sovinay'+ productId);
      Http http = new Http();

      HttpRequest request = new HttpRequest();

      String endpoint = Url.getOrgDomainUrl().toExternalForm() +'/services/apexrest/B2B_Inventory__c/' + productId;

      request.setEndpoint(endpoint);

      request.setMethod('GET');

      request.setHeader('Authorization', 'Bearer '+UserInfo.getSessionID());

      request.setHeader('Content-Type', 'application/json');

     

      HttpResponse response = http.send(request);

      // If the request is successful, parse the JSON response.

      //decimal stck =2.0;

      Map<String, Object> results = new Map<String, Object>();

      if (response.getStatusCode() == 200) {

        // Deserialize the JSON string into collections of primitive data types.

        results = (Map<String, Object>) JSON.deserializeUntyped(

          response.getBody()

        );

        return results;

      }

      return results;

    } catch (Exception e) {

      throw new AuraHandledException(e.getMessage());

    }

  }

  @AuraEnabled

  public static Case Notifycase(String descr, String userId){

       User cname = [SELECT Id, ContactId from User WHERE Id=:userId];

       Contact Cntname  = [SELECT Id, AccountId, Name from Contact WHERE Id=:cname.ContactId];

      Case cs = new Case();

      try {

          cs.Description = descr;

          //cs.OwnerId = '00GDS00000B43Fk2AJ';

          cs.ContactId = Cntname.Id;

          cs.AccountId = Cntname.AccountId;

          insert cs;

          return cs;

         

      } catch (Exception e) {

          throw new AuraHandledException(e.getMessage());

      }

  }

@AuraEnabled
public static void orderedproducts(String ordersummaryId){
List<OrderItemSummary> orderItems = [SELECT Id, OrderSummaryId, Quantity, StockKeepingUnit, Product2Id FROM OrderItemSummary WHERE OrderSummaryId =:orderSummaryId];
  for(OrderItemSummary odis : orderItems)
{
 String sku = odis.StockKeepingUnit;
 if(sku!=null)
{
 Decimal newCommittedQuantity;
String productId = odis.Product2Id;
Map<String, Object> resultData = B2BGetInfo.getInventoryData(productId);
 Decimal oldCommittedQuantity = (Decimal)resultData.get('Committed__c');
 if(oldCommittedQuantity!=null)
 {
 newCommittedQuantity = oldCommittedQuantity + odis.Quantity;
}
 else {
   newCommittedQuantity = odis.Quantity;
}
 Decimal oldReservedQuantity = (Decimal)resultData.get('Reserved__c');
Decimal newReservedQuantity = oldReservedQuantity - odis.Quantity;
 Http http = new Http();
HttpRequest request = new HttpRequest();
request.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/B2B_Inventory__c/'+sku);
 request.setBody('{"Reserved__c":'+newReservedQuantity+',"Committed__c":'+newCommittedQuantity+'}');
 request.setMethod('PATCH');
request.setHeader('Authorization','Bearer '+UserInfo.getSessionId());
 request.setHeader('Content-Type', 'application/json');
 HttpResponse response = http.send(request);
 }

}
}
}