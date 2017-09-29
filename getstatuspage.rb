#
# Load incident history / component history from StatusPage.io, and export it as CSV.
#

require 'httpclient'
require 'json'
require 'csv'

APIKEY = 'YOUR_APIKEY'
PAGE_ID = 'YOUR_PAGEID'
ENDPOINT = 'https://api.statuspage.io/v1/pages'

client = HTTPClient.new

headers = {'Authorization': "OAuth #{APIKEY}"}
res = client.get("#{ENDPOINT}/#{PAGE_ID}/incidents.json", nil, headers)
data = JSON.parse(res.body)

data.each.with_index do |json, i|
  csv << json.keys if i==0
  csv << json.values
end

# CSV.open('incidents.csv','w') do |csv|
#   data.each.with_index do |json, i|
#     csv << json.keys if i==0
#     csv << json.values
#   end
# end


# res = client.get("#{ENDPOINT}/#{PAGE_ID}/components.json", nil, headers)
# data = JSON.parse(res.body)

# CSV.open('components.csv','w') do |csv|
#   data.each.with_index do |json, i|
#     csv << json.keys if i==0
#     csv << json.values
#   end
# end
