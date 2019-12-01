require 'rails_helper'
RSpec.feature 'Abstractor Schemas', type: :system do
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

  scenario 'Viewing a list of abstraction schemas', js: true, focus: false do
    visit abstractor_abstraction_schemas_path
    logs_in('mjg994', 'secret')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Anatomical location')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Date Schema')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Diagnosis')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Dopamine transporter level')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Duration')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Extent of resection')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Falls')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Favorite major Moomin character')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Favorite minor Moomin character')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Freezing')


    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(display_name: 'Falls').first

    within("#abstractor_abstractor_abstraction_schema_#{abstractor_abstraction_schema.id}") do
      click_link('Values')
    end
    expect(page.current_path).to eq(abstractor_abstraction_schema_abstractor_object_values_path(abstractor_abstraction_schema))

    visit abstractor_abstraction_schemas_path
    sleep(1)

    all('.abstractor_abstraction_schemas_list .pagination a', text: '2')[0].click
    sleep(1)

    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Karnofsky performance status')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Karnofsky performance status date')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Laterality')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Numeric Schema')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'RECIST response criteria')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Radiation therapy prescription date')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Score 1')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Score 2')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'String Schema')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Surgery')

    all('.abstractor_abstraction_schemas_list .pagination a', text: '3')[0].click
    sleep(1)
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Text Schema')

    visit abstractor_abstraction_schemas_path

    find('.abstractor_abstraction_schemas_list th a', text: 'Name').click
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Text Schema')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Surgery')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'String Schema')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Score 2')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Score 1')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Radiation therapy prescription date')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'RECIST response criteria')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Numeric Schema')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Laterality')
    expect(page).to have_css('.abstractor_abstraction_schema_display_name', text: 'Karnofsky performance status date')
  end
end
