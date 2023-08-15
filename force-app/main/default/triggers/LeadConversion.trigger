trigger LeadConversion on Lead(before update, after update) {
  if (Trigger.isUpdate && Trigger.isAfter) {
    LeadConversionHelper.convertLeads(Trigger.New);
  }
}
