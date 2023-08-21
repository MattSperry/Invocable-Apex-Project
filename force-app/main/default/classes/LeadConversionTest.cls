@IsTest
private class LeadConversionTest {
  @TestSetup
  static void makeData() {
    // Create test data for Lead Conversion Requests
    Lead l = new Lead(LastName = 'Sperry', Company = 'SOLVD', Convert__c = false);
    insert l;
    Account acc = new Account(Name = 'SOLVD');
    insert acc;
    Contact c = new Contact(FirstName = 'Matt', LastName = 'Sperry', AccountId = acc.Id);
    insert c;
  }
  @IsTest
  static void testLeadConversionWithOpp() {
    // Create Lead Conversion Request
    LeadConversion.LeadConversionRequest request = new LeadConversion.LeadConversionRequest();
    request.leadId = [SELECT Id FROM Lead WHERE LastName = 'Sperry' LIMIT 1].Id;
    request.accountId = [SELECT Id FROM Account WHERE Name = 'SOLVD' LIMIT 1].Id;
    request.contactId = [SELECT Id FROM Contact WHERE LastName = 'Sperry' LIMIT 1].Id;
    request.opportunityName = 'Test123';
    request.noOpportunityCreation = false;

    // Create a list of requests
    List<LeadConversion.LeadConversionRequest> requests = new List<LeadConversion.LeadConversionRequest>();
    requests.add(request);

    // Update lead and call the convertLeads method
    Test.startTest();
    LeadConversion.convertLeads(requests);
    Test.stopTest();

    // Query contacts and accounts generated
    List<Contact> newContacts = [SELECT Name FROM Contact WHERE Account.Name = 'SOLVD'];
    List<Account> newAccounts = [SELECT Name FROM Account WHERE Name = 'SOLVD'];
    List<Opportunity> newOpportunities = [SELECT Name FROM Opportunity WHERE Name = 'Test123'];

    System.assertEquals(1, newContacts.size(), 'Should have a contact matching the lead');
    System.assertEquals(1, newAccounts.size(), 'Should have an account associated with the contact');
    System.assertEquals(1, newOpportunities.size(), 'Opportunity should be created');
  }

  @IsTest
  static void testLeadConversionNoOpp() {
    LeadConversion.LeadConversionRequest request = new LeadConversion.LeadConversionRequest();
    request.leadId = [SELECT Id FROM Lead WHERE LastName = 'Sperry' LIMIT 1].Id;
    request.opportunityName = 'Test123';
    request.noOpportunityCreation = true;

    // Create a list of requests
    List<LeadConversion.LeadConversionRequest> requests = new List<LeadConversion.LeadConversionRequest>();
    requests.add(request);

    // Update lead and call the convertLeads method
    Test.startTest();
    LeadConversion.convertLeads(requests);
    Test.stopTest();

    // Make sure Opportunity is generated
    List<Opportunity> newOpportunities = [SELECT Name FROM Opportunity WHERE Name = 'Test123'];

    System.assertEquals(0, newOpportunities.size(), 'Opportunity should not be created');
  }
}
