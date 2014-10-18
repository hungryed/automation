describe 'autofill' do
  let(:sign_in_path) { 'https://www.mturk.com/mturk/beginsignin' }
  let(:google_search) { find('input[name="q"]').native }
  let(:visit_google) { visit 'https://www.google.com' }
  let(:hit_path) { 'https://www.mturk.com/mturk/preview?groupId=3NVVDJT9G6NCC7MWGLSHAEOQMY0PX3' }
  let(:accept_button) { all('input[name="/accept"]').first }
  let(:submit_button) { all('input[name="/submit"]').first }
  let(:google_results) {
    results = []
    within '#res' do
      results = all('a').select { |link| link.text.present? }
    end
    results
  }

  before(:all) do
    visit sign_in_path
    binding.pry # wait for user to sign in
  end

  before :each do
    visit hit_path
    accept_button.click
    @hit_url = page.current_url
  end

  after :each do
    sleep 2
  end

  def fill_in_search_with(string)
    google_search.send_keys(string)
    google_search.send_keys(:return)
  end

  def extract_text_from(element, regex)
    element.text.match(/#{regex}/).try(:[], 0..-1).try(:first)
  end

  def run_sequence
    begin
      barcode = all('h3').find { |nodes| nodes.text.match(/Product barcode value/) }
      barcode_string = extract_text_from(barcode.reload, "[^Product barcode value:](.*)/)")
    rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
      binding.pry # check error
      retry
    end
    visit_google
    fill_in_search_with(barcode_string)

    if google_results.length < 2
      visit @hit_url
      find('input[name="Answer_3"]').click
      submit_button.click
    else
      binding.pry # wait for user to get correct link
    end
  end

# would do a loop but something about session reset is causing a
# stale element issue. investigate later
  it "does" do
    run_sequence
  end

  it "does" do
    run_sequence
  end

  # it "does" do
  #   run_sequence
  # end

  # it "does" do
  #   run_sequence
  # end
end
