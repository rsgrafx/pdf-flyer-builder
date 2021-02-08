require 'json'

class Listing 
  attr_accessor :path, :json_data, :data
  
  def initialize(path)
    @path = (File.join(File.expand_path('../', File.dirname(__FILE__)), path))
  end

  def load_data
    @json_data=File.read(@path)
  end

  def parse 
    @data=Hash[JSON.parse(json_data).map {|k, v| [k.to_sym, v]}]
  end

end

listing = Listing.new("tmp/listing123.json")

listing.load_data()
listing.parse()
puts listing.data[:name].inspect()
