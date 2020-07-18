require 'net/http'
require 'uri'
require 'slop'
require 'time'
require 'logger'
require 'json'
require 'descriptive_statistics'

# Create a Logger that prints to STDOUT
log = Logger.new(STDOUT)

# Usage: ruby pingdom_report.rb --from 2020-01-01 --to 2020-12-31 --apitoken xxxxxxx --checkid yyyy
opts = Slop.parse do |o|
    o.string '-f', '--from', 'Start Date (Ex. 2020-04-01)', required: true
    o.string '-t', '--to', 'End Date (Ex. 2020-05-01)', required: true
    o.string '-a', '--apitoken', required: true
    o.string '-c', '--checkid', required: true
    o.on '--version', 'print the version' do
        puts Slop::VERSION
        exit
    end
end

data = []

(opts[:from]..opts[:to]).each do |day|
    log.info("fetching #{day}...")
    uri = URI.parse("https://api.pingdom.com/api/3.1/summary.performance/#{opts[:checkid]}?from=#{Time.parse(day).to_i}&to=#{Time.parse(day).to_i + 86400}&resolution=hour")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{opts[:apitoken]}"

    req_options = {
    use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
    end

    if response.code != "200" then
        log.error("#{response.code}: #{response.body}")
        exit
    end

    body = JSON.parse(response.body)

    body['summary']['hours'].each do |point|
        data << point['avgresponse']
    end
end

p "term: #{opts[:from]}~#{opts[:to]}, max: #{data.max}msec, min: #{data.min}msec, median: #{data.median}msec, 95%: #{data.percentile(95).to_i}msec"