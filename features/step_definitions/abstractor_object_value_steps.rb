Then(/^I should see the first (\d+) "([^"]*)" abstractor object values$/) do |abstractor_object_value_count, abstraction_schema_display_name |
  abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(display_name: abstraction_schema_display_name).first
  abstractor_object_values = abstractor_abstraction_schema.abstractor_object_values.order(:value).limit(abstractor_object_value_count)
  abstractor_object_values.each do |abstractor_object_value|
    expect(all("#abstractor_object_value_#{abstractor_object_value.id}")[0].find('.abstractor_object_value_value')).to have_content(abstractor_object_value.value)
    expect(all("#abstractor_object_value_#{abstractor_object_value.id}")[0].find('.abstractor_object_value_vocabulary_code')).to have_content(abstractor_object_value.vocabulary_code)
  end
end

Then(/^I should see the following "([^"]*)" abstractor object values$/) do |abstraction_schema_display_name, table|
  table.hashes.each_with_index do |abstractor_object_value_hash, i|
    expect(all(".abstractor_object_value")[i].find('.abstractor_object_value_value')).to have_content(abstractor_object_value_hash['Value'])
    expect(all(".abstractor_object_value")[i].find('.abstractor_object_value_vocabulary_code')).to have_content(abstractor_object_value_hash['Vocabulary Code'])
  end
end

Then(/^the "([^"]*)" field should be disabled and contain the value "([^"]*)"$/) do |field_label, value|
  expect(page.has_field?(field_label, with: value, disabled: true)).to be_truthy
end

Then(/^the "([^"]*)" field should not be disabled and contain the value "([^"]*)"$/) do |field_label, value|
  expect(page.has_field?(field_label, with: value, disabled: false)).to be_truthy
end

Then(/^I should see the following variants$/) do |table|
  table.hashes.each_with_index do |abstractor_object_value_variant_hash, i|
    disabled = abstractor_object_value_variant_hash['Disabled'] == 'yes' ? true: false
    expect(all(".abstractor_object_value_variant")[i].find('.value').has_field?('Variant Value', with: abstractor_object_value_variant_hash['Variant Value'], disabled: disabled)).to be_truthy
    if  abstractor_object_value_variant_hash['Case Sensitive?'] == 'yes'
      expect(all(".abstractor_object_value_variant")[i].find('.case_sensitive').has_checked_field?('Case Sensitive?', disabled: disabled)).to be_truthy
    end

    if  abstractor_object_value_variant_hash['Case Sensitive?'] == 'no'
      expect(all(".abstractor_object_value_variant")[i].find('.case_sensitive').has_unchecked_field?('Case Sensitive?', disabled: disabled)).to be_truthy
    end
  end
end

Then(/^"([^"]*)" field should display the error message "([^"]*)"$/) do |field_label, error_message|
  expect(page).to have_css("#abstractor_object_value .#{field_label.parameterize("_").downcase} .field_with_errors")
  expect(all("#abstractor_object_value .#{field_label.parameterize("_").downcase}")[0]).to have_content(error_message)
end

Then(/^the Variant Values "([^"]*)" field should display the error message "([^"]*)"$/) do |field_label, error_message|
  expect(page).to have_css(".abstractor_object_value_variant .#{field_label.parameterize("_").downcase} .field_with_errors")
  expect(all(".abstractor_object_value_variant .#{field_label.parameterize("_").downcase}")[0]).to have_content(error_message)
end