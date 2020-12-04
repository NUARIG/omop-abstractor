require './lib/clamp_mapper/parser'
file = "/Users/mjg994/Documents/source/omop-abstractor/lib/setup/data/clamp/sample.xmi"
clamp_xmi = File.read(file)
@document = ClampMapper::Document.new(Nokogiri::XML(clamp_xmi), file)

sections_grouped = @document.sections.group_by do |section|
  section.name
end

bad_guy_sections = []
sections_grouped.each do |section_name, sections|
  if section_name == 'SPECIMEN'
    previous_section_trigger = sections.first.trigger
    sections.each do |section|
      puts 'section token'
      puts section.to_s
      puts 'trigger'
      puts section.trigger

      if section.trigger.downcase < previous_section_trigger.downcase
        bad_guy_sections << section
      else
        previous_section_trigger = section.trigger
      end
    end
  end
end

bad_guy_sections.each do |bad_guy_section|
  @document.sections.reject! { |section| section == bad_guy_section  }
end


@document.named_entities.each do |named_entity|
  puts named_entity.semantic_tag_value
end

# named_entity = @document.named_entities.detect do |named_entity|
#   named_entity.semantic_tag_value == 'melanotic schwannoma (neurilemmoma ,  neurinoma) (9560/0)'
# end

named_entity = @document.named_entities.detect do |named_entity|
  named_entity.semantic_tag_value == 'osteosarcoma (9180/3)'
end


values = [5,10]
sentence = 'The p53 immunostain shows moderate immunoreactivity in about 5-10% of the tumor cells.'
regexp = Regexp.new("#{values.first}\-#{values.last}\%")
match = sentence.match(regexp)
hello = (Percentage.new((((values.first.to_f + values.last.to_f)/2)) / 100))