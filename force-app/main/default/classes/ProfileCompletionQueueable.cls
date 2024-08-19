public class ProfileCompletionQueueable implements Queueable,Database.AllowsCallouts {
    
    private List<Id> accountIds;
    
    public ProfileCompletionQueueable(List<Id> accountIds) {
        this.accountIds = accountIds;
    }
    
    public void execute(QueueableContext context) {
        List<Account> accounts = [SELECT Id, PersonEmail, t_shirt_size__c, shoe_size__c, Loyalty_Customer_ID__c FROM Account WHERE Id IN :accountIds];
        
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Account acc : accounts) {
            if (acc.PersonEmail != null && acc.t_shirt_size__c != null && acc.shoe_size__c != null) {
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:commutatus');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');

                String jsonBody = JSON.serialize(new Map<String, Object>{
                    'email' => acc.PersonEmail,
                    'tshirtSize' => acc.t_shirt_size__c,
                    'shoeSize' => acc.shoe_size__c
                });
                
                req.setBody(jsonBody);
                
                Http http = new Http();
                HttpResponse res = http.send(req);
               
                if (res.getStatusCode() == 200) {
                    Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    if (responseBody.containsKey('customer_id')) {
                        String customerId = String.valueOf(responseBody.get('customer_id')) ;
                        acc.Loyalty_Customer_ID__c = customerId;
                        accountsToUpdate.add(acc);
                    }
                } else {
                    System.debug('HTTP Request failed with status code: ' + res.getStatusCode());
                    Map<String, Object> errorResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    if (errorResponse.containsKey('message')) {
                        String errorMessage = (String) errorResponse.get('message');
                        System.debug('Error message: ' + errorMessage);
                    }
                }
            }
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}