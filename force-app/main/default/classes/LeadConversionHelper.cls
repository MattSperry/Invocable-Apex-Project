public without sharing class LeadConversionHelper {
    public static void convertLeads(List<Lead> leadList){
        // Get leads with the checkbox checked
        Set<Id> validLeadIds = new Set<Id>();
        for (Lead l: leadList){
            if(l.Convert__c == true){
                validLeadIds.add(l.Id);
            }
        }
        
        if (!validLeadIds.isEmpty()){
            // Get leads to convert
            List<Lead> leadsToConvert = [SELECT Id, IsConverted FROM Lead WHERE Id IN :validLeadIds];         
            
            // Filter out leads that are already converted
            List<Lead> leadsToProcess = new List<Lead>();
            for (Lead ld : leadsToConvert) {
                if (!ld.IsConverted) {
                    leadsToProcess.add(ld);
                }
            }
            // Create lead convert object
            List<Database.LeadConvert> LeadConvertList = new List<Database.LeadConvert>();
            for (Lead lead: leadsToProcess){
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(lead.Id);
                lc.setConvertedStatus('Closed - Converted');
                leadConvertList.add(lc);
            }
            // Preform lead conversion
            List<Database.LeadConvertResult> convertResults = new List<Database.LeadConvertResult>();
            if (!leadConvertList.isEmpty()){
                convertResults = Database.convertLead(leadConvertList);
            }
            // Debuging
            for (Database.LeadConvertResult lcr : convertResults){
                if(lcr.isSuccess()){
                    System.debug('Account Id :' + lcr.getAccountId());
                    System.debug('Contact Id :' + lcr.getContactId());
                    System.debug('Opportunity Id :' + lcr.getOpportunityId());
                } else {
                    System.debug('Lead Conversion failed :' + lcr.getErrors());
                }
            }
        }
    }
}