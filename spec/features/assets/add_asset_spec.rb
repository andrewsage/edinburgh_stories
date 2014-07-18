require 'rails_helper'

feature 'adding new assets', js: true do
  let(:asset_attrs) {{
    file_type:   "image",
    title:       "Arthur's Seat",
    year:        "2014",
    description: "Arthur's Seat is the plug of a long extinct volcano."
  }}
  let(:mock_response) { double('response', body: asset_attrs.to_json) }
  let(:mock_conn)     { double('conn', post: mock_response) }

  before :each do
    allow(Faraday).to receive(:new).and_return(mock_conn)
  end

  scenario 'adding a new asset creates it' do
    visit '/assets/new'

    select asset_attrs[:file_type], from: 'asset[file_type]'
    attach_file :file, File.join(File.dirname(__FILE__), '../../fixtures/files/test.jpg')
    fill_in 'asset[title]', with: asset_attrs[:title]
    select asset_attrs[:year], from: 'asset[year]'
    fill_in 'asset[description]', with: asset_attrs[:description]

    click_button 'Save'

    expect(mock_conn).to have_received(:post) { "/assets" }
    expect(current_path).to eq('/assets')
  end
end
