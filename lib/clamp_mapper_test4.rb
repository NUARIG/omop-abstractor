require './lib/clamp_mapper/parser'
file = "/Users/mjg994/Documents/source/omop-abstractor/lib/setup/data_out/custom_nlp_provider_clamp/NoteStableIdentifier_705_1600422775.xmi"
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

clamp_note.named_entities.each do |named_entity|
  puts named_entity.semantic_tag_attribute
  puts named_entity.semantic_tag_value
  puts clamp_note.text[named_entity.sentence.sentence_begin..named_entity.sentence.sentence_end] #suggestion_source[:match_value],
  puts clamp_note.text[named_entity.sentence.sentence_begin..named_entity.sentence.sentence_end] #suggestion_source[:sentence_match_value]
end

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
  abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.find(abstractor_abstraction_schema['abstractor_abstraction_schema_id'])

  puts "abstractor_abstraction_schema['abstractor_abstraction_source_id']"
  puts abstractor_abstraction_schema['abstractor_abstraction_source_id']

  # ABSTRACTOR_RULE_TYPE_UNKNOWN = 'unknown'
  case abstractor_abstraction_source.abstractor_rule_type.name
  when Abstractor::Enum::ABSTRACTOR_RULE_TYPE_VALUE
    named_entities = clamp_note.named_entities.select { |named_entity|  named_entity.semantic_tag_attribute == abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate }
    puts 'how much you got?'
    puts named_entities.size
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
      nil,                                  #suggestion_source[:section_name]
      nil,                                  #suggestion[:value]
      true,                                 #suggestion[:unknown].to_s.to_boolean
      false,                                #suggestion[:not_applicable].to_s.to_boolean
      nil,
      nil,
      false                                 #suggestion[:negated].to_s.to_boolean
      )
    end
  when Abstractor::Enum::ABSTRACTOR_RULE_TYPE_NAME_VALUE
    named_entities = clamp_note.named_entities.select { |named_entity|  named_entity.semantic_tag_attribute == abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate }
    # ABSTRACTOR_OBJECT_TYPE_LIST                 = 'list'
    # ABSTRACTOR_OBJECT_TYPE_RADIO_BUTTON_LIST    = 'radio button list'

    # ABSTRACTOR_OBJECT_TYPE_NUMBER               = 'number'
    # ABSTRACTOR_OBJECT_TYPE_NUMBER_LIST          = 'number list'

    # ABSTRACTOR_OBJECT_TYPE_BOOLEAN              = 'boolean'
    # ABSTRACTOR_OBJECT_TYPE_STRING               = 'string'
    # ABSTRACTOR_OBJECT_TYPE_DATE                 = 'date'
    # ABSTRACTOR_OBJECT_TYPE_DYNAMIC_LIST         = 'dynamic list'
    # ABSTRACTOR_OBJECT_TYPE_TEXT                 = 'text'

    case abstractor_abstraction_schema.abstractor_object_type.value
    when Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_LIST, Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_RADIO_BUTTON_LIST
      named_entities = clamp_note.named_entities.select { |named_entity|  named_entity.semantic_tag_attribute == abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate }
      puts 'how much you got?'
      puts named_entities.size

      if abstractor_abstraction_schema.deleted_non_deleted_object_type_list?
        named_entities_names = named_entities.select { |named_entity|  named_entity.semantic_tag_value_type == 'Name' }
        named_entities_values = clamp_note.named_entities.select { |named_entity| named_entity.semantic_tag_attribute == 'deleted_non_deleted' && named_entity.semantic_tag_value_type == 'Value'  }

        if named_entities_names.any?
          named_entities_names.each do |named_entity_name|
            values = named_entities_values.select { |named_entities_value| named_entity_name.sentence == named_entities_value.sentence }
            suggested = false
            if values.any?
              values.each do |value|
                abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
                abstractor_abstraction,
                abstractor_abstraction_source,
                clamp_note.text[value.named_entity_begin..value.named_entity_end], #suggestion_source[:match_value],
                clamp_note.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:sentence_match_value]
                abstractor_note['source_id'],
                abstractor_note['source_type'],
                abstractor_note['source_method'],
                named_entity_name.sentence.section.name, #suggestion_source[:section_name]
                value.semantic_tag_value,                 #suggestion[:value]
                false,                                     #suggestion[:unknown].to_s.to_boolean
                false,                                     #suggestion[:not_applicable].to_s.to_boolean
                nil,
                nil,
                (named_entity_name.negated? || value.negated?)   #suggestion[:negated].to_s.to_boolean
                )
                if !suggested && (named_entity_name.negated? && value.negated?)
                  suggested = true
                end
              end
            end
            if !suggested
              abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
              abstractor_abstraction,
              abstractor_abstraction_source,
              nil, #suggestion_source[:match_value],
              nil, #suggestion_source[:sentence_match_value]
              abstractor_note['source_id'],
              abstractor_note['source_type'],
              abstractor_note['source_method'],
              nil,                                  #suggestion_source[:section_name]
              nil,                                  #suggestion[:value]
              true,                                 #suggestion[:unknown].to_s.to_boolean
              false,                                #suggestion[:not_applicable].to_s.to_boolean
              nil,
              nil,
              false                                 #suggestion[:negated].to_s.to_boolean
              )
            end
          end
        end
      elsif abstractor_abstraction_schema.positive_negative_object_type_list?
        named_entities_names = named_entities.select { |named_entity|  named_entity.semantic_tag_value_type == 'Name' }
        named_entities_values = clamp_note.named_entities.select { |named_entity| named_entity.semantic_tag_attribute == 'positive_negative'  && named_entity.semantic_tag_value_type == 'Value'  }

        if named_entities_names.any?
          named_entities_names.each do |named_entity_name|
            values = named_entities_values.select { |named_entities_value| named_entity_name.sentence == named_entities_value.sentence }
            suggested = false
            if values.any?
              values.each do |value|
                abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
                abstractor_abstraction,
                abstractor_abstraction_source,
                clamp_note.text[value.named_entity_begin..value.named_entity_end], #suggestion_source[:match_value],                clamp_note.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:sentence_match_value]
                abstractor_note['source_id'],
                abstractor_note['source_type'],
                abstractor_note['source_method'],
                named_entity_name.sentence.section.name, #suggestion_source[:section_name]
                value.semantic_tag_value,                 #suggestion[:value]
                false,                                     #suggestion[:unknown].to_s.to_boolean
                false,                                     #suggestion[:not_applicable].to_s.to_boolean
                nil,
                nil,
                (named_entity_name.negated? || value.negated?)   #suggestion[:negated].to_s.to_boolean
                )
                if !suggested && (named_entity_name.negated? && value.negated?)
                  suggested = true
                end
              end
            end
            if !suggested
              abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
              abstractor_abstraction,
              abstractor_abstraction_source,
              nil, #suggestion_source[:match_value],
              nil, #suggestion_source[:sentence_match_value]
              abstractor_note['source_id'],
              abstractor_note['source_type'],
              abstractor_note['source_method'],
              nil,                                  #suggestion_source[:section_name]
              nil,                                  #suggestion[:value]
              true,                                 #suggestion[:unknown].to_s.to_boolean
              false,                                #suggestion[:not_applicable].to_s.to_boolean
              nil,
              nil,
              false                                 #suggestion[:negated].to_s.to_boolean
              )
            end
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
          nil,                                  #suggestion_source[:section_name]
          nil,                                  #suggestion[:value]
          true,                                 #suggestion[:unknown].to_s.to_boolean
          false,                                #suggestion[:not_applicable].to_s.to_boolean
          nil,
          nil,
          false                                 #suggestion[:negated].to_s.to_boolean
          )
        end
      end
    when Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_NUMBER, Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_NUMBER_LIST      
      named_entities_names = named_entities.select { |named_entity|  named_entity.semantic_tag_value_type == 'Name' }
      named_entities_values = clamp_note.named_entities.select { |named_entity| named_entity.semantic_tag_attribute == 'number' && named_entity.semantic_tag_value_type == 'Value'  }
      if named_entities_names.any?
        named_entities_names.each do |named_entity_name|
          values = named_entities_values.select { |named_entities_value| named_entity_name.sentence == named_entities_value.sentence }
          suggested = false
          if values.any?
            values.each do |value|
              if value.scan('%').present?
                value = (Percentage.new("50.0%").to_f / 100)
              end
              
              abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
              abstractor_abstraction,
              abstractor_abstraction_source,
              clamp_note.text[value.named_entity_begin..value.named_entity_end], #suggestion_source[:match_value],              
              clamp_note.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:sentence_match_value]
              abstractor_note['source_id'],
              abstractor_note['source_type'],
              abstractor_note['source_method'],
              named_entity_name.sentence.section.name, #suggestion_source[:section_name]
              value.semantic_tag_value,                 #suggestion[:value]
              false,                                     #suggestion[:unknown].to_s.to_boolean
              false,                                     #suggestion[:not_applicable].to_s.to_boolean
              nil,
              nil,
              (named_entity_name.negated? || value.negated?)   #suggestion[:negated].to_s.to_boolean
              )
              if !suggested && (named_entity_name.negated? && value.negated?)
                suggested = true
              end
            end
          end
          if !suggested
            abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
            abstractor_abstraction,
            abstractor_abstraction_source,
            nil, #suggestion_source[:match_value],
            nil, #suggestion_source[:sentence_match_value]
            abstractor_note['source_id'],
            abstractor_note['source_type'],
            abstractor_note['source_method'],
            nil,                                  #suggestion_source[:section_name]
            nil,                                  #suggestion[:value]
            true,                                 #suggestion[:unknown].to_s.to_boolean
            false,                                #suggestion[:not_applicable].to_s.to_boolean
            nil,
            nil,
            false                                 #suggestion[:negated].to_s.to_boolean
            )
          end
        end
      end
    end
  end
end