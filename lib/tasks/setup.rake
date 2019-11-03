# initial setup
# bundle exec rake db:migrate
# bundle exec rake data:load_omop_vocabulary_tables
# bundle exec rake data:compile_omop_vocabulary_indexes
# bundle exec rake setup:data
# bundle exec rake data:compile_omop_indexes
# bundle exec rake data:compile_omop_constraints
# bundle exec rake abstractor:setup:system
# bundle exec rake setup:schemas
# bundle exec rake suggestor:do

#cleanup
# bundle exec rake setup:truncate_schemas
# bundle exec rake data:truncate_omop_clinical_data_tables
# bundle exec rake setup:schemas
# bundle exec rake setup:data
# bundle exec rake suggestor:do
require './lib/omop_abstractor/setup/setup'
namespace :setup do
  desc 'Load schemas'
  task(schemas: :environment) do |t, args|
    date_object_type = Abstractor::AbstractorObjectType.where(value: 'date').first
    list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
    boolean_object_type = Abstractor::AbstractorObjectType.where(value: 'boolean').first
    string_object_type = Abstractor::AbstractorObjectType.where(value: 'string').first
    number_object_type = Abstractor::AbstractorObjectType.where(value: 'number').first
    radio_button_list_object_type = Abstractor::AbstractorObjectType.where(value: 'radio button list').first
    dynamic_list_object_type = Abstractor::AbstractorObjectType.where(value: 'dynamic list').first
    name_value_rule = Abstractor::AbstractorRuleType.where(name: 'name/value').first
    value_rule = Abstractor::AbstractorRuleType.where(name: 'value').first
    unknown_rule = Abstractor::AbstractorRuleType.where(name: 'unknown').first
    source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
    source_type_custom_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'custom nlp suggestion').first
    indirect_source_type = Abstractor::AbstractorAbstractionSourceType.where(name: 'indirect').first

    #surgical pathology report abstractions setup begin
    #concept_id 10  = 'Procedure Occurrence'
    #concept_id 5085 = 'Note'
    #concept_id 44818790 = 'Has procedure context (SNOMED)'
    #concept_id 4213297 = 'Surgical pathology procedure'
    abstractor_namespace_surgical_pathology = Abstractor::AbstractorNamespace.where(name: 'Surgical Pathology', subject_type: NoteStableIdentifier.to_s, joins_clause:
    "JOIN note ON note_stable_identifier.note_id = note.note_id
     JOIN fact_relationship ON fact_relationship.domain_concept_id_1 = 5085 AND fact_relationship.fact_id_1 = note.note_id AND fact_relationship.relationship_concept_id = 44818790
     JOIN procedure_occurrence ON fact_relationship.domain_concept_id_2 = 10 AND fact_relationship.fact_id_2 = procedure_occurrence.procedure_occurrence_id AND procedure_occurrence.procedure_concept_id = 4213297",
    where_clause: "note.note_title in('Final Diagnosis', 'Final Pathologic Diagnosis') AND note_date >='2018-03-01'").first_or_create
    # where_clause: "note.note_title = 'Final Diagnosis'").first_or_create

    #Begin primary cancer
    primary_cancer_group = Abstractor::AbstractorSubjectGroup.where(name: 'Primary Cancer', enable_workflow_status: false).first_or_create
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_histology',
      display_name: 'Histology',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer histology').first_or_create

    primary_cns_histologies = CSV.new(File.open('lib/setup/data/primary_cns_diagnoses.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")

    primary_cns_histologies.each do |histology|
      name = histology['name'].downcase.gsub(', nos', '').strip
      if histology['icdo3_code'].present?
        abstractor_object_value = Abstractor::AbstractorObjectValue.where(:value => "#{name} (#{histology['icdo3_code']})".downcase, vocabulary_code: histology['icdo3_code'], vocabulary: 'ICD-O-3', vocabulary_version: 'ICD-O-3').first_or_create
      else
        abstractor_object_value = Abstractor::AbstractorObjectValue.where(:value => "#{name}", vocabulary_code: "#{name}".downcase).first_or_create
      end

      Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
      Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => histology['name'].downcase).first_or_create

      normalized_values = OmopAbstractor::Setup.normalize(name.downcase)
      normalized_values.each do |normalized_value|
        if !OmopAbstractor::Setup.object_value_exists?(abstractor_abstraction_schema, normalized_value)
          Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => normalized_value.downcase).first_or_create
        end
      end

      histology_synonyms = CSV.new(File.open('lib/setup/data/primary_cns_diagnosis_synonyms.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
      histology_synonyms = histology_synonyms.select { |histology_synonym| histology_synonym['diagnosis_id'] == histology['id'] }
      histology_synonyms.each do |histology_synonym|
        Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => histology_synonym['name'].downcase).first_or_create
      end
    end

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 1).first_or_create

    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_site',
      display_name: 'Site',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer site').first_or_create

    sites = CSV.new(File.open('lib/setup/data/icdo3_sites.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    primary_cns_sites = CSV.new(File.open('lib/setup/data/site_site_categories.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    primary_cns_sites = primary_cns_sites.map { |primary_cns_site| primary_cns_site['icdo3_code'] }
    sites = sites.select { |site| primary_cns_sites.include?(site['icdo3_code']) }
    sites.each do |site|
      abstractor_object_value = Abstractor::AbstractorObjectValue.where(:value => "#{site.to_hash['name']} (#{site.to_hash['icdo3_code']})".downcase, vocabulary_code: site.to_hash['icdo3_code'], vocabulary: 'ICD-O-3', vocabulary_version: '2011 Updates to ICD-O-3').first_or_create
      Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
      Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => site.to_hash['name'].downcase).first_or_create
      site_synonyms = CSV.new(File.open('lib/setup/data/icdo3_site_synonyms.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
      site_synonyms.select { |site_synonym| site.to_hash['icdo3_code'] == site_synonym.to_hash['icdo3_code'] }.each do |site_synonym|
        Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => site_synonym.to_hash['synonym_name'].downcase).first_or_create
      end
    end

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 2).first_or_create

    #Begin Laterality
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_site_laterality',
      display_name: 'Laterality',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'laterality').first_or_create
    lateralites = ['bilateral', 'left', 'right']
    lateralites.each do |laterality|
      abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: laterality, vocabulary_code: laterality).first_or_create
      Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    end

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 3).first_or_create

    #End Laterality

    #Begin WHO Grade
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_who_grade',
      display_name: 'WHO Grade',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'grade').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'Grade 1', vocabulary_code: 'Grade 1').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'Grade I').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'Grade 2', vocabulary_code: 'Grade 2').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'Grade II').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'Grade 3', vocabulary_code: 'Grade 3').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'Grade III').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'Grade 4', vocabulary_code: 'Grade 4').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'Grade IV').first_or_create


    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 4).first_or_create

    #End WHO Grade

    #Begin recurrent
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_recurrence_status',
      display_name: 'Recurrent',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'recurrent').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'initial', vocabulary_code: 'initial').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'recurrent', vocabulary_code: 'recurrent').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'residual').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'recurrence').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 4).first_or_create

    #End recurrent

    #End primary cancer
    #Begin metastatic
    metastatic_cancer_group = Abstractor::AbstractorSubjectGroup.where(name: 'Metastatic Cancer', enable_workflow_status: false).first_or_create
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_metastatic_cancer_histology',
      display_name: 'Histology',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer histology').first_or_create

    metastatic_histologies = CSV.new(File.open('lib/setup/data/metastatic_diagnoses.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")

    metastatic_histologies.each do |histology|
      name = histology['name'].downcase.gsub(', nos', '').strip
      if histology['icdo3_code'].present?
        abstractor_object_value = Abstractor::AbstractorObjectValue.where(:value => "#{name} (#{histology['icdo3_code']})".downcase, vocabulary_code: histology['icdo3_code'], vocabulary: 'ICD-O-3', vocabulary_version: 'ICD-O-3').first_or_create
      else
        abstractor_object_value = Abstractor::AbstractorObjectValue.where(:value => "#{name}", vocabulary_code: "#{name}".downcase).first_or_create
      end

      Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
      Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => histology['name'].downcase).first_or_create

      normalized_values = OmopAbstractor::Setup.normalize(name.downcase)
      normalized_values.each do |normalized_value|
        if !OmopAbstractor::Setup.object_value_exists?(abstractor_abstraction_schema, normalized_value)
          Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => normalized_value.downcase).first_or_create
        end
      end

      histology_synonyms = CSV.new(File.open('lib/setup/data/primary_cns_diagnosis_synonyms.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
      histology_synonyms = histology_synonyms.select { |histology_synonym| histology_synonym['diagnosis_id'] == histology['id'] }
      histology_synonyms.each do |histology_synonym|
        Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => histology_synonym['name'].downcase).first_or_create
      end
    end

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 2).first_or_create

    #Begin metastatic cancer site
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_metastatic_cancer_site',
      display_name: 'Site',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer site').first_or_create

    sites = CSV.new(File.open('lib/setup/data/icdo3_sites.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    primary_cns_sites = CSV.new(File.open('lib/setup/data/site_site_categories.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    primary_cns_sites = primary_cns_sites.map { |primary_cns_site| primary_cns_site['icdo3_code'] }
    sites = sites.select { |site| primary_cns_sites.include?(site['icdo3_code']) }
    sites.each do |site|
      abstractor_object_value = Abstractor::AbstractorObjectValue.where(:value => "#{site.to_hash['name']} (#{site.to_hash['icdo3_code']})".downcase, vocabulary_code: site.to_hash['icdo3_code'], vocabulary: 'ICD-O-3', vocabulary_version: '2011 Updates to ICD-O-3').first_or_create
      Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
      Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => site.to_hash['name'].downcase).first_or_create
      site_synonyms = CSV.new(File.open('lib/setup/data/icdo3_site_synonyms.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
      site_synonyms.select { |site_synonym| site.to_hash['icdo3_code'] == site_synonym.to_hash['icdo3_code'] }.each do |site_synonym|
        Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => site_synonym.to_hash['synonym_name'].downcase).first_or_create
      end
    end

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 2).first_or_create

    #End metastatic cancer site

    #Begin metastatic cancer primary site
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_metastatic_cancer_primary_site',
      display_name: 'Primary Site',
      abstractor_object_type: list_object_type,
      preferred_name: 'primary cancer site').first_or_create

    sites = CSV.new(File.open('lib/setup/data/icdo3_sites.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    primary_cns_sites = CSV.new(File.open('lib/setup/data/site_site_categories.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    primary_cns_sites = primary_cns_sites.map { |primary_cns_site| primary_cns_site['icdo3_code'] }
    sites = sites.select { |site| !primary_cns_sites.include?(site['icdo3_code']) }
    sites.each do |site|
      abstractor_object_value = Abstractor::AbstractorObjectValue.where(:value => "#{site.to_hash['name']} (#{site.to_hash['icdo3_code']})".downcase, vocabulary_code: site.to_hash['icdo3_code'], vocabulary: 'ICD-O-3', vocabulary_version: '2011 Updates to ICD-O-3').first_or_create
      Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
      Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => site.to_hash['name'].downcase).first_or_create
      site_synonyms = CSV.new(File.open('lib/setup/data/icdo3_site_synonyms.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
      site_synonyms.select { |site_synonym| site.to_hash['icdo3_code'] == site_synonym.to_hash['icdo3_code'] }.each do |site_synonym|
        Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => site_synonym.to_hash['synonym_name'].downcase).first_or_create
      end
    end

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 2).first_or_create

    #End metastatic cancer primary site

    #Begin Laterality
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_metastatic_cancer_site_laterality',
      display_name: 'Laterality',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'laterality').first_or_create
    lateralites = ['bilateral', 'left', 'right']
    lateralites.each do |laterality|
      abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: laterality, vocabulary_code: laterality).first_or_create
      Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    end

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 3).first_or_create

    #End Laterality

    #Begin recurrent
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_metastatic_cancer_recurrence_status',
      display_name: 'Recurrent',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'recurrent').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'initial', vocabulary_code: 'initial').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'recurrent', vocabulary_code: 'recurrent').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'residual').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'recurrence').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 4).first_or_create

    #End recurrent

    #End metastatic

    #Begin IDH1 status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_idh1_status',
      display_name: 'IDH1 Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'idh1').first_or_create

    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'idh-1')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'idh 1')

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'positive', vocabulary_code: 'positive').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'yes').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'pos.').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'affirmative').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'negative', vocabulary_code: 'negative').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'no').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'neg.').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create

    #End IDH1 status

    #Begin IDH2 status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_idh2_status',
      display_name: 'IDH2 Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'idh2').first_or_create

    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'idh-2')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'idh 2')

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'positive', vocabulary_code: 'positive').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'yes').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'pos.').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'affirmative').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'negative', vocabulary_code: 'negative').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'no').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'neg.').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End IDH2 status

    #Begin 1p status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_1p_status',
      display_name: '1P Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: '1P').first_or_create

    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'OneP')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: '1-P')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: '1P19Q')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: '1P-19Q')

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'deleted', vocabulary_code: 'deleted').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'del.').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'non-deleted', vocabulary_code: 'non-deleted').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'nondeleted').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'not deleted').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End 1p status

    #Begin 19q status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_19q_status',
      display_name: '19q Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: '19Q').first_or_create

    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'NineteenQ')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: '19-Q')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: '1P19Q')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: '1P-19Q')

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'deleted', vocabulary_code: 'deleted').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'del.').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'non-deleted', vocabulary_code: 'non-deleted').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'nondeleted').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'not deleted').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End 19q status

    #Begin 10q/PTEN status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_10q_PTEN_status',
      display_name: '10q/PTEN Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: '10q/PTEN').first_or_create

    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: '10qPTEN')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: '10q-PTEN')

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'deleted', vocabulary_code: 'deleted').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'del.').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'non-deleted', vocabulary_code: 'non-deleted').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'nondeleted').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'not deleted').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End 10q/PTEN status

    #Begin MGMT promoter methylation status Status status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_mgmt_status',
      display_name: 'MGMT promoter methylation status Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'MGMT').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'positive', vocabulary_code: 'positive').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'yes').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'pos.').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'affirmative').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'negative', vocabulary_code: 'negative').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'no').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'neg.').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End MGMT promoter methylation status Status

    #Begin ki67
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_ki67',
      display_name: 'ki67',
      abstractor_object_type: number_object_type,
      preferred_name: 'ki67').first_or_create

    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'ki-67')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'mib-1')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'mib1')

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End ki67

    #Begin p53
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_p53',
      display_name: 'p53',
      abstractor_object_type: number_object_type,
      preferred_name: 'p53').first_or_create

    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'p-53')

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End p53

    #surgical pathology report abstractions setup end

    #outside surgical pathology report abstractions setup begin
    #surgical pathology report abstractions setup begin
    #concept_id 10  = 'Procedure Occurrence'
    #concept_id 5085 = 'Note'
    #concept_id 44818790 = 'Has procedure context (SNOMED)'
    #concept_id 4244107 = 'Surgical pathology consultation and report on referred slides prepared elsewhere'
    abstractor_namespace_outside_surgical_pathology = Abstractor::AbstractorNamespace.where(name: 'Outside Surgical Pathology', subject_type: NoteStableIdentifier.to_s, joins_clause:
    "JOIN note ON note_stable_identifier.note_id = note.note_id
     JOIN fact_relationship ON fact_relationship.domain_concept_id_1 = 5085 AND fact_relationship.fact_id_1 = note.note_id AND fact_relationship.relationship_concept_id = 44818790
     JOIN procedure_occurrence ON fact_relationship.domain_concept_id_2 = 10 AND fact_relationship.fact_id_2 = procedure_occurrence.procedure_occurrence_id AND procedure_occurrence.procedure_concept_id = 4244107",
    # where_clause: "note.note_title = 'Final Diagnosis'").first_or_create
    where_clause: "note.note_title IN('Final Diagnosis', 'Final Pathologic Diagnosis') AND note_date >='2018-03-01'").first_or_create

    #Begin primary cancer
    primary_cancer_group = Abstractor::AbstractorSubjectGroup.where(name: 'Primary Cancer', enable_workflow_status: false).first_or_create
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_histology',
      display_name: 'Histology',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer histology').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 1).first_or_create

    #End primary cancer
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_site',
      display_name: 'Site',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer site').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 2).first_or_create

    #Begin Laterality
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_site_laterality',
      display_name: 'Laterality',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'laterality').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 3).first_or_create

    #End Laterality

    #Begin surgery date
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_surgery_date',
      display_name: 'Surgery Date',
      abstractor_object_type: date_object_type,
      preferred_name: 'Surgery Date').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End surgery date

    #Begin WHO Grade
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_who_grade',
      display_name: 'WHO Grade',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'grade').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 4).first_or_create

    #End WHO Grade

    #Begin recurrent
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_recurrence_status',
      display_name: 'Recurrent',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'recurrent').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 4).first_or_create

    #End recurrent

    #End primary cancer
    #Begin metastatic
    metastatic_cancer_group = Abstractor::AbstractorSubjectGroup.where(name: 'Metastatic Cancer', enable_workflow_status: false).first_or_create
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_metastatic_cancer_histology',
      display_name: 'Histology',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer histology').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 2).first_or_create

    #Begin metastatic cancer site
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_metastatic_cancer_site',
      display_name: 'Site',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer site').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 2).first_or_create

    #End metastatic cancer site

    #Begin metastatic cancer primary site
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_metastatic_cancer_primary_site',
      display_name: 'Primary Site',
      abstractor_object_type: list_object_type,
      preferred_name: 'primary cancer site').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 2).first_or_create

    #End metastatic cancer primary site

    #Begin Laterality
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_metastatic_cancer_site_laterality',
      display_name: 'Laterality',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'laterality').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 3).first_or_create

    #End Laterality

    #Begin recurrent
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_metastatic_cancer_recurrence_status',
      display_name: 'Recurrent',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'recurrent').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 4).first_or_create

    #End recurrent

    #End metastatic

    #Begin IDH1 status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_idh1_status',
      display_name: 'IDH1 Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'idh1').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create

    #End IDH1 status

    #Begin IDH2 status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_idh2_status',
      display_name: 'IDH2 Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'idh2').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End IDH2 status

    #Begin 1p status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_1p_status',
      display_name: '1P Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: '1P').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End 1p status

    #Begin 19q status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_19q_status',
      display_name: '19q Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: '19Q').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End 19q status

    #Begin 10q/PTEN status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_10q_PTEN_status',
      display_name: '10q/PTEN Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: '10q/PTEN').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End 10q/PTEN status

    #Begin MGMT promoter methylation status Status status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_mgmt_status',
      display_name: 'MGMT promoter methylation status Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'MGMT').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End MGMT promoter methylation status Status

    #Begin ki67
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_ki67',
      display_name: 'ki67',
      abstractor_object_type: number_object_type,
      preferred_name: 'ki67').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End ki67

    #Begin p53
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_p53',
      display_name: 'p53',
      abstractor_object_type: number_object_type,
      preferred_name: 'p53').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
    #End p53

    #outside surgical pathology report abstractions setup end

    #molecular genetics report abstractions setup begin
    abstractor_namespace_molecular_pathology = Abstractor::AbstractorNamespace.where(name: 'Molecular Pathology', subject_type: NoteStableIdentifier.to_s, joins_clause:
    "JOIN note ON note_stable_identifier.note_id = note.note_id
     JOIN fact_relationship ON fact_relationship.domain_concept_id_1 = 5085 AND fact_relationship.fact_id_1 = note.note_id AND fact_relationship.relationship_concept_id = 44818790
     JOIN procedure_occurrence ON fact_relationship.domain_concept_id_2 = 10 AND fact_relationship.fact_id_2 = procedure_occurrence.procedure_occurrence_id AND procedure_occurrence.procedure_concept_id = 4019097",
     where_clause: "note.note_title = 'Interpretation'").first_or_create

     abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
       predicate: 'has_mgmt_status',
       display_name: 'MGMT promoter methylation status Status',
       abstractor_object_type: radio_button_list_object_type,
       preferred_name: 'MGMT').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_molecular_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
    # Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'health_heritage_casefinder_nlp_service').first_or_create
  end

  desc "Load data"
  task(data: :environment) do |t, args|
    #Person 1
    location = Location.where(location_id: 1, address_1: '123 Main Street', address_2: 'Apt, 3F', city: 'New York', state: 'NY' , zip: '10001', county: 'Manhattan').first_or_create
    person = Person.where(person_id: 1, gender_concept_id: Concept.genders.first, year_of_birth: 1971, month_of_birth: 12, day_of_birth: 10, birth_datetime: DateTime.parse('12/10/1971'), race_concept_id: Concept.races.first, ethnicity_concept_id: Concept.ethnicities.first, person_source_value: '123', location: location).first_or_create
    location = Location.where(location_id: 2, address_1: '123 Main St', address_2: '3F', city: 'Chicago', state: 'IL', zip: '60657', county: 'Cook', location_source_value: nil).first_or_create
    person.adresses.where(location: location).first_or_create
    person.emails.where(email: 'person1@ohdsi.org').first_or_create
    person.mrns.where(health_system: 'NMHC',  mrn: '111').first_or_create
    if person.name
      person.name.destroy!
    end
    person.build_name(first_name: 'Harold', middle_name: nil , last_name: 'Baines' , suffix: 'Mr' , prefix: nil)
    person.save!
    person.phone_numbers.where(phone_number: '8471111111').first_or_create

    #surgical pathology report begin
    gender_concept = Concept.genders.where(concept_name: 'MALE').first
    provider = Provider.where(provider_id: 1, provider_name: 'Craig Horbinski', npi: '1730345026', dea: nil, specialty_concept_id: nil, care_site_id: nil, year_of_birth: Date.parse('1/1/1968').year, gender_concept_id: gender_concept.concept_id, provider_source_value: nil, specialty_source_value: nil, specialty_source_concept_id: nil, gender_source_value: nil, gender_source_concept_id: nil).first_or_create
    procedure_concept = Concept.procedure_concepts.where(concept_code: '39228008').first #Surgical Pathology
    procedure_type_concept = Concept.procedure_types.where(concept_name: 'Secondary Procedure').first
    procedure_occurrence = ProcedureOccurrence.where(procedure_occurrence_id: 1, person_id: person.person_id, procedure_concept_id: procedure_concept.concept_id, procedure_date: Date.parse('1/1/2018'), procedure_datetime: Date.parse('1/1/2018'), procedure_type_concept_id: procedure_type_concept.concept_id, modifier_concept_id: nil, quantity: 1, provider_id: provider.provider_id, visit_occurrence_id: nil, procedure_source_value: nil, procedure_source_concept_id: nil, modifier_source_value: nil).first_or_create
    note_type_concept = Concept.note_types.where(concept_name: 'Pathology report').first
    note_class_concept = Concept.standard.valid.where(concept_name: 'Pathology procedure note').first
    note = Note.where(note_id: 1, person_id: person.person_id, note_date: Date.parse('1/1/2019'), note_datetime: Date.parse('1/1/2018'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Final Diagnosis', note_text: 'The patient has glioblastoma.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end

    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create

    note = Note.where(note_id: 2, person_id: person.person_id, note_date: Date.parse('1/1/2019'), note_datetime: Date.parse('1/1/2018'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Gross Description', note_text: 'Gross description of the front parietal lobe.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end

    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create

    note = Note.where(note_id: 3, person_id: person.person_id, note_date: Date.parse('1/1/2019'), note_datetime: Date.parse('1/1/2018'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Comment', note_text: 'Comment on the surgical pathology procedure.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end

    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create
    #abstract
    # note.note_stable_identifier.abstract(namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id)
    specimen_code_concept = Concept.specimen_concepts.where(concept_name: 'Brain neoplasm tissue sample').first
    specimen_type_concept = Concept.specimen_types.first
    domain_concept_specimen = Concept.domain_concepts.where(concept_name: 'Specimen').first
    relationship_has_specimen = Relationship.where(relationship_id: 'Has specimen').first
    relationship_specimen_of = Relationship.where(relationship_id: 'Specimen of').first
    specimen = Specimen.where(specimen_id: 1, person_id: person.person_id, specimen_concept_id: specimen_code_concept.concept_id, specimen_type_concept_id: specimen_type_concept.concept_id, specimen_date: Date.parse('1/1/2018'), specimen_datetime: Date.parse('1/1/2018')).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_specimen.concept_id, fact_id_2: specimen.specimen_id, relationship_concept_id: relationship_has_specimen.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_specimen.concept_id, fact_id_1: specimen.specimen_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create

    procedure_concept = Concept.procedure_concepts.where(concept_code: '61512', vocabulary_id: 'CPT4').first #PR EXCIS SUPRATENT MENINGIOMA
    procedure_type_concept = Concept.procedure_types.where(concept_name: 'Primary Procedure').first
    gender_concept = Concept.genders.where(concept_name: 'MALE').first
    provider = Provider.where(provider_id: 2, provider_name: 'James Chandler', npi: '1881656411', dea: nil, specialty_concept_id: nil, care_site_id: nil, year_of_birth: Date.parse('1/1/1968').year, gender_concept_id: gender_concept.concept_id, provider_source_value: nil, specialty_source_value: nil, specialty_source_concept_id: nil, gender_source_value: nil, gender_source_concept_id: nil).first_or_create
    surgery_procedure_occurrence = ProcedureOccurrence.where(procedure_occurrence_id: 2, person_id: person.person_id, procedure_concept_id: procedure_concept.concept_id, procedure_date: Date.parse('1/1/2018'), procedure_datetime: Date.parse('1/1/2018'), procedure_type_concept_id: procedure_type_concept.concept_id, modifier_concept_id: nil, quantity: 1, provider_id: provider.provider_id, visit_occurrence_id: nil, procedure_source_value: nil, procedure_source_concept_id: nil, modifier_source_value: nil).first_or_create
    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: surgery_procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: surgery_procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create

    #surgical pathology report end

    #outside surgical pathology report begin
    gender_concept = Concept.genders.where(concept_name: 'MALE').first
    provider = Provider.where(provider_id: 1, provider_name: 'Craig Horbinski', npi: '1730345026', dea: nil, specialty_concept_id: nil, care_site_id: nil, year_of_birth: Date.parse('1/1/1968').year, gender_concept_id: gender_concept.concept_id, provider_source_value: nil, specialty_source_value: nil, specialty_source_concept_id: nil, gender_source_value: nil, gender_source_concept_id: nil).first_or_create
    procedure_concept = Concept.where(concept_code: '59000001').first #"Surgical pathology consultation and report on referred slides prepared elsewhere"
    procedure_type_concept = Concept.procedure_types.where(concept_name: 'Secondary Procedure').first

    procedure_occurrence = ProcedureOccurrence.where(procedure_occurrence_id: 3, person_id: person.person_id, procedure_concept_id: procedure_concept.concept_id, procedure_date: Date.parse('1/1/2018'), procedure_datetime: Date.parse('1/1/2018'), procedure_type_concept_id: procedure_type_concept.concept_id, modifier_concept_id: nil, quantity: 1, provider_id: provider.provider_id, visit_occurrence_id: nil, procedure_source_value: nil, procedure_source_concept_id: nil, modifier_source_value: nil).first_or_create
    note_type_concept = Concept.note_types.where(concept_name: 'Pathology report').first
    note_class_concept = Concept.standard.valid.where(concept_name: 'Pathology procedure note').first
    note = Note.where(note_id: 4, person_id: person.person_id, note_date: Date.parse('1/1/2019'), note_datetime: Date.parse('1/1/2018'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Final Diagnosis', note_text: 'The patient has glioblastoma.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end

    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create

    note = Note.where(note_id: 5, person_id: person.person_id, note_date: Date.parse('1/1/2019'), note_datetime: Date.parse('1/1/2018'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Gross Description', note_text: 'Gross description of the front parietal lobe.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end

    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create


    note = Note.where(note_id: 6, person_id: person.person_id, note_date: Date.parse('1/1/2019'), note_datetime: Date.parse('1/1/2018'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Comment', note_text: 'Comment on the surgical pathology procedure.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end
    #outside surgical pathology report end

    #molecular genetics report begin
    gender_concept = Concept.genders.where(concept_name: 'MALE').first
    provider = Provider.where(provider_id: 1, provider_name: 'Craig Horbinski', npi: '1730345026', dea: nil, specialty_concept_id: nil, care_site_id: nil, year_of_birth: Date.parse('1/1/1968').year, gender_concept_id: gender_concept.concept_id, provider_source_value: nil, specialty_source_value: nil, specialty_source_concept_id: nil, gender_source_value: nil, gender_source_concept_id: nil).first_or_create
    procedure_concept = Concept.procedure_concepts.where(concept_code: '116148004').first  #Molecular genetics procedure
    procedure_type_concept = Concept.procedure_types.where(concept_name: 'Secondary Procedure').first
    procedure_occurrence = ProcedureOccurrence.where(procedure_occurrence_id: 4, person_id: person.person_id, procedure_concept_id: procedure_concept.concept_id, procedure_date: Date.parse('1/1/2017'), procedure_datetime: Date.parse('1/1/2017'), procedure_type_concept_id: procedure_type_concept.concept_id, modifier_concept_id: nil, quantity: 1, provider_id: provider.provider_id, visit_occurrence_id: nil, procedure_source_value: nil, procedure_source_concept_id: nil, modifier_source_value: nil).first_or_create
    note_type_concept = Concept.note_types.where(concept_name: 'Pathology report').first
    note_class_concept = Concept.standard.valid.where(concept_name: 'Pathology procedure note').first
    note = Note.where(note_id: 7, person_id: person.person_id, note_date: Date.parse('1/1/2019'), note_datetime: Date.parse('1/1/2017'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Interpretation', note_text: 'The tumor is positive for mgmt promoter methylation.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end

    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create

    note = Note.where(note_id: 8, person_id: person.person_id, note_date: Date.parse('1/1/2019'), note_datetime: Date.parse('1/1/2017'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Comment', note_text: 'Comment on the molecular genetics procedure.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end

    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create
    #abstract
    # note.note_stable_identifier.abstract(namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_molecular_pathology.id)
    #molecular genetics report end

    #Person 2
    location = Location.where(location_id: 3, address_1: '456 Main Street', address_2: 'Apt, 3F', city: 'New York', state: 'NY' , zip: '10001', county: 'Manhattan').first_or_create
    person = Person.where(person_id: 2, gender_concept_id: Concept.genders.last, year_of_birth: 1981, month_of_birth: 12, day_of_birth: 10, birth_datetime: DateTime.parse('12/10/1981'), race_concept_id: Concept.races.last, ethnicity_concept_id: Concept.ethnicities.last, person_source_value: '124', location: location).first_or_create
    location = Location.where(location_id: 4, address_1: '456 Main St', address_2: '3F', city: 'Chicago', state: 'IL', zip: '60657', county: 'Cook', location_source_value: nil).first_or_create
    person.adresses.where(location: location).first_or_create
    person.emails.where(email: 'person2@ohdsi.org').first_or_create
    person.mrns.where(health_system: 'NMHC',  mrn: '222').first_or_create
    if person.name
      person.name.destroy!
    end
    person.build_name(first_name: 'Paul', middle_name: nil , last_name: 'Konerko' , suffix: 'Mr' , prefix: nil)
    person.save!
    person.phone_numbers.where(phone_number: '8472222222').first_or_create

    #surgical pathology report begin
    gender_concept = Concept.genders.where(concept_name: 'MALE').first
    provider = Provider.where(provider_id: 1, provider_name: 'Craig Horbinski', npi: '1730345026', dea: nil, specialty_concept_id: nil, care_site_id: nil, year_of_birth: Date.parse('1/1/1968').year, gender_concept_id: gender_concept.concept_id, provider_source_value: nil, specialty_source_value: nil, specialty_source_concept_id: nil, gender_source_value: nil, gender_source_concept_id: nil).first_or_create
    procedure_concept = Concept.procedure_concepts.where(concept_code: '39228008').first
    procedure_type_concept = Concept.procedure_types.where(concept_name: 'Secondary Procedure').first
    procedure_occurrence = ProcedureOccurrence.where(procedure_occurrence_id: 5, person_id: person.person_id, procedure_concept_id: procedure_concept.concept_id, procedure_date: Date.parse('2/1/2018'), procedure_datetime: Date.parse('2/1/2018'), procedure_type_concept_id: procedure_type_concept.concept_id, modifier_concept_id: nil, quantity: 1, provider_id: provider.provider_id, visit_occurrence_id: nil, procedure_source_value: nil, procedure_source_concept_id: nil, modifier_source_value: nil).first_or_create
    note_type_concept = Concept.note_types.where(concept_name: 'Pathology report').first
    note_class_concept = Concept.standard.valid.where(concept_name: 'Pathology procedure note').first
    note = Note.where(note_id: 9, person_id: person.person_id, note_date: Date.parse('2/1/2019'), note_datetime: Date.parse('2/1/2018'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Final Diagnosis', note_text: 'The patient has adenocarcinoma of the prostate.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create


    note = Note.where(note_id: 10, person_id: person.person_id, note_date: Date.parse('2/1/2019'), note_datetime: Date.parse('2/1/2018'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Gross Description', note_text: 'Gross description of the front parietal lobe.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end

    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create


    note = Note.where(note_id: 11, person_id: person.person_id, note_date: Date.parse('2/1/2019'), note_datetime: Date.parse('2/1/2018'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Comment', note_text: 'Comment on the surgical pathology procedure.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end

    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create

    #abstract
    # note.note_stable_identifier.abstract(namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id)

    specimen_code_concept = Concept.specimen_concepts.where(concept_name:  'Specimen from brain obtained by biopsy').first
    specimen_type_concept = Concept.specimen_types.first
    domain_concept_specimen = Concept.domain_concepts.where(concept_name: 'Specimen').first
    relationship_has_specimen = Relationship.where(relationship_id: 'Has specimen').first
    relationship_specimen_of = Relationship.where(relationship_id: 'Specimen of').first
    specimen = Specimen.where(specimen_id: 2, person_id: person.person_id, specimen_concept_id: specimen_code_concept.concept_id, specimen_type_concept_id: specimen_type_concept, specimen_date: Date.parse('2/1/2018'), specimen_datetime: Date.parse('2/1/2018')).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_specimen.concept_id, fact_id_2: specimen.specimen_id, relationship_concept_id: relationship_has_specimen.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_specimen.concept_id, fact_id_1: specimen.specimen_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create

    procedure_concept = Concept.procedure_concepts.where(concept_code: '61512', vocabulary_id: 'CPT4').first #PR EXCIS SUPRATENT MENINGIOMA
    procedure_type_concept = Concept.procedure_types.where(concept_name: 'Primary Procedure').first
    gender_concept = Concept.genders.where(concept_name: 'MALE').first
    provider = Provider.where(provider_id: 2, provider_name: 'James Chandler', npi: '1881656411', dea: nil, specialty_concept_id: nil, care_site_id: nil, year_of_birth: Date.parse('1/1/1968').year, gender_concept_id: gender_concept.concept_id, provider_source_value: nil, specialty_source_value: nil, specialty_source_concept_id: nil, gender_source_value: nil, gender_source_concept_id: nil).first_or_create
    surgery_procedure_occurrence = ProcedureOccurrence.where(procedure_occurrence_id: 6, person_id: person.person_id, procedure_concept_id: procedure_concept.concept_id, procedure_date: Date.parse('2/1/2018'), procedure_datetime: Date.parse('2/1/2018'), procedure_type_concept_id: procedure_type_concept.concept_id, modifier_concept_id: nil, quantity: 1, provider_id: provider.provider_id, visit_occurrence_id: nil, procedure_source_value: nil, procedure_source_concept_id: nil, modifier_source_value: nil).first_or_create
    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: surgery_procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: surgery_procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    #surgical pathology report end

    #outside surgical pathology report begin
    gender_concept = Concept.genders.where(concept_name: 'MALE').first
    provider = Provider.where(provider_id: 1, provider_name: 'Craig Horbinski', npi: '1730345026', dea: nil, specialty_concept_id: nil, care_site_id: nil, year_of_birth: Date.parse('1/1/1968').year, gender_concept_id: gender_concept.concept_id, provider_source_value: nil, specialty_source_value: nil, specialty_source_concept_id: nil, gender_source_value: nil, gender_source_concept_id: nil).first_or_create
    procedure_concept = Concept.where(concept_code: '59000001').first
    procedure_type_concept = Concept.procedure_types.where(concept_name: 'Secondary Procedure').first
    procedure_occurrence = ProcedureOccurrence.where(procedure_occurrence_id: 7, person_id: person.person_id, procedure_concept_id: procedure_concept.concept_id, procedure_date: Date.parse('2/1/2018'), procedure_datetime: Date.parse('2/1/2018'), procedure_type_concept_id: procedure_type_concept.concept_id, modifier_concept_id: nil, quantity: 1, provider_id: provider.provider_id, visit_occurrence_id: nil, procedure_source_value: nil, procedure_source_concept_id: nil, modifier_source_value: nil).first_or_create
    note_type_concept = Concept.note_types.where(concept_name: 'Pathology report').first
    note_class_concept = Concept.standard.valid.where(concept_name: 'Pathology procedure note').first
    note = Note.where(note_id: 12, person_id: person.person_id, note_date: Date.parse('2/1/2019'), note_datetime: Date.parse('2/1/2018'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Final Diagnosis', note_text: 'The patient has adenocarcinoma of the prostate.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create

    note = Note.where(note_id: 13, person_id: person.person_id, note_date: Date.parse('2/1/2019'), note_datetime: Date.parse('2/1/2018'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Gross Description', note_text: 'Gross description of the front parietal lobe.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end

    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create

    note = Note.where(note_id: 14, person_id: person.person_id, note_date: Date.parse('2/1/2019'), note_datetime: Date.parse('2/1/2018'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Comment', note_text: 'Comment on the surgical pathology procedure.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end

    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create

    #abstract
    # note.note_stable_identifier.abstract(namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id)
    #outside surgical pathology report end

    #molecular genetics report
    gender_concept = Concept.genders.where(concept_name: 'MALE').first
    provider = Provider.where(provider_id: 1, provider_name: 'Craig Horbinski', npi: '1730345026', dea: nil, specialty_concept_id: nil, care_site_id: nil, year_of_birth: Date.parse('1/1/1968').year, gender_concept_id: gender_concept.concept_id, provider_source_value: nil, specialty_source_value: nil, specialty_source_concept_id: nil, gender_source_value: nil, gender_source_concept_id: nil).first_or_create
    procedure_concept = Concept.procedure_concepts.where(concept_code: '116148004').first  #Molecular genetics procedure
    procedure_type_concept = Concept.procedure_types.where(concept_name: 'Secondary Procedure').first
    procedure_occurrence = ProcedureOccurrence.where(procedure_occurrence_id: 8, person_id: person.person_id, procedure_concept_id: procedure_concept.concept_id, procedure_date: Date.parse('8/1/2018'), procedure_datetime: Date.parse('8/1/2018'), procedure_type_concept_id: procedure_type_concept.concept_id, modifier_concept_id: nil, quantity: 1, provider_id: provider.provider_id, visit_occurrence_id: nil, procedure_source_value: nil, procedure_source_concept_id: nil, modifier_source_value: nil).first_or_create
    note_type_concept = Concept.note_types.where(concept_name: 'Pathology report').first
    note_class_concept = Concept.standard.valid.where(concept_name: 'Pathology procedure note').first
    note = Note.where(note_id: 15, person_id: person.person_id, note_date: Date.parse('8/1/2019'), note_datetime: Date.parse('8/1/2018'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Interpretation', note_text: 'The tumor is negative for mgmt promoter methylation.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end

    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create

    note = Note.where(note_id: 16, person_id: person.person_id, note_date: Date.parse('8/1/2019'), note_datetime: Date.parse('8/1/2018'), note_type_concept_id: note_type_concept.concept_id, note_class_concept_id: note_class_concept.concept_id, note_title: 'Comment', note_text: 'Comment on the molecular genetics procedure.', encoding_concept_id: 0, language_concept_id: 0, provider_id: provider.provider_id, visit_occurrence_id: nil, note_source_value: nil).first_or_create
    if note.note_stable_identifier.blank?
      note.build_note_stable_identifier(stable_identifier_path: 'stable_identifier_path', stable_identifier_value: 'stable_identifier_value')
      note.save!
    end

    domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
    domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
    relationship_proc_context_of = Relationship.where(relationship_id: 'Proc context of').first
    relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
    FactRelationship.where(domain_concept_id_1: domain_concept_procedure.concept_id, fact_id_1: procedure_occurrence.procedure_occurrence_id, domain_concept_id_2: domain_concept_note.concept_id, fact_id_2: note.note_id, relationship_concept_id: relationship_proc_context_of.relationship_concept_id).first_or_create
    FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: note.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, fact_id_2: procedure_occurrence.procedure_occurrence_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).first_or_create

    #abstract
    # note.note_stable_identifier.abstract(namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_molecular_pathology.id
  end

  desc 'Truncate schemas'
  task(truncate_schemas: :environment) do  |t, args|
    Abstractor::AbstractorAbstraction.delete_all
    Abstractor::AbstractorSuggestion.delete_all
    Abstractor::AbstractorSuggestionSource.delete_all
    Abstractor::AbstractorNamespaceEvent.delete_all
    Abstractor::AbstractorNamespace.delete_all
    Abstractor::AbstractorSubjectGroup.delete_all
    Abstractor::AbstractorAbstractionSchema.delete_all
    Abstractor::AbstractorObjectValue.delete_all
    Abstractor::AbstractorAbstractionSchemaObjectValue.delete_all
    Abstractor::AbstractorObjectValueVariant.delete_all
    Abstractor::AbstractorSubject.delete_all
    Abstractor::AbstractorAbstractionSource.delete_all
    Abstractor::AbstractorSubjectGroupMember.delete_all
  end
end