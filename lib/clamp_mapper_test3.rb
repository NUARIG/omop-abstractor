require './lib/clamp_mapper/parser'
file = "/Users/mjg994/Documents/source/omop-abstractor/lib/setup/data_out/custom_nlp_provider_clamp/NoteStableIdentifier_417_1599130437.xmi"
parser = ClampMapper::Parser.new
parser.read(file)
clamp_note = parser.document
# puts parser.document.xmi_document
# puts parser.document.name
# puts parser.document.text
file = file.gsub('xmi', 'json')
abstractor_note = File.read(file)
abstractor_note = JSON.parse(abstractor_note)

puts clamp_note.named_entities.size
puts clamp_note.section_named_entities.size

# {
#   "abstractor_abstraction_schema_id": 358,
#   "abstractor_abstraction_schema_uri": "http://localhost:3000/abstractor_abstraction_schemas/358.json",
#   "abstractor_abstraction_abstractor_suggestions_uri": "http://localhost:3000/abstractor_abstractions/1182/abstractor_suggestions.json",
#   "abstractor_abstraction_id": 1182,
#   "abstractor_abstraction_source_id": 698,
#   "abstractor_subject_id": 698,
#   "namespace_type": "Abstractor::AbstractorNamespace",
#   "namespace_id": 95,
#   "abstractor_rule_type": "value",
#   "updated_at": "2020-08-27T21:47:34Z"
# }

abstractor_note['abstractor_abstraction_schemas'].each do |abstractor_abstraction_schema|
  abstractor_abstraction = Abstractor::AbstractorAbstraction.find(abstractor_abstraction_schema['abstractor_abstraction_id'])
  puts abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate
  abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.find(abstractor_abstraction_schema['abstractor_abstraction_source_id'])
  puts "abstractor_abstraction_schema['abstractor_abstraction_source_id']"
  puts abstractor_abstraction_schema['abstractor_abstraction_source_id']

  named_entities = clamp_note.named_entities.select { |named_entity|  named_entity.semantic_tag_attribute == abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate }

  puts 'how much you got?'
  puts named_entities.size

  # abstractor_section_names = abstractor_abstraction_source.abstractor_abstraction_source_sections.map { |abstractor_abstraction_source_section| abstractor_abstraction_source_section.abstractor_section.name }
  #
  # puts 'begin sections'
  # puts abstractor_section_names
  # puts 'end sections'
  # puts 'hello'
  # puts clamp_note.named_entities.size
  # named_entities = clamp_note.named_entities.reject { |named_entity|  named_entity.specimen }
  # puts named_entities.size
  # puts 'goodbye'

  if named_entities.any?
    named_entities.each do |named_entity|
      puts 'here is the note'
      puts clamp_note.text

      puts 'named_entity_begin'
      puts named_entity.named_entity_begin

      puts 'named_entity_end'
      puts named_entity.named_entity_end

      puts 'sentence_begin'
      puts named_entity.sentence.sentence_begin

      puts 'sentence_end'
      puts named_entity.sentence.sentence_end

      puts 'match_value'
      puts clamp_note.text[named_entity.named_entity_begin..named_entity.named_entity_end]
      puts 'sentence_match_value'
      puts clamp_note.text[named_entity.sentence.sentence_begin..named_entity.sentence.sentence_end]

      abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
      abstractor_abstraction,
      abstractor_abstraction_source,
      clamp_note.text[named_entity.named_entity_begin..named_entity.named_entity_end], #suggestion_source[:match_value],
      clamp_note.text[named_entity.sentence.sentence_begin..named_entity.sentence.sentence_end], #suggestion_source[:sentence_match_value]
      abstractor_note['source_id'],
      abstractor_note['source_type'],
      abstractor_note['source_method'],
      named_entity.sentence.section.name, #suggestion_source[:section_name]
      named_entity.semantic_tag_value,    #suggestion[:value]
      false,                              #suggestion[:unknown].to_s.to_boolean
      false,                              #suggestion[:not_applicable].to_s.to_boolean
      nil,
      nil,
      named_entity.negated?               #suggestion[:negated].to_s.to_boolean
      )
    end
  else
    abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
    abstractor_abstraction,
    abstractor_abstraction_source,
    nil, #suggestion_source[:match_value],
    nil, #suggestion_source[:sentence_match_value]
    abstractor_note['source_id'],
    abstractor_note['source_type'],
    abstractor_note['source_method'],
    nil, #suggestion_source[:section_name]
    nil,    #suggestion[:value]
    true,                              #suggestion[:unknown].to_s.to_boolean
    false,                              #suggestion[:not_applicable].to_s.to_boolean
    nil,
    nil,
    false               #suggestion[:negated].to_s.to_boolean
    )
  end
end