public class AccountTriggerHandler {
    public static void populateUniqueId(List<Account> accountsList){
        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc : accountsList) {
            String uId;
            Account tempAcc = new Account();

            uId = acc.Id + '_' + EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(String.valueOf(Crypto.getRandomInteger())))).substring(12, 27);
            tempAcc.Id = acc.Id;
            tempAcc.Unique_Id__c = uId;
            accountsToUpdate.add(tempAcc);
        }
        update accountsToUpdate;
    }
   
    public static void profileUpdated(List<Account> accountsList, Map<Id, Account> oldMap){
         List<Id> accountIdsToProcess = new List<Id>();
    
    	for (Account acc : accountsList) {
            if (acc.Profile_Completed__c == true && oldMap.get(acc.Id).Profile_Completed__c == false) {
                accountIdsToProcess.add(acc.Id);
            }
    	}
        if(!accountIdsToProcess.isEmpty()){
            System.enqueueJob(new ProfileCompletionQueueable(accountIdsToProcess));
        }
    }
}