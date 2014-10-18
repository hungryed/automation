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

  def fill_in_search_with(string)
    google_search.send_keys(string)
    google_search.send_keys(:return)
  end

  def extract_text_from(element, regex)
    element.text.match(/#{regex}/).try(:[], 0..-1).try(:first)
  end

  it "does" do
    visit sign_in_path
    binding.pry
    2.times do
      begin
        visit hit_path
        accept_button.click
        hit_url = page.current_url

        barcode = all('h3').find { |nodes| nodes.text.match(/Product barcode value/) }
        barcode_string = extract_text_from(barcode, "[^Product barcode value:](.*)/)")
        visit_google
        fill_in_search_with(barcode_string)

        if google_results.length < 2
          visit hit_url
          find('input[name="Answer_3"]').click
          submit_button.click
        else
          binding.pry
        end
      rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
        binding.pry
        sleep 2
        retry
      end
    end
  end
end
