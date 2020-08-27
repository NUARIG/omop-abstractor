require './lib/clamp_mapper/parser'

parser = ClampMapper::Parser.new
file = 'lib/setup/data/clamp/sample.xmi'
parser.read(file)
parser.document.xmi_document
parser.document.name
parser.document.text

parser.document.sections.size
parser.document.sections[0]
parser.document.sections[0].section_begin
parser.document.sections[0].section_end
parser.document.sections[0].section_names.size
parser.document.sections[0].section_names.each do |section_name|
  puts section_name
end

parser.document.sentences.size
parser.document.sentences[0]
parser.document.sentences[0].sentence_begin
parser.document.sentences[0].sentence_end
parser.document.sentences[0].sentence_number
parser.document.sentences[0].section

parser.document.named_entities.size
parser.document.named_entities[0]
parser.document.named_entities[0].named_entity_begin
parser.document.named_entities[0].named_entity_end
parser.document.named_entities[0].semantic_tag
parser.document.named_entities[0].assertion


old
  create_table "abstractor_sections", force: :cascade do |t|
    t.integer "abstractor_section_type_id"
    t.string "source_type"
    t.string "source_method"
    t.string "name"
    t.string "description"
    t.string "delimiter"
    t.string "custom_regular_expression"
    t.boolean "return_note_on_empty_section"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_section_name_variants", force: :cascade do |t|
    t.integer "abstractor_section_id"
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_abstraction_sources", force: :cascade do |t|
    t.integer "abstractor_subject_id"
    t.string "from_method"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "custom_method"
    t.integer "abstractor_abstraction_source_type_id"
    t.integer "abstractor_rule_type_id"
    t.string "section_name"
    t.string "custom_nlp_provider"
  end

  create_table "abstractor_suggestions", force: :cascade do |t|
    t.integer "abstractor_abstraction_id"
    t.string "suggested_value"
    t.boolean "unknown"
    t.boolean "not_applicable"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "accepted"
    t.index ["abstractor_abstraction_id"], name: "index_abstractor_abstraction_id_2"
  end

  create_table "abstractor_suggestion_sources", force: :cascade do |t|
    t.integer "abstractor_abstraction_source_id"
    t.integer "abstractor_suggestion_id"
    t.text "match_value"
    t.text "sentence_match_value"
    t.integer "source_id"
    t.string "source_method"
    t.string "source_type"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "custom_method"
    t.string "custom_explanation"
    t.string "section_name"
    t.index ["abstractor_suggestion_id"], name: "index_abstractor_suggestion_id"
  end

new
  alter

    abstractor_abstraction_sources
      add section_required boolean

    abstractor_suggestions
      add system_rejected        boolean
      add system_rejected_reason string

      add system_accepted        boolean
      add system_accepted_reason string

    abstractor_sections
      add auto_accept            boolean ?

  create
    create_table "abstractor_abstraction_source_sections", force: :cascade do |t|
      t.integer "abstractor_abstraction_source_id"
      t.integer "abstractor_section_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

  generic
    AN-352
    AN-353
    AN-354
    AN-355

  setup entries in abstractor_abstraction_source_sections
  clamp_mapper will insert into abstractor_suggestion_sources with a section_name of the section it found a named entity within

  if abstractor_abstraction_sources is not setup with any abstractor_abstraction_source_sections then insert the CLAMP named entity into abstractor_suggestions and abstractor_suggestion_sources and set abstractor_suggestions.accepted = false and abstractor_suggestions.system_rejected = false and abstractor_suggestions.system_accepted = false.
  if abstractor_abstraction_sources is setup with any abstractor_abstraction_source_sections, and the CLAMP named entity section_name matches a section name or one of its variants, then insert the CLAMP named entity into abstractor_suggestions and abstractor_suggestion_sources.  Set abstractor_suggestions.accepted = true and abstractor_suggestions.system_accepted = true and abstractor_suggestions.system_accepted_reason = 'Matches a setup section.'
  if abstractor_abstraction_sources is setup with any abstractor_abstraction_source_sections and abstractor_abstraction_sources.section_required = true, and the CLAMP named entity section_name does not match a section name or one of its variants, then insert the CLAMP named entity into abstractor_suggestions and abstractor_suggestion_sources. Set abstractor_suggestions.accepted = false and abstractor_suggestions.system_rejected = true and abstractor_suggestions.system_rejected_reason = 'Not in any setup section.'
  if abstractor_abstraction_sources is setup with any abstractor_abstraction_source_sections and abstractor_abstraction_sources.section_required = false, and the CLAMP named entity section_name does not match a section name or one of its variants, then insert the CLAMP named entity into abstractor_suggestions and abstractor_suggestion_sources. Set abstractor_suggestions.accepted = null and abstractor_suggestions.system_rejected = false.

  if the CLAMP named entity assertion=negative, then insert the CLAMP named entity into abstractor_suggestions and abstractor_suggestion_sources. Set abstractor_suggestions.accepted = false and abstractor_suggestions.system_rejected = true and abstractor_suggestions.system_rejected_reason = 'Negated.'

  later
    AN-356
    AN-357
    AN-358

  hardcoded
    AN-359
    AN-360

  reassess
    AN-361

  name/value
    AN-362
    AN-363

  create_table "abstractor_abstraction_schema_relations", force: :cascade do |t|
    t.integer "subject_id"
    t.integer "object_id"
    t.integer "abstractor_relation_type_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
