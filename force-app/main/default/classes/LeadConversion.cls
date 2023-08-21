public without sharing class LeadConversion {
  @InvocableMethod(
    label='Convert Leads'
    description='Converts leads allowing dynamic assignment of Contacts, Accoutns, and Opportunities'
  )
  public static void convertLeads(List<LeadConversionRequest> requests) {
    // Get leads to convert
    Set<ID> leadIds = new Set<ID>();
    for (LeadConversionRequest lcr : requests) {
      leadIds.add(lcr.leadId);
    }

    List<Lead> leadsToConvert = [
      SELECT Id, IsConverted
      FROM Lead
      WHERE Id IN :leadIds AND IsConverted = FALSE
    ];

    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];

    // Create list to store lead conversion requests
    List<Database.LeadConvert> leadConvertList = new List<Database.LeadConvert>();

    // Process lead conversion from input
    for (LeadConversionRequest lcr : requests) {
      Database.LeadConvert lc = new Database.LeadConvert();
      lc.setLeadId(lcr.leadId);
      lc.setConvertedStatus(convertStatus.MasterLabel);
      lc.setDoNotCreateOpportunity(lcr.noOpportunityCreation);
      System.debug('Do Not Create Opportunity value: ' + lc.isDoNotCreateOpportunity());
      if (lcr.accountId != null) {
        lc.setAccountId(lcr.accountId);
      }
      if (lcr.opportunityName != null && lcr.noOpportunityCreation == false) {
        lc.setOpportunityName(lcr.opportunityName);
      }
      if (lcr.contactId != null) {
        lc.setContactId(lcr.contactId);
      }
      leadConvertList.add(lc);
    }
    //Perform lead conversion
    List<Database.LeadConvertResult> convertResults = new List<Database.LeadConvertResult>();
    if (!leadConvertList.isEmpty()) {
      convertResults = Database.convertLead(leadConvertList);
    }
    // Debuging
    for (Database.LeadConvertResult lcr : convertResults) {
      if (lcr.isSuccess()) {
        System.debug('Account Id :' + lcr.getAccountId());
        System.debug('Contact Id :' + lcr.getContactId());
        System.debug('Opportunity Id :' + lcr.getOpportunityId());
      } else {
        System.debug('Lead Conversion failed :' + lcr.getErrors());
      }
    }
  }

  public class LeadConversionRequest {
    @InvocableVariable(label='Lead Id' required=true)
    public Id leadId;

    @InvocableVariable(label='Account Id')
    public Id accountId;

    @InvocableVariable(label='Contact Id')
    public Id contactId;

    @InvocableVariable(label='Opportunity Name')
    public String opportunityName;

    @InvocableVariable(label='No Opportunity Creation')
    public Boolean noOpportunityCreation = false;
  }
}
