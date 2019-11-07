require 'rails_helper'
RSpec.feature 'Home', type: :system do
  before(:each) do
    WebMock.disable_net_connect!(allow_localhost: true)
    visit root_path
    sleep(1)
  end

  scenario 'works', js: true, focus: true do
    expect(page).to have_css('#home', text: 'OMOP Abstractor')
  end
end