require './lib/clamp_mapper/parser'
file = "/Users/mjg994/Documents/source/omop-abstractor/lib/setup/data/clamp/sample.xmi"
clamp_xmi = File.read(file)
@document = ClampMapper::Document.new(Nokogiri::XML(clamp_xmi), file)
@document.named_entities.each do |named_entity|
  puts named_entity.semantic_tag_value
end

# named_entity = @document.named_entities.detect do |named_entity|
#   named_entity.semantic_tag_value == 'melanotic schwannoma (neurilemmoma ,  neurinoma) (9560/0)'
# end

named_entity = @document.named_entities.detect do |named_entity|
  named_entity.semantic_tag_value == 'osteosarcoma (9180/3)'
end
