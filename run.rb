require 'nokogiri'
require 'open-uri'
require 'uri'

class Rudiment
  attr_accessor :name, :image_src, :exercise_src

  BASE_URL = 'http://www.vicfirth.com/education/'

  def initialize(attributes = {})
    attributes.each do |k,v|
      send("#{k}=", v)
    end
    self
  end

  def to_html
    <<-html
      <h2>#{name}</h2>
      <p class="rudiment-image">
        <img src="#{image_url}" />
      </p>
      <h3>Exercise</h3>
      <p class="rudiment-exercise">
        <img src="#{exercise_url}" />
      </p>
    html
  end

  def image_url
    File.join(image_directory, 'rudiment.gif')
  end

  def exercise_url
    File.join(image_directory, 'exercise.gif')
  end

  def download_images!
    FileUtils.mkdir_p image_directory

    if image_src
      # Get the image
      $stderr.puts "downloading #{external_url(image_src)}"
      File.open(image_url,'wb'){ |f| f.write(open(external_url(image_src)).read) }
    end

    if exercise_src
      # Get the example
      $stderr.puts "downloading #{external_url(exercise_src)}"
      File.open(exercise_url,'wb'){ |f| f.write(open(external_url(exercise_src)).read) }
    end
  end

  private
  def image_directory
    File.join('images', name.downcase.gsub(/\s+/, '_').gsub(/\W/, ''))
  end

  def make_absolute(root, href)
    URI.parse(root).merge(URI.parse(href)).to_s
  end

  def external_url(src)
    make_absolute("#{BASE_URL}/rudiments/", src)
  end
end

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