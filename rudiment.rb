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
    html = "<h2>#{name}</h2>"
    html << image_html if has_image?
    html << exercise_html if has_exercise?

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

    if has_image?
      # Get the image
      $stderr.puts "downloading #{external_url(image_src)}"
      File.open(image_url,'wb'){ |f| f.write(open(external_url(image_src)).read) }
    end

    if has_exercise?
      # Get the example
      $stderr.puts "downloading #{external_url(exercise_src)}"
      File.open(exercise_url,'wb'){ |f| f.write(open(external_url(exercise_src)).read) }
    end
  end

  def has_image?
    !!image_src
  end

  def has_exercise?
    !!exercise_src
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

  def image_html
    <<-image_html
      <p class="rudiment-image">
        <img src="#{image_url}" />
      </p>
    image_html
  end

  def exercise_html
    <<-exercise_html
      <h3>Exercise</h3>
      <p class="rudiment-exercise">
        <img src="#{exercise_url}" />
      </p>
    exercise_html
  end
end