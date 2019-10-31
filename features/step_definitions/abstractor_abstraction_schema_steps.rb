When(/^I follow "([^"]*)" within the "([^"]*)" schema$/) do |link, abstraction_schema_display_name|
  abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(display_name: abstraction_schema_display_name).first
  all("#abstractor_abstraction_schema_#{abstractor_abstraction_schema.id}")[0].click_link(link)
end
