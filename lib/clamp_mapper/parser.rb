require './lib/clamp_mapper/document'
module ClampMapper
  class Parser
    attr_accessor :document
    def read(file)
      file_name = file.split('/').last
      @document = ClampMapper::Document.new(File.open(file) { |f| Nokogiri::XML(f) }, file_name)
    end
  end
end