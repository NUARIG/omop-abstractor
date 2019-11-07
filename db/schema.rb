# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_07_07_181428) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abstractor_abstraction_group_members", force: :cascade do |t|
    t.integer "abstractor_abstraction_group_id"
    t.integer "abstractor_abstraction_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["abstractor_abstraction_group_id"], name: "index_abstractor_abstraction_group_id"
    t.index ["abstractor_abstraction_id"], name: "index_abstractor_abstraction_id"
  end

  create_table "abstractor_abstraction_groups", force: :cascade do |t|
    t.integer "abstractor_subject_group_id"
    t.string "about_type"
    t.integer "about_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "system_generated", default: false
    t.string "subtype"
    t.index ["about_id", "about_type", "deleted_at"], name: "index_about_id_about_type_deleted_at"
  end

  create_table "abstractor_abstraction_object_values", force: :cascade do |t|
    t.integer "abstractor_abstraction_id"
    t.integer "abstractor_object_value_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_abstraction_schema_object_values", force: :cascade do |t|
    t.integer "abstractor_abstraction_schema_id"
    t.integer "abstractor_object_value_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "display_order"
  end

  create_table "abstractor_abstraction_schema_predicate_variants", force: :cascade do |t|
    t.integer "abstractor_abstraction_schema_id"
    t.string "value"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_abstraction_schema_relations", force: :cascade do |t|
    t.integer "subject_id"
    t.integer "object_id"
    t.integer "abstractor_relation_type_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_abstraction_schemas", force: :cascade do |t|
    t.string "predicate"
    t.string "display_name"
    t.integer "abstractor_object_type_id"
    t.string "preferred_name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_abstraction_source_types", force: :cascade do |t|
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

  create_table "abstractor_abstractions", force: :cascade do |t|
    t.integer "abstractor_subject_id"
    t.string "value"
    t.string "about_type"
    t.integer "about_id"
    t.boolean "unknown"
    t.boolean "not_applicable"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "workflow_status"
    t.string "workflow_status_whodunnit"
    t.index ["about_id", "about_type", "deleted_at"], name: "index_about_id_about_type_deleted_at_2"
    t.index ["abstractor_subject_id"], name: "index_abstractor_subject_id"
  end

  create_table "abstractor_indirect_sources", force: :cascade do |t|
    t.integer "abstractor_abstraction_id"
    t.integer "abstractor_abstraction_source_id"
    t.string "source_type"
    t.integer "source_id"
    t.string "source_method"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_namespace_events", force: :cascade do |t|
    t.integer "abstractor_namespace_id", null: false
    t.string "eventable_type", null: false
    t.integer "eventable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_namespaces", force: :cascade do |t|
    t.string "name", null: false
    t.string "subject_type", null: false
    t.text "joins_clause", null: false
    t.text "where_clause", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_object_types", force: :cascade do |t|
    t.string "value"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_object_value_variants", force: :cascade do |t|
    t.integer "abstractor_object_value_id"
    t.string "value"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "case_sensitive", default: false
  end

  create_table "abstractor_object_values", force: :cascade do |t|
    t.string "value"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "properties"
    t.string "vocabulary_code"
    t.string "vocabulary"
    t.string "vocabulary_version"
    t.text "comments"
    t.boolean "case_sensitive", default: false
  end

  create_table "abstractor_relation_types", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_rule_abstractor_subjects", force: :cascade do |t|
    t.integer "abstractor_rule_id", null: false
    t.integer "abstractor_subject_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_rule_types", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_rules", force: :cascade do |t|
    t.text "rule", null: false
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

  create_table "abstractor_section_types", force: :cascade do |t|
    t.string "name"
    t.string "regular_expression"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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

  create_table "abstractor_subject_group_members", force: :cascade do |t|
    t.integer "abstractor_subject_id"
    t.integer "abstractor_subject_group_id"
    t.integer "display_order"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["abstractor_subject_id"], name: "index_abstractor_subject_id_2"
  end

  create_table "abstractor_subject_groups", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cardinality"
    t.string "subtype"
    t.boolean "enable_workflow_status", default: false
    t.string "workflow_status_submit"
    t.string "workflow_status_pend"
  end

  create_table "abstractor_subject_relations", force: :cascade do |t|
    t.integer "subject_id"
    t.integer "object_id"
    t.integer "abstractor_relation_type_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_subjects", force: :cascade do |t|
    t.integer "abstractor_abstraction_schema_id"
    t.string "subject_type"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dynamic_list_method"
    t.string "namespace_type"
    t.integer "namespace_id"
    t.index ["namespace_type", "namespace_id"], name: "index_namespace_type_namespace_id"
    t.index ["subject_type"], name: "index_subject_type"
  end

  create_table "abstractor_suggestion_object_value_variants", force: :cascade do |t|
    t.integer "abstractor_suggestion_id"
    t.integer "abstractor_object_value_variant_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abstractor_suggestion_object_values", force: :cascade do |t|
    t.integer "abstractor_suggestion_id"
    t.integer "abstractor_object_value_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "api_logs", force: :cascade do |t|
    t.string "system", null: false
    t.text "url"
    t.text "payload"
    t.text "response"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_api_logs_on_created_at"
    t.index ["system"], name: "index_api_logs_on_system"
  end

  create_table "attribute_definition", id: false, force: :cascade do |t|
    t.bigint "attribute_definition_id", null: false
    t.string "attribute_name", limit: 255, null: false
    t.text "attribute_description"
    t.bigint "attribute_type_concept_id", null: false
    t.text "attribute_syntax"
  end

  create_table "care_site", id: false, force: :cascade do |t|
    t.bigint "care_site_id", null: false
    t.string "care_site_name", limit: 255
    t.bigint "place_of_service_concept_id"
    t.bigint "location_id"
    t.string "care_site_source_value", limit: 50
    t.string "place_of_service_source_value", limit: 50
  end

  create_table "cdm_source", id: false, force: :cascade do |t|
    t.string "cdm_source_name", limit: 255, null: false
    t.string "cdm_source_abbreviation", limit: 25
    t.string "cdm_holder", limit: 255
    t.text "source_description"
    t.string "source_documentation_reference", limit: 255
    t.string "cdm_etl_reference", limit: 255
    t.date "source_release_date"
    t.date "cdm_release_date"
    t.string "cdm_version", limit: 10
    t.string "vocabulary_version", limit: 20
  end

  create_table "cohort", id: false, force: :cascade do |t|
    t.bigint "cohort_definition_id", null: false
    t.bigint "subject_id", null: false
    t.date "cohort_start_date", null: false
    t.date "cohort_end_date", null: false
  end

  create_table "cohort_attribute", id: false, force: :cascade do |t|
    t.bigint "cohort_definition_id", null: false
    t.bigint "subject_id", null: false
    t.date "cohort_start_date", null: false
    t.date "cohort_end_date", null: false
    t.bigint "attribute_definition_id", null: false
    t.decimal "value_as_number"
    t.bigint "value_as_concept_id"
  end

  create_table "cohort_definition", id: false, force: :cascade do |t|
    t.bigint "cohort_definition_id", null: false
    t.string "cohort_definition_name", limit: 255, null: false
    t.text "cohort_definition_description"
    t.bigint "definition_type_concept_id", null: false
    t.text "cohort_definition_syntax"
    t.bigint "subject_concept_id", null: false
    t.date "cohort_initiation_date"
  end

  create_table "concept", id: false, force: :cascade do |t|
    t.bigint "concept_id", null: false
    t.string "concept_name", limit: 255, null: false
    t.string "domain_id", limit: 20, null: false
    t.string "vocabulary_id", limit: 20, null: false
    t.string "concept_class_id", limit: 20, null: false
    t.string "standard_concept", limit: 1
    t.string "concept_code", limit: 50, null: false
    t.date "valid_start_date", null: false
    t.date "valid_end_date", null: false
    t.string "invalid_reason", limit: 1
  end

  create_table "concept_ancestor", id: false, force: :cascade do |t|
    t.bigint "ancestor_concept_id", null: false
    t.bigint "descendant_concept_id", null: false
    t.bigint "min_levels_of_separation", null: false
    t.bigint "max_levels_of_separation", null: false
  end

  create_table "concept_class", id: false, force: :cascade do |t|
    t.string "concept_class_id", limit: 20, null: false
    t.string "concept_class_name", limit: 255, null: false
    t.bigint "concept_class_concept_id", null: false
  end

  create_table "concept_relationship", id: false, force: :cascade do |t|
    t.bigint "concept_id_1", null: false
    t.bigint "concept_id_2", null: false
    t.string "relationship_id", limit: 20, null: false
    t.date "valid_start_date", null: false
    t.date "valid_end_date", null: false
    t.string "invalid_reason", limit: 1
  end

  create_table "concept_synonym", id: false, force: :cascade do |t|
    t.bigint "concept_id", null: false
    t.string "concept_synonym_name", limit: 1000, null: false
    t.bigint "language_concept_id", null: false
  end

  create_table "condition_era", id: false, force: :cascade do |t|
    t.bigint "condition_era_id", null: false
    t.bigint "person_id", null: false
    t.bigint "condition_concept_id", null: false
    t.date "condition_era_start_date", null: false
    t.date "condition_era_end_date", null: false
    t.bigint "condition_occurrence_count"
  end

  create_table "condition_occurrence", id: false, force: :cascade do |t|
    t.bigint "condition_occurrence_id", null: false
    t.bigint "person_id", null: false
    t.bigint "condition_concept_id", null: false
    t.date "condition_start_date", null: false
    t.datetime "condition_start_datetime"
    t.date "condition_end_date"
    t.datetime "condition_end_datetime"
    t.bigint "condition_type_concept_id", null: false
    t.string "stop_reason", limit: 20
    t.bigint "provider_id"
    t.bigint "visit_occurrence_id"
    t.string "condition_source_value", limit: 50
    t.bigint "condition_source_concept_id"
    t.string "condition_status_source_value", limit: 50
    t.bigint "condition_status_concept_id"
  end

  create_table "cost", id: false, force: :cascade do |t|
    t.bigint "cost_id", null: false
    t.bigint "cost_event_id", null: false
    t.string "cost_domain_id", limit: 20, null: false
    t.bigint "cost_type_concept_id", null: false
    t.bigint "currency_concept_id"
    t.decimal "total_charge"
    t.decimal "total_cost"
    t.decimal "total_paid"
    t.decimal "paid_by_payer"
    t.decimal "paid_by_patient"
    t.decimal "paid_patient_copay"
    t.decimal "paid_patient_coinsurance"
    t.decimal "paid_patient_deductible"
    t.decimal "paid_by_primary"
    t.decimal "paid_ingredient_cost"
    t.decimal "paid_dispensing_fee"
    t.bigint "payer_plan_period_id"
    t.decimal "amount_allowed"
    t.bigint "revenue_code_concept_id"
    t.string "reveue_code_source_value", limit: 50
    t.bigint "drg_concept_id"
    t.string "drg_source_value", limit: 3
  end

  create_table "death", id: false, force: :cascade do |t|
    t.bigint "person_id", null: false
    t.date "death_date", null: false
    t.datetime "death_datetime"
    t.bigint "death_type_concept_id", null: false
    t.bigint "cause_concept_id"
    t.string "cause_source_value", limit: 50
    t.bigint "cause_source_concept_id"
  end

  create_table "device_exposure", id: false, force: :cascade do |t|
    t.bigint "device_exposure_id", null: false
    t.bigint "person_id", null: false
    t.bigint "device_concept_id", null: false
    t.date "device_exposure_start_date", null: false
    t.datetime "device_exposure_start_datetime"
    t.date "device_exposure_end_date"
    t.datetime "device_exposure_end_datetime"
    t.bigint "device_type_concept_id", null: false
    t.string "unique_device_id", limit: 50
    t.bigint "quantity"
    t.bigint "provider_id"
    t.bigint "visit_occurrence_id"
    t.bigint "visit_detail_id"
    t.string "device_source_value", limit: 100
    t.bigint "device_source_concept_id"
  end

  create_table "domain", id: false, force: :cascade do |t|
    t.string "domain_id", limit: 20, null: false
    t.string "domain_name", limit: 255, null: false
    t.bigint "domain_concept_id", null: false
  end

  create_table "dose_era", id: false, force: :cascade do |t|
    t.bigint "dose_era_id", null: false
    t.bigint "person_id", null: false
    t.bigint "drug_concept_id", null: false
    t.bigint "unit_concept_id", null: false
    t.decimal "dose_value", null: false
    t.date "dose_era_start_date", null: false
    t.date "dose_era_end_date", null: false
  end

  create_table "drug_era", id: false, force: :cascade do |t|
    t.bigint "drug_era_id", null: false
    t.bigint "person_id", null: false
    t.bigint "drug_concept_id", null: false
    t.date "drug_era_start_date", null: false
    t.date "drug_era_end_date", null: false
    t.bigint "drug_exposure_count"
    t.bigint "gap_days"
  end

  create_table "drug_exposure", id: false, force: :cascade do |t|
    t.bigint "drug_exposure_id", null: false
    t.bigint "person_id", null: false
    t.bigint "drug_concept_id", null: false
    t.date "drug_exposure_start_date", null: false
    t.datetime "drug_exposure_start_datetime"
    t.date "drug_exposure_end_date"
    t.datetime "drug_exposure_end_datetime"
    t.date "verbatim_end_date"
    t.bigint "drug_type_concept_id", null: false
    t.string "stop_reason", limit: 20
    t.bigint "refills"
    t.decimal "quantity"
    t.bigint "days_supply"
    t.text "sig"
    t.bigint "route_concept_id"
    t.string "lot_number", limit: 50
    t.bigint "provider_id"
    t.bigint "visit_occurrence_id"
    t.bigint "visit_detail_id"
    t.string "drug_source_value", limit: 50
    t.bigint "drug_source_concept_id"
    t.string "route_source_value", limit: 50
    t.string "dose_unit_source_value", limit: 50
  end

  create_table "drug_strength", id: false, force: :cascade do |t|
    t.bigint "drug_concept_id", null: false
    t.bigint "ingredient_concept_id", null: false
    t.decimal "amount_value"
    t.bigint "amount_unit_concept_id"
    t.decimal "numerator_value"
    t.bigint "numerator_unit_concept_id"
    t.decimal "denominator_value"
    t.bigint "denominator_unit_concept_id"
    t.bigint "box_size"
    t.date "valid_start_date", null: false
    t.date "valid_end_date", null: false
    t.string "invalid_reason", limit: 1
  end

  create_table "fact_relationship", id: false, force: :cascade do |t|
    t.bigint "domain_concept_id_1", null: false
    t.bigint "fact_id_1", null: false
    t.bigint "domain_concept_id_2", null: false
    t.bigint "fact_id_2", null: false
    t.bigint "relationship_concept_id", null: false
  end

  create_table "location", id: false, force: :cascade do |t|
    t.bigint "location_id", null: false
    t.string "address_1", limit: 50
    t.string "address_2", limit: 50
    t.string "city", limit: 50
    t.string "state", limit: 2
    t.string "zip", limit: 9
    t.string "county", limit: 20
    t.string "location_source_value", limit: 50
  end

  create_table "login_audits", force: :cascade do |t|
    t.string "username", null: false
    t.string "login_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "measurement", id: false, force: :cascade do |t|
    t.bigint "measurement_id", null: false
    t.bigint "person_id", null: false
    t.bigint "measurement_concept_id", null: false
    t.date "measurement_date", null: false
    t.string "measurement_time", limit: 10
    t.datetime "measurement_datetime"
    t.bigint "measurement_type_concept_id", null: false
    t.bigint "operator_concept_id"
    t.decimal "value_as_number"
    t.bigint "value_as_concept_id"
    t.bigint "unit_concept_id"
    t.decimal "range_low"
    t.decimal "range_high"
    t.bigint "provider_id"
    t.bigint "visit_occurrence_id"
    t.bigint "visit_detail_id"
    t.string "measurement_source_value", limit: 50
    t.bigint "measurement_source_concept_id"
    t.string "unit_source_value", limit: 50
    t.string "value_source_value", limit: 50
  end

  create_table "metadata", id: false, force: :cascade do |t|
    t.bigint "metadata_concept_id", null: false
    t.bigint "metadata_type_concept_id", null: false
    t.string "name", limit: 250, null: false
    t.text "value_as_string"
    t.bigint "value_as_concept_id"
    t.date "metadata_date"
    t.datetime "metadata_datetime"
  end

  create_table "note", id: false, force: :cascade do |t|
    t.bigint "note_id", null: false
    t.bigint "person_id", null: false
    t.date "note_date", null: false
    t.datetime "note_datetime"
    t.bigint "note_type_concept_id", null: false
    t.bigint "note_class_concept_id", null: false
    t.string "note_title", limit: 250
    t.text "note_text"
    t.bigint "encoding_concept_id", null: false
    t.bigint "language_concept_id", null: false
    t.bigint "provider_id"
    t.bigint "visit_occurrence_id"
    t.bigint "visit_detail_id"
    t.string "note_source_value", limit: 50
  end

  create_table "note_nlp", id: false, force: :cascade do |t|
    t.bigint "note_nlp_id", null: false
    t.bigint "note_id", null: false
    t.bigint "section_concept_id"
    t.string "snippet", limit: 250
    t.string "offset", limit: 250
    t.string "lexical_variant", limit: 250, null: false
    t.bigint "note_nlp_concept_id"
    t.bigint "note_nlp_source_concept_id"
    t.string "nlp_system", limit: 250
    t.date "nlp_date", null: false
    t.datetime "nlp_datetime"
    t.string "term_exists", limit: 1
    t.string "term_temporal", limit: 50
    t.string "term_modifiers", limit: 2000
  end

  create_table "note_stable_identifier", force: :cascade do |t|
    t.bigint "note_id", null: false
    t.string "stable_identifier_path", null: false
    t.string "stable_identifier_value", null: false
    t.index ["note_id"], name: "idx_note_stable_identifier_1"
    t.index ["stable_identifier_path", "stable_identifier_value"], name: "idx_note_stable_identifier_2"
  end

  create_table "observation", id: false, force: :cascade do |t|
    t.bigint "observation_id", null: false
    t.bigint "person_id", null: false
    t.bigint "observation_concept_id", null: false
    t.date "observation_date", null: false
    t.datetime "observation_datetime"
    t.bigint "observation_type_concept_id", null: false
    t.decimal "value_as_number"
    t.string "value_as_string", limit: 60
    t.bigint "value_as_concept_id"
    t.bigint "qualifier_concept_id"
    t.bigint "unit_concept_id"
    t.bigint "provider_id"
    t.bigint "visit_occurrence_id"
    t.bigint "visit_detail_id"
    t.string "observation_source_value", limit: 50
    t.bigint "observation_source_concept_id"
    t.string "unit_source_value", limit: 50
    t.string "qualifier_source_value", limit: 50
  end

  create_table "observation_period", id: false, force: :cascade do |t|
    t.bigint "observation_period_id", null: false
    t.bigint "person_id", null: false
    t.date "observation_period_start_date", null: false
    t.date "observation_period_end_date", null: false
    t.bigint "period_type_concept_id", null: false
  end

  create_table "payer_plan_period", id: false, force: :cascade do |t|
    t.bigint "payer_plan_period_id", null: false
    t.bigint "person_id", null: false
    t.date "payer_plan_period_start_date", null: false
    t.date "payer_plan_period_end_date", null: false
    t.bigint "payer_concept_id"
    t.string "payer_source_value", limit: 50
    t.bigint "payer_source_concept_id"
    t.bigint "plan_concept_id"
    t.string "plan_source_value", limit: 50
    t.bigint "plan_source_concept_id"
    t.bigint "sponsor_concept_id"
    t.string "sponsor_source_value", limit: 50
    t.bigint "sponsor_source_concept_id"
    t.string "family_source_value", limit: 50
    t.bigint "stop_reason_concept_id"
    t.bigint "stop_reason_source_value"
    t.bigint "stop_reason_source_concept_id"
  end

  create_table "person", id: false, force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "gender_concept_id", null: false
    t.bigint "year_of_birth", null: false
    t.bigint "month_of_birth"
    t.bigint "day_of_birth"
    t.datetime "birth_datetime"
    t.bigint "race_concept_id", null: false
    t.bigint "ethnicity_concept_id", null: false
    t.bigint "location_id"
    t.bigint "provider_id"
    t.bigint "care_site_id"
    t.string "person_source_value", limit: 50
    t.string "gender_source_value", limit: 50
    t.bigint "gender_source_concept_id"
    t.string "race_source_value", limit: 50
    t.bigint "race_source_concept_id"
    t.string "ethnicity_source_value", limit: 50
    t.bigint "ethnicity_source_concept_id"
  end

  create_table "pii_address", id: false, force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "location_id"
  end

  create_table "pii_email", id: false, force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "email", limit: 255
  end

  create_table "pii_mrn", id: false, force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "health_system", limit: 50
    t.string "mrn", limit: 50
  end

  create_table "pii_name", id: false, force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "first_name", limit: 200
    t.string "middle_name", limit: 508
    t.string "last_name", limit: 200
    t.string "suffix", limit: 50
    t.string "prefix", limit: 50
  end

  create_table "pii_phone_number", id: false, force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "phone_number", limit: 50
  end

  create_table "procedure_occurrence", id: false, force: :cascade do |t|
    t.bigint "procedure_occurrence_id", null: false
    t.bigint "person_id", null: false
    t.bigint "procedure_concept_id", null: false
    t.date "procedure_date", null: false
    t.datetime "procedure_datetime"
    t.bigint "procedure_type_concept_id", null: false
    t.bigint "modifier_concept_id"
    t.bigint "quantity"
    t.bigint "provider_id"
    t.bigint "visit_occurrence_id"
    t.bigint "visit_detail_id"
    t.string "procedure_source_value", limit: 50
    t.bigint "procedure_source_concept_id"
    t.string "modifier_source_value", limit: 50
  end

  create_table "procedure_occurrence_stable_identifier", force: :cascade do |t|
    t.bigint "procedure_occurrence_id", null: false
    t.string "stable_identifier_path", null: false
    t.string "stable_identifier_value_1", null: false
    t.string "stable_identifier_value_2"
    t.string "stable_identifier_value_3"
    t.string "stable_identifier_value_4"
    t.string "stable_identifier_value_5"
    t.string "stable_identifier_value_6"
  end

  create_table "provider", id: false, force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "provider_name", limit: 255
    t.string "npi", limit: 20
    t.string "dea", limit: 20
    t.bigint "specialty_concept_id"
    t.bigint "care_site_id"
    t.bigint "year_of_birth"
    t.bigint "gender_concept_id"
    t.string "provider_source_value", limit: 50
    t.string "specialty_source_value", limit: 50
    t.bigint "specialty_source_concept_id"
    t.string "gender_source_value", limit: 50
    t.bigint "gender_source_concept_id"
  end

  create_table "relationship", id: false, force: :cascade do |t|
    t.string "relationship_id", limit: 20, null: false
    t.string "relationship_name", limit: 255, null: false
    t.string "is_hierarchical", limit: 1, null: false
    t.string "defines_ancestry", limit: 1, null: false
    t.string "reverse_relationship_id", limit: 20, null: false
    t.bigint "relationship_concept_id", null: false
  end

  create_table "site_categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at"
  end

  create_table "site_categories_sites", id: false, force: :cascade do |t|
    t.integer "site_id"
    t.integer "site_category_id"
  end

  create_table "sites", force: :cascade do |t|
    t.string "icdo3_code", null: false
    t.integer "level", null: false
    t.string "name", null: false
    t.boolean "synonym", null: false
    t.boolean "laterality"
    t.datetime "created_at", null: false
    t.datetime "updated_at"
  end

  create_table "source_to_concept_map", id: false, force: :cascade do |t|
    t.string "source_code", limit: 50, null: false
    t.bigint "source_concept_id", null: false
    t.string "source_vocabulary_id", limit: 20, null: false
    t.string "source_code_description", limit: 255
    t.bigint "target_concept_id", null: false
    t.string "target_vocabulary_id", limit: 20, null: false
    t.date "valid_start_date", null: false
    t.date "valid_end_date", null: false
    t.string "invalid_reason", limit: 1
  end

  create_table "specimen", id: false, force: :cascade do |t|
    t.bigint "specimen_id", null: false
    t.bigint "person_id", null: false
    t.bigint "specimen_concept_id", null: false
    t.bigint "specimen_type_concept_id", null: false
    t.date "specimen_date", null: false
    t.datetime "specimen_datetime"
    t.decimal "quantity"
    t.bigint "unit_concept_id"
    t.bigint "anatomic_site_concept_id"
    t.bigint "disease_status_concept_id"
    t.string "specimen_source_id", limit: 50
    t.string "specimen_source_value", limit: 50
    t.string "unit_source_value", limit: 50
    t.string "anatomic_site_source_value", limit: 50
    t.string "disease_status_source_value", limit: 50
  end

  create_table "sql_audits", force: :cascade do |t|
    t.string "username", null: false
    t.string "auditable_type"
    t.text "auditable_ids"
    t.text "sql", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "username", null: false
    t.boolean "system_administrator"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "visit_detail", id: false, force: :cascade do |t|
    t.bigint "visit_detail_id", null: false
    t.bigint "person_id", null: false
    t.bigint "visit_detail_concept_id", null: false
    t.date "visit_start_date", null: false
    t.datetime "visit_start_datetime"
    t.date "visit_end_date", null: false
    t.datetime "visit_end_datetime"
    t.bigint "visit_type_concept_id", null: false
    t.bigint "provider_id"
    t.bigint "care_site_id"
    t.bigint "admitting_source_concept_id"
    t.bigint "discharge_to_concept_id"
    t.bigint "preceding_visit_detail_id"
    t.string "visit_source_value", limit: 50
    t.bigint "visit_source_concept_id"
    t.string "admitting_source_value", limit: 50
    t.string "discharge_to_source_value", limit: 50
    t.bigint "visit_detail_parent_id"
    t.bigint "visit_occurrence_id", null: false
  end

  create_table "visit_occurrence", id: false, force: :cascade do |t|
    t.bigint "visit_occurrence_id", null: false
    t.bigint "person_id", null: false
    t.bigint "visit_concept_id", null: false
    t.date "visit_start_date", null: false
    t.datetime "visit_start_datetime"
    t.date "visit_end_date", null: false
    t.datetime "visit_end_datetime"
    t.bigint "visit_type_concept_id", null: false
    t.bigint "provider_id"
    t.bigint "care_site_id"
    t.string "visit_source_value", limit: 50
    t.bigint "visit_source_concept_id"
    t.bigint "admitting_source_concept_id"
    t.string "admitting_source_value", limit: 50
    t.bigint "discharge_to_concept_id"
    t.string "discharge_to_source_value", limit: 50
    t.bigint "preceding_visit_occurrence_id"
  end

  create_table "vocabulary", id: false, force: :cascade do |t|
    t.string "vocabulary_id", limit: 20, null: false
    t.string "vocabulary_name", limit: 255, null: false
    t.string "vocabulary_reference", limit: 255
    t.string "vocabulary_version", limit: 255
    t.bigint "vocabulary_concept_id", null: false
  end

end
