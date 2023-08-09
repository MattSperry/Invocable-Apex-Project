@isTest
public class LeadConversionHelperTest {
    @TestSetup
    static void makeData(){
        // Create test leads
        List<Lead> testLeads = new List<Lead>();

        Lead testLead1 = new Lead(
            LastName = 'Test1',
            Company = 'TestCompany',
            Convert__c = false
        );
        testLeads.add(testLead1);

        Lead testLead2 = new Lead(
            LastName = 'Test2',
            Company = 'TestCompany',
            Convert__c = true
        );
        testLeads.add(testLead2);

        insert testLeads;
    }
    @isTest static void testLeadConversion(){
        // Get test leads
        List<Lead> testLeads = [SELECT LastName, Company, Convert__c FROM Lead];

        Test.startTest();
        testLeads[0].Convert__c = true;
        update testLeads;
        Test.stopTest();

        // Query contacts generated
        List<Contact> newContacts = [SELECT Name FROM Contact WHERE Account.Name = 'TestCompany'];

        System.assertEquals(2, newContacts.size(), 'Should have 2 contacts matching the 2 leads');        
    }
}