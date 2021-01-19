require './lib/clamp_mapper/process_note'
require './lib/clamp_mapper/parser'
file = "/Users/mjg994/Documents/source/omop-abstractor/lib/setup/data/clamp/NoteStableIdentifier_86074_1609006633.json"
abstractor_note = ClampMapper::ProcessNote.process(JSON.parse(File.read(file)))
clamp_document = ClampMapper::Parser.new.read(abstractor_note)

#step 1
sections_grouped = clamp_document.sections.group_by do |section|
  section.name
end

puts "sections_grouped['SPECIMEN'].size"
puts sections_grouped['SPECIMEN'].size
puts "sections_grouped['COMMENT'].size"
puts sections_grouped['COMMENT'].size

bad_guy_sections = []
sections_grouped.each do |section_name, sections|
  if section_name == 'SPECIMEN'
    previous_section_trigger = sections.first.trigger
    puts 'here is the first trigger'
    puts previous_section_trigger
    sections.each_with_index do |section, i|
      puts 'section token'
      puts section.to_s
      puts 'trigger'
      puts section.trigger


      if i > 0 && section.trigger.downcase <= previous_section_trigger.downcase
        bad_guy_sections << section
      else
        previous_section_trigger = section.trigger
      end
    end
  end
end

bad_guy_sections.each do |bad_guy_section|
  clamp_document.sections.reject! { |section| section == bad_guy_section }
end

sections_grouped = clamp_document.sections.group_by do |section|
  section.name
end

puts "sections_grouped['SPECIMEN'].size"
puts sections_grouped['SPECIMEN'].size
puts "sections_grouped['COMMENT'].size"
puts sections_grouped['COMMENT'].size

#step 2
if !sections_grouped['SPECIMEN'].empty? && !sections_grouped['COMMENT'].empty?
  bad_guy_sections = []
  sections_grouped['SPECIMEN'].each do |specimen_section|
    if sections_grouped['COMMENT'][0].section_end < specimen_section.section_begin
      bad_guy_sections << specimen_section
    end
  end
end

bad_guy_sections.each do |bad_guy_section|
  clamp_document.sections.reject! { |section| section == bad_guy_section  }
end

sections_grouped = clamp_document.sections.group_by do |section|
  section.name
end

puts "sections_grouped['SPECIMEN'].size"
puts sections_grouped['SPECIMEN'].size
puts "sections_grouped['COMMENT'].size"
puts sections_grouped['COMMENT'].size

#step 3
if sections_grouped['SPECIMEN'].nil? && !sections_grouped['COMMENT'].empty?
  clamp_document.add_named_entity(0, sections_grouped['COMMENT'][0].section_begin-2, 'SPECIMEN', 'present', true)
end

sections_grouped = clamp_document.sections.group_by do |section|
  section.name
end

puts "sections_grouped['SPECIMEN'].size"
puts sections_grouped['SPECIMEN'].size
puts "sections_grouped['COMMENT'].size"
puts sections_grouped['COMMENT'].size

note_stable_identifier = NoteStableIdentifier.find(abstractor_note['source_id'])
##
anchor_sections =[]
anchor_predicate = nil
section_abstractor_abstraction_group_map = {}
if clamp_document.sections.any?
  note_stable_identifier.abstractor_abstraction_groups_by_namespace(namespace_type: abstractor_note['namespace_type'], namespace_id: abstractor_note['namespace_id']).each do |abstractor_abstraction_group|
    puts 'hello'
    puts abstractor_abstraction_group.abstractor_subject_group.name

    if abstractor_abstraction_group.anchor?
      puts 'we have an anchor'
      anchor_predicate = abstractor_abstraction_group.anchor.abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate
      puts anchor_predicate
      anchor_sections = []
      abstractor_abstraction_group.anchor.abstractor_abstraction.abstractor_subject.abstractor_abstraction_sources.each do |abstractor_abstraction_source|
        abstractor_abstraction_source.abstractor_abstraction_source_sections.each do |abstractor_abstraction_source_section|
          anchor_sections << abstractor_abstraction_source_section.abstractor_section.name
        end
      end
      anchor_sections.uniq!

      puts 'anchor_sections'
      puts anchor_sections.size

      anchor_named_entities = clamp_document.named_entities.select { |named_entity|  named_entity.semantic_tag_attribute == anchor_predicate && !named_entity.negated? && named_entity.sentence.section && anchor_sections.include?(named_entity.sentence.section.name) }

      puts 'anchor_named_entities'
      puts anchor_named_entities.size

      anchor_named_entity_sections = anchor_named_entities.group_by{ |anchor_named_entity|  anchor_named_entity.sentence.section.section_range }.keys.sort_by(&:min)

      puts 'are we going to land?'
      puts anchor_named_entity_sections.size
      first_anchor_named_entity_section = anchor_named_entity_sections.shift
      if section_abstractor_abstraction_group_map[first_anchor_named_entity_section]
        section_abstractor_abstraction_group_map[first_anchor_named_entity_section] << abstractor_abstraction_group
      else
        puts 'in the digs'
        section_abstractor_abstraction_group_map[first_anchor_named_entity_section] = [abstractor_abstraction_group]
      end

      anchor_named_entities = clamp_document.named_entities.select { |named_entity|  named_entity.semantic_tag_attribute == anchor_predicate && named_entity.sentence.section && named_entity.sentence.section.section_range == first_anchor_named_entity_section }

      prior_anchor_named_entities = []
      prior_anchor_named_entities << anchor_named_entities.map(&:semantic_tag_value).sort
      for anchor_named_entity_section in anchor_named_entity_sections
        #moomin
        anchor_named_entities = clamp_document.named_entities.select { |named_entity|  named_entity.semantic_tag_attribute == anchor_predicate && named_entity.sentence.section && named_entity.sentence.section.section_range == anchor_named_entity_section }

        unless prior_anchor_named_entities.include?(anchor_named_entities.map(&:semantic_tag_value).sort)

          abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.create_abstractor_abstraction_group(abstractor_abstraction_group.abstractor_subject_group_id, abstractor_note['source_type'], abstractor_note['source_id'], abstractor_note['namespace_type'], abstractor_note['namespace_id'])

          if section_abstractor_abstraction_group_map[anchor_named_entity_section]
            section_abstractor_abstraction_group_map[anchor_named_entity_section] << abstractor_abstraction_group
          else
            section_abstractor_abstraction_group_map[anchor_named_entity_section] = [abstractor_abstraction_group]
          end

          abstractor_abstraction_group.abstractor_abstraction_group_members.each do |abstractor_abstraction_group_member|
            abstractor_abstraction_source = abstractor_abstraction_group_member.abstractor_abstraction.abstractor_subject.abstractor_abstraction_sources.first
            abstractor_suggestion = abstractor_abstraction_group_member.abstractor_abstraction.abstractor_subject.suggest(
            abstractor_abstraction_group_member.abstractor_abstraction,
            abstractor_abstraction_source,
            nil, #suggestion_source[:match_value],
            nil, #suggestion_source[:sentence_match_value]
            abstractor_note['source_id'],
            abstractor_note['source_type'],
            abstractor_note['source_method'],
            nil,                                  #suggestion_source[:section_name]
            nil,                                  #suggestion[:value]
            false,                                #suggestion[:unknown].to_s.to_boolean
            true,                                 #suggestion[:not_applicable].to_s.to_boolean
            nil,
            nil,
            false                                 #suggestion[:negated].to_s.to_boolean
            )
          end
          prior_anchor_named_entities << anchor_named_entities.map(&:semantic_tag_value).sort
        end
      end
    end
  end
end





anchor_predicate = 'has_cancer_histology'
anchor_named_entities = clamp_document.named_entities.select { |named_entity|  named_entity.semantic_tag_attribute == anchor_predicate && !named_entity.negated? && named_entity.sentence.section && anchor_sections.include?(named_entity.sentence.section.name) }
anchor_named_entities = clamp_document.named_entities.select { |named_entity|  named_entity.semantic_tag_attribute == anchor_predicate }

anchor_named_entities[0].sentence.section.name


clamp_document.section_named_entities.each do |section_named_entity|
  puts section_named_entity.semantic_tag
  puts section_named_entity.named_entity_range
end

SPECIMEN
128..143
SPECIMEN
145..147
COMMENT
227..231
SPECIMEN
865..867
COMMENT
926..930
SPECIMEN
1646..1658
SPECIMEN
0..225

clamp_document.sections.each do |section|
  puts section.name
  puts section.section_begin
  puts section.section_end
end

COMMENT
227
863
COMMENT
926
1645
SPECIMEN
0
225