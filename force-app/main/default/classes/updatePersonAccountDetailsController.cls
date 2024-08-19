public without sharing class updatePersonAccountDetailsController {
    public Account account { get; set; }

    public updatePersonAccountDetailsController() {
        String encodedId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));
        if (encodedId != null) {
            List<Account> accounts = [SELECT Id, Name, PersonBirthdate, Phone, t_shirt_size__c, shoe_size__c, Unique_Id__c 
                                      FROM Account 
                                      WHERE Unique_Id__c = :encodedId LIMIT 1];
            if (!accounts.isEmpty()) {
                account = accounts[0];
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account not found.'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid or missing account Identifier.'));
        }
    }

    public PageReference save() {
        if (account != null && account.Id != null) {
            try {
                Account accountToUpdate = new Account(
                Id = account.Id,
                PersonBirthdate = account.PersonBirthdate,
                Phone = account.Phone,
                t_shirt_size__c = account.t_shirt_size__c,
                shoe_size__c = account.shoe_size__c,
                Profile_Completed__c = true);
                update accountToUpdate;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Account Information updated successfully.'));
            } catch (DmlException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while updating account, Please correct data and submit again'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account is not properly initialized.'));
        }
        return null;
    }
}