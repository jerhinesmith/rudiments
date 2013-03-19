require 'nokogiri'
require 'open-uri'
require File.join(File.dirname(__FILE__), 'rudiment')

doc = Nokogiri::HTML(open("#{Rudiment::BASE_URL}/rudiments.php"))

$stderr.puts "building a list of links"
rudiment_links = doc.css('table tr td p a').collect{|a| a['href']}.select{|l| l =~ /^rudiments\//}.collect{|l| "#{Rudiment::BASE_URL}#{l}"}

output = "<html><head><title>Rudiments</title></head><body>"

rudiment_links.each do |link|
  $stderr.puts "Retrieving #{link}"
  rudiment_doc = Nokogiri::HTML(open(link))
  name = rudiment_doc.at_css('.header1').content
  image_src = rudiment_doc.at_css('.header1 + p > img').attr('src')
  exercise_src = rudiment_doc.css('img').collect{|i| i.attr('src')}.select{|i| i =~ /exercise\.gif$/}.first

  r = Rudiment.new(:name => name, :image_src => image_src, :exercise_src => exercise_src)
  r.download_images!
  output << r.to_html
end

output << "</body></html>"

puts output