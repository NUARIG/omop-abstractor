require 'rails_helper'
RSpec.feature 'Adding an abstractor object value.  User should be able to add an abstractor object value', type: :system do
  before(:each) do
    WebMock.disable_net_connect!(allow_localhost: true)
    Abstractor::Setup.system
    OmopAbstractor::SpecSetup.encounter_note
    OmopAbstractor::SpecSetup.sites
    OmopAbstractor::SpecSetup.custom_site_synonyms
    OmopAbstractor::SpecSetup.site_categories
    OmopAbstractor::SpecSetup.laterality
    OmopAbstractor::SpecSetup.radiation_therapy_prescription
    OmopAbstractor::SpecSetup.pathology_case
    OmopAbstractor::SpecSetup.surgery
    OmopAbstractor::SpecSetup.imaging_exam
  end

  scenario 'Adding an abstractor object value', js: true, focus: false do
    visit abstractor_abstraction_schemas_path
    logs_in('mjg994', 'secret')
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(display_name: 'Anatomical location').first

    within("#abstractor_abstractor_abstraction_schema_#{abstractor_abstraction_schema.id}") do
      click_link('Values')
    end
    click_link('New')
    fill_in 'Value', with: 'moomin'
    fill_in 'Vocabulary Code', with: 'moomin code'
    fill_in 'Comments', with: 'moomin comments'
    click_link('Add variant')
    fill_in 'Variant Value', with: 'moomin variant'
    within('.abstractor_object_value_variant') do
      check('Case Sensitive?', allow_label_click: true)
    end

    click_button('Save')
    fill_in 'Search', with: 'moomin'
    click_button('Search')
    match_abstractor_object_value_row('moomin', 'moomin code', 0)
    abstractor_object_value = abstractor_abstraction_schema.abstractor_object_values.where(value: 'moomin').first
    within("#abstractor_abstractor_object_value_#{abstractor_object_value.id}") do
      click_link('Edit')
    end

    expect(page.has_field?('Value', with: 'moomin', disabled: false)).to be_truthy
    expect(page.has_field?('Vocabulary Code', with: 'moomin code', disabled: false)).to be_truthy
    expect(page.has_field?('Comments', with: 'moomin comments', disabled: false)).to be_truthy
    expect(page.has_checked_field?('Case Sensitive?', disabled: false, visible: false)).to be_truthy

    match_abstractor_object_value_variant_row('moomin variant', true, false, 0)
  end

  scenario 'Adding an abstractor object value with validation', js: true, focus: false do
    visit abstractor_abstraction_schemas_path
    logs_in('mjg994', 'secret')
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(display_name: 'Anatomical location').first
    within("#abstractor_abstractor_abstraction_schema_#{abstractor_abstraction_schema.id}") do
      click_link('Values')
    end
    click_link('New')
    click_link('Add variant')
    click_button('Save')
    expect(page).to have_css("#new_abstractor_abstractor_object_value .value .field_with_errors")
    expect(all("#new_abstractor_abstractor_object_value .value")[0]).to have_content("can't be blank")

    expect(page).to have_css("#new_abstractor_abstractor_object_value .vocabulary_code .field_with_errors")
    expect(all("#new_abstractor_abstractor_object_value .vocabulary_code")[0]).to have_content("can't be blank")

    expect(page).to have_css("#abstractor_object_value_variants .value .field_with_errors")
    expect(all("#abstractor_object_value_variants .value")[0]).to have_content("can't be blank")
  end
end

def match_abstractor_object_value_row(value, vocabulary_code, index)
  expect(all('.abstractor_abstractor_object_value')[index].find('.abstractor_object_value_value')).to have_content(value)
  expect(all('.abstractor_abstractor_object_value')[index].find('.abstractor_object_value_vocabulary_code')).to have_content(vocabulary_code)
end

def match_abstractor_object_value_variant_row(value, case_sensitive, disabled, index)
  expect(all('.abstractor_object_value_variant')[index].has_field?('Variant Value', with: value, disabled: disabled)).to be_truthy
  if case_sensitive
    expect(all('.abstractor_object_value_variant')[index].has_checked_field?('Case Sensitive?', disabled: disabled, visible: false)).to be_truthy
  else
    expect(all('.abstractor_object_value_variant')[index].has_unchecked_field?('Case Sensitive?', disabled: disabled, visible: false)).to be_truthy
  end
end