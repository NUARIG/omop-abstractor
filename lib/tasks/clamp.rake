require './lib/omop_abstractor/setup/setup'
require './lib/clamp_mapper/parser'
require './lib/clamp_mapper/process_note'
namespace :clamp do
  desc "Determine new stable identifier values"
  task(determine_new_stable_identifier_values: :environment) do |t, args|
    stable_identifier_values = CSV.new(File.open('lib/setup/data/stable_identifier_values.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    stable_identifier_values = stable_identifier_values.map { |stable_identifier_value| stable_identifier_value['stable_identifier_value'] }

    stable_identifier_values_new = CSV.new(File.open('lib/setup/data/stable_identifier_values_new.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    stable_identifier_values_new = stable_identifier_values_new.map { |stable_identifier_value| stable_identifier_value['stable_identifier_value'] }
    stable_identifier_values_delta = stable_identifier_values_new - stable_identifier_values

    headers = ['stable_identifier_value']
    row_header = CSV::Row.new(headers, headers, true)
    row_template = CSV::Row.new(headers, [], false)

    CSV.open('lib/setup/data_out/stable_identifier_value_delta.csv', "wb") do |csv|
      csv << row_header
      stable_identifier_values_delta.each do |stable_identifier_value_delta|
        row = row_template.dup
        row['stable_identifier_value'] = stable_identifier_value_delta
        csv << row
      end
    end
  end

  desc 'Load schemas CLAMP'
  task(schemas_clamp: :environment) do |t, args|
    date_object_type = Abstractor::AbstractorObjectType.where(value: 'date').first
    list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
    boolean_object_type = Abstractor::AbstractorObjectType.where(value: 'boolean').first
    string_object_type = Abstractor::AbstractorObjectType.where(value: 'string').first
    number_object_type = Abstractor::AbstractorObjectType.where(value: 'number').first
    radio_button_list_object_type = Abstractor::AbstractorObjectType.where(value: 'radio button list').first
    dynamic_list_object_type = Abstractor::AbstractorObjectType.where(value: 'dynamic list').first
    text_object_type = Abstractor::AbstractorObjectType.where(value: 'text').first
    name_value_rule = Abstractor::AbstractorRuleType.where(name: 'name/value').first
    value_rule = Abstractor::AbstractorRuleType.where(name: 'value').first
    unknown_rule = Abstractor::AbstractorRuleType.where(name: 'unknown').first
    source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
    source_type_custom_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'custom nlp suggestion').first
    indirect_source_type = Abstractor::AbstractorAbstractionSourceType.where(name: 'indirect').first
    abstractor_section_type_offsets = Abstractor::AbstractorSectionType.where(name: Abstractor::Enum::ABSTRACTOR_SECTION_TYPE_OFFSETS).first
    abstractor_section_mention_type_alphabetic = Abstractor::AbstractorSectionMentionType.where(name: Abstractor::Enum::ABSTRACTOR_SECTION_MENTION_TYPE_ALPHABETIC).first
    abstractor_section_mention_type_token = Abstractor::AbstractorSectionMentionType.where(name: Abstractor::Enum::ABSTRACTOR_SECTION_MENTION_TYPE_TOKEN).first
    abstractor_section_specimen = Abstractor::AbstractorSection.where(abstractor_section_type: abstractor_section_type_offsets, name: 'SPECIMEN', source_type: NoteStableIdentifier.to_s, source_method: 'note_text', return_note_on_empty_section: true, abstractor_section_mention_type: abstractor_section_mention_type_alphabetic).first_or_create
    abstractor_section_comment = Abstractor::AbstractorSection.where(abstractor_section_type: abstractor_section_type_offsets, name: 'COMMENT', source_type: NoteStableIdentifier.to_s, source_method: 'note_text', return_note_on_empty_section: true, abstractor_section_mention_type: abstractor_section_mention_type_token).first_or_create
    abstractor_section_comment.abstractor_section_name_variants.build(name: 'Comment')
    abstractor_section_comment.abstractor_section_name_variants.build(name: 'Comments')
    abstractor_section_comment.abstractor_section_name_variants.build(name: 'Note')
    abstractor_section_comment.abstractor_section_name_variants.build(name: 'Notes')
    abstractor_section_comment.abstractor_section_name_variants.build(name: 'Additional comment')
    abstractor_section_comment.abstractor_section_name_variants.build(name: 'Additional comments')
    abstractor_section_comment.save!

    abstractor_namespace_surgical_pathology = Abstractor::AbstractorNamespace.where(name: 'Surgical Pathology', subject_type: NoteStableIdentifier.to_s, joins_clause:
    "JOIN note_stable_identifier_full ON note_stable_identifier.stable_identifier_path = note_stable_identifier_full.stable_identifier_path AND note_stable_identifier.stable_identifier_value = note_stable_identifier_full.stable_identifier_value
     JOIN note ON note_stable_identifier_full.note_id = note.note_id
     JOIN fact_relationship ON fact_relationship.domain_concept_id_1 = 5085 AND fact_relationship.fact_id_1 = note.note_id AND fact_relationship.relationship_concept_id = 44818790
     JOIN procedure_occurrence ON fact_relationship.domain_concept_id_2 = 10 AND fact_relationship.fact_id_2 = procedure_occurrence.procedure_occurrence_id AND procedure_occurrence.procedure_concept_id = 4213297",
    where_clause: "note.note_title in('Final Diagnosis', 'Final Pathologic Diagnosis') AND note_date >='2018-03-01'").first_or_create

    abstractor_namespace_surgical_pathology.abstractor_namespace_sections.build(abstractor_section: abstractor_section_specimen)
    abstractor_namespace_surgical_pathology.abstractor_namespace_sections.build(abstractor_section: abstractor_section_comment)
    abstractor_namespace_surgical_pathology.save!

    #Begin primary cancer
    primary_cancer_group = Abstractor::AbstractorSubjectGroup.where(name: 'Primary Cancer', enable_workflow_status: false).first_or_create
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_histology',
      display_name: 'Histology',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer histology').first_or_create

    # primary_cns_histologies = CSV.new(File.open('lib/setup/data/primary_cns_diagnoses.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
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

      # histology_synonyms = CSV.new(File.open('lib/setup/data/primary_cns_diagnosis_synonyms.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
      histology_synonyms = CSV.new(File.open('lib/setup/data/primary_cns_diagnosis_synonyms.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
      histology_synonyms = histology_synonyms.select { |histology_synonym| histology_synonym['diagnosis_id'] == histology['id'] }
      histology_synonyms.each do |histology_synonym|
        normalized_values = OmopAbstractor::Setup.normalize(histology_synonym['name'].downcase)
        normalized_values.each do |normalized_value|
          Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => normalized_value.downcase).first_or_create
        end
      end

      # histology_synonyms = CSV.new(File.open('lib/setup/data/icdo3_diagnosis_synonyms.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
      # histology_synonyms = histology_synonyms.select { |histology_synonym| histology_synonym['icdo3_code'] == histology['icdo3_code'] }
      # histology_synonyms.each do |histology_synonym|
      #   normalized_values = OmopAbstractor::Setup.normalize(histology_synonym['synonym_name'].downcase)
      #   normalized_values.each do |normalized_value|
      #     Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => normalized_value.downcase).first_or_create
      #   end
      # end
    end

    abstractor_object_value = abstractor_abstraction_schema.abstractor_object_values.where(vocabulary_code: '8000/3').first
    abstractor_object_value.favor_more_specific = true
    abstractor_object_value.save!

    abstractor_object_value = abstractor_abstraction_schema.abstractor_object_values.where(value: 'glioma').first
    abstractor_object_value.favor_more_specific = true
    abstractor_object_value.save!

    primary_cns_histologies = CSV.new(File.open('lib/setup/data/cap_ecc_primary_cns_histologies.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")

    primary_cns_histologies.each do |histology|
      icdo3_code = histology['icdo3_code']
      icdo3_code.insert(4,'/')
      name = histology['name'].gsub(icdo3_code, '').strip
      name = name.downcase.gsub(', nos', '').strip
      abstractor_object_value =  Abstractor::AbstractorObjectValue.where(value: "#{name} (#{icdo3_code})", vocabulary_code: icdo3_code).first
      if abstractor_object_value.blank?
        abstractor_object_value = Abstractor::AbstractorObjectValue.where(:value => "#{name} (#{icdo3_code})".downcase, vocabulary_code: icdo3_code, vocabulary: 'ICD-O-3', vocabulary_version: 'ICD-O-3').first_or_create
        Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
        Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => name.downcase).first_or_create
      else
        Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => name.downcase).first_or_create
      end

      normalized_values = OmopAbstractor::Setup.normalize(name)
      normalized_values.each do |normalized_value|
        if !OmopAbstractor::Setup.object_value_exists?(abstractor_abstraction_schema, normalized_value)
          Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => normalized_value.downcase).first_or_create
        end
      end
    end

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id, anchor: true).first_or_create
    abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp', section_required: true).first_or_create
    Abstractor::AbstractorAbstractionSourceSection.where( abstractor_abstraction_source: abstractor_abstraction_source, abstractor_section: abstractor_section_specimen).first_or_create
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

      normalized_values = OmopAbstractor::Setup.normalize(site.to_hash['name'].downcase)
      normalized_values.each do |normalized_value|
        if !OmopAbstractor::Setup.object_value_exists?(abstractor_abstraction_schema, normalized_value)
          Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => normalized_value.downcase).first_or_create
        end
      end

      site_synonyms = CSV.new(File.open('lib/setup/data/icdo3_site_synonyms.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
      site_synonyms.select { |site_synonym| site.to_hash['icdo3_code'] == site_synonym.to_hash['icdo3_code'] }.each do |site_synonym|
        normalized_values = OmopAbstractor::Setup.normalize(site_synonym.to_hash['synonym_name'].downcase)
        normalized_values.each do |normalized_value|
          Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => normalized_value.downcase).first_or_create
        end
      end
    end

    abstractor_object_value = abstractor_abstraction_schema.abstractor_object_values.where(vocabulary_code: 'C71.9').first
    abstractor_object_value.favor_more_specific = true
    abstractor_object_value.save!

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id, anchor: false).first_or_create
    abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp', section_required: true).first_or_create
    Abstractor::AbstractorAbstractionSourceSection.where( abstractor_abstraction_source: abstractor_abstraction_source, abstractor_section: abstractor_section_specimen).first_or_create
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

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id, anchor: false).first_or_create
    abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp', section_required: true).first_or_create
    Abstractor::AbstractorAbstractionSourceSection.where( abstractor_abstraction_source: abstractor_abstraction_source, abstractor_section: abstractor_section_specimen).first_or_create
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


    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id, anchor: false).first_or_create
    abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp', section_required: true).first_or_create
    Abstractor::AbstractorAbstractionSourceSection.where( abstractor_abstraction_source: abstractor_abstraction_source, abstractor_section: abstractor_section_specimen).first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 4).first_or_create

    #End WHO Grade

    #Begin recurrent
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_recurrence_status',
      display_name: 'Recurrent',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'recurrent').first_or_create

    abstractor_object_value_initial = Abstractor::AbstractorObjectValue.where(value: 'initial', vocabulary_code: 'initial').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value_initial).first_or_create

    abstractor_object_value_recurrent = Abstractor::AbstractorObjectValue.where(value: 'recurrent', vocabulary_code: 'recurrent').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value_recurrent).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value_recurrent, value: 'residual').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value_recurrent, value: 'recurrence').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id, anchor: false, default_abstractor_object_value_id: abstractor_object_value_initial.id).first_or_create
    abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp', section_required: true).first_or_create
    Abstractor::AbstractorAbstractionSourceSection.where(abstractor_abstraction_source: abstractor_abstraction_source, abstractor_section: abstractor_section_specimen).first_or_create
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

      histology_synonyms = CSV.new(File.open('lib/setup/data/metastatic_diagnosis_synonyms.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
      histology_synonyms = histology_synonyms.select { |histology_synonym| histology_synonym['diagnosis_id'] == histology['id'] }
      histology_synonyms.each do |histology_synonym|
        normalized_values = OmopAbstractor::Setup.normalize(histology_synonym['name'].downcase)
        normalized_values.each do |normalized_value|
          Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => normalized_value.downcase).first_or_create
        end
      end
    end

    abstractor_object_value = abstractor_abstraction_schema.abstractor_object_values.where(vocabulary_code: '8000/6').first
    abstractor_object_value.favor_more_specific = true
    abstractor_object_value.save!

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id, anchor: true).first_or_create
    abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp', section_required: true).first_or_create
    Abstractor::AbstractorAbstractionSourceSection.where(abstractor_abstraction_source: abstractor_abstraction_source, abstractor_section: abstractor_section_specimen).first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 1).first_or_create

    #Begin metastatic cancer site
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_site',
      display_name: 'Site',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer site').first_or_create

    #keep as create, not first_or_create
    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id, anchor: false).create
    abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp', section_required: true).first_or_create
    Abstractor::AbstractorAbstractionSourceSection.where(abstractor_abstraction_source: abstractor_abstraction_source, abstractor_section: abstractor_section_specimen).first_or_create
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
    sites = sites.reject { |site| primary_cns_sites.include?(site['icdo3_code']) || site['icdo3_code'] == 'C71' }
    sites.each do |site|
      abstractor_object_value = Abstractor::AbstractorObjectValue.where(:value => "#{site.to_hash['name']} (#{site.to_hash['icdo3_code']})".downcase, vocabulary_code: site.to_hash['icdo3_code'], vocabulary: 'ICD-O-3', vocabulary_version: '2011 Updates to ICD-O-3').first_or_create
      Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
      Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => site.to_hash['name'].downcase).first_or_create


      normalized_values = OmopAbstractor::Setup.normalize(site.to_hash['name'].downcase)
      normalized_values.each do |normalized_value|
        if !OmopAbstractor::Setup.object_value_exists?(abstractor_abstraction_schema, normalized_value)
          Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => normalized_value.downcase).first_or_create
        end
      end

      site_synonyms = CSV.new(File.open('lib/setup/data/icdo3_site_synonyms.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
      site_synonyms.select { |site_synonym| site.to_hash['icdo3_code'] == site_synonym.to_hash['icdo3_code'] }.each do |site_synonym|
        normalized_values = OmopAbstractor::Setup.normalize(site_synonym.to_hash['synonym_name'].downcase)
        normalized_values.each do |normalized_value|
          Abstractor::AbstractorObjectValueVariant.where(:abstractor_object_value => abstractor_object_value, :value => normalized_value.downcase).first_or_create
        end
      end
    end

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id, anchor: false).first_or_create
    abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp', section_required: true).first_or_create
    Abstractor::AbstractorAbstractionSourceSection.where(abstractor_abstraction_source: abstractor_abstraction_source, abstractor_section: abstractor_section_specimen).first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 3).first_or_create

    #End metastatic cancer primary site

    #Begin Laterality
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_site_laterality',
      display_name: 'Laterality',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'laterality').first_or_create

    #keep as create, not first_or_create
    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id, anchor: false).create
    abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp', section_required: true).first_or_create
    Abstractor::AbstractorAbstractionSourceSection.where(abstractor_abstraction_source: abstractor_abstraction_source, abstractor_section: abstractor_section_specimen).first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 4).first_or_create

    #End Laterality

    #Begin recurrent
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_recurrence_status',
      display_name: 'Recurrent',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'recurrent').first_or_create

    #keep as create, not first_or_create
    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id, anchor: false, default_abstractor_object_value_id: abstractor_object_value_initial.id).create
    abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp', section_required: true).first_or_create
    Abstractor::AbstractorAbstractionSourceSection.where(abstractor_abstraction_source: abstractor_abstraction_source, abstractor_section: abstractor_section_specimen).first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 5).first_or_create

    #End recurrent

    #End metastatic

    #Begin IDH1 status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_idh1_status',
      display_name: 'IDH1 Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'idh1').first_or_create

    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'idh-1').first_or_create
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'idh 1').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'positive', vocabulary_code: 'positive').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'yes').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'pos.').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'affirmative').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'mutated').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'mutant').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'idh-mutant').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'idh mutant').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'idh-mutated').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'idh mutated').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'negative', vocabulary_code: 'negative').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'no').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'neg.').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'wild-type.').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'wild type.').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'wildtype.').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create

    #End IDH1 status

    #Begin IDH2 status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_idh2_status',
      display_name: 'IDH2 Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'idh2').first_or_create

    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'idh-2').first_or_create
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'idh 2').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'positive', vocabulary_code: 'positive').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'yes').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'pos.').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'affirmative').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'mutated').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'mutant').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'idh-mutant').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'idh mutant').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'idh-mutated').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'idh mutated').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'negative', vocabulary_code: 'negative').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'no').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'neg.').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'wild-type.').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'wild type.').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'wildtype.').first_or_create


    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create

    #End IDH2 status

    #Begin 1p status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_1p_status',
      display_name: '1P Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: '1P').first_or_create

    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'OneP').first_or_create
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: '1-P').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'deleted', vocabulary_code: 'deleted').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'del.').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'non-deleted', vocabulary_code: 'non-deleted').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'nondeleted').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'not deleted').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    #End 1p status

    #Begin 19q status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_19q_status',
      display_name: '19q Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: '19Q').first_or_create

    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'NineteenQ').first_or_create
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: '19-Q').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'deleted', vocabulary_code: 'deleted').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'del.').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'non-deleted', vocabulary_code: 'non-deleted').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'nondeleted').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'not deleted').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    #End 19q status

    #Begin 10q/PTEN status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_10q_PTEN_status',
      display_name: '10q/PTEN Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: '10q/PTEN').first_or_create

    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'TenqPTEN').first_or_create
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: '10qPTEN').first_or_create
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: '10q-PTEN').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'deleted', vocabulary_code: 'deleted').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'del.').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'non-deleted', vocabulary_code: 'non-deleted').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'nondeleted').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'not deleted').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
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
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'mutated').first_or_create

    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'negative', vocabulary_code: 'negative').first_or_create
    Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value).first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'no').first_or_create
    Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: 'neg.').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    #End MGMT promoter methylation status Status

    #Begin ki67
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_ki67',
      display_name: 'ki67',
      abstractor_object_type: number_object_type,
      preferred_name: 'ki67').first_or_create

    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'ki-67').first_or_create
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'mib-1').first_or_create
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'mib1').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    #End ki67

    #Begin p53
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_p53',
      display_name: 'p53',
      abstractor_object_type: number_object_type,
      preferred_name: 'p53').first_or_create

    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'p-53').first_or_create
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.where(abstractor_abstraction_schema: abstractor_abstraction_schema, value: 'p 53').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    #End p53

    abstractor_namespace_outside_surgical_pathology = Abstractor::AbstractorNamespace.where(name: 'Outside Surgical Pathology', subject_type: NoteStableIdentifier.to_s, joins_clause:
    "JOIN note_stable_identifier_full ON note_stable_identifier.stable_identifier_path = note_stable_identifier_full.stable_identifier_path AND note_stable_identifier.stable_identifier_value = note_stable_identifier_full.stable_identifier_value
     JOIN note ON note_stable_identifier_full.note_id = note.note_id
     JOIN fact_relationship ON fact_relationship.domain_concept_id_1 = 5085 AND fact_relationship.fact_id_1 = note.note_id AND fact_relationship.relationship_concept_id = 44818790
     JOIN procedure_occurrence ON fact_relationship.domain_concept_id_2 = 10 AND fact_relationship.fact_id_2 = procedure_occurrence.procedure_occurrence_id AND procedure_occurrence.procedure_concept_id = 4244107",
    where_clause: "note.note_title IN('Final Diagnosis', 'Final Pathologic Diagnosis') AND note_date >='2018-03-01'").first_or_create

    #Begin primary cancer
    primary_cancer_group = Abstractor::AbstractorSubjectGroup.where(name: 'Primary Cancer', enable_workflow_status: false).first_or_create
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_histology',
      display_name: 'Histology',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer histology').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id, anchor: true).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 1).first_or_create

    #End primary cancer
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_site',
      display_name: 'Site',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer site').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id, anchor: false).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 2).first_or_create

    #Begin Laterality
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_site_laterality',
      display_name: 'Laterality',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'laterality').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id, anchor: false).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 3).first_or_create

    #End Laterality

    #Begin surgery date
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_surgery_date',
      display_name: 'Surgery Date',
      abstractor_object_type: date_object_type,
      preferred_name: 'Surgery Date').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    #End surgery date

    #Begin WHO Grade
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_who_grade',
      display_name: 'WHO Grade',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'grade').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id, anchor: false).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 4).first_or_create

    #End WHO Grade

    #Begin recurrent
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_recurrence_status',
      display_name: 'Recurrent',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'recurrent').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id, anchor: false, default_abstractor_object_value_id: abstractor_object_value_initial.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => primary_cancer_group, :display_order => 5).first_or_create

    #End recurrent

    #End primary cancer
    #Begin metastatic
    metastatic_cancer_group = Abstractor::AbstractorSubjectGroup.where(name: 'Metastatic Cancer', enable_workflow_status: false).create
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_metastatic_cancer_histology',
      display_name: 'Histology',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer histology').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id, anchor: true).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 1).first_or_create

    #Begin metastatic cancer site
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_site',
      display_name: 'Site',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer site').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id, anchor: false).create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 2).first_or_create

    #End metastatic cancer site

    #Begin metastatic cancer primary site
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_metastatic_cancer_primary_site',
      display_name: 'Primary Site',
      abstractor_object_type: list_object_type,
      preferred_name: 'primary cancer site').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id, anchor: false).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 3).first_or_create

    #End metastatic cancer primary site

    #Begin Laterality
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_site_laterality',
      display_name: 'Laterality',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'laterality').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id, anchor: false).create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 4).first_or_create

    #End Laterality

    #Begin recurrent
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_recurrence_status',
      display_name: 'Recurrent',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'recurrent').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id, anchor: false, default_abstractor_object_value_id: abstractor_object_value_initial.id).create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    Abstractor::AbstractorSubjectGroupMember.where(:abstractor_subject => abstractor_subject, :abstractor_subject_group => metastatic_cancer_group, :display_order => 5).first_or_create

    #End recurrent

    #End metastatic

    #Begin IDH1 status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_idh1_status',
      display_name: 'IDH1 Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'idh1').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create

    #End IDH1 status

    #Begin IDH2 status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_idh2_status',
      display_name: 'IDH2 Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'idh2').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    #End IDH2 status

    #Begin 1p status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_1p_status',
      display_name: '1P Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: '1P').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    #End 1p status

    #Begin 19q status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_19q_status',
      display_name: '19q Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: '19Q').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    #End 19q status

    #Begin 10q/PTEN status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_10q_PTEN_status',
      display_name: '10q/PTEN Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: '10q/PTEN').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    #End 10q/PTEN status

    #Begin MGMT promoter methylation status Status status
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_mgmt_status',
      display_name: 'MGMT promoter methylation status Status',
      abstractor_object_type: radio_button_list_object_type,
      preferred_name: 'MGMT').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    #End MGMT promoter methylation status Status

    #Begin ki67
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_ki67',
      display_name: 'ki67',
      abstractor_object_type: number_object_type,
      preferred_name: 'ki67').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    #End ki67

    #Begin p53
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_p53',
      display_name: 'p53',
      abstractor_object_type: number_object_type,
      preferred_name: 'p53').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_outside_surgical_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
    #End p53

    #outside surgical pathology report abstractions setup end

    #molecular genetics report abstractions setup begin
    abstractor_namespace_molecular_pathology = Abstractor::AbstractorNamespace.where(name: 'Molecular Pathology', subject_type: NoteStableIdentifier.to_s, joins_clause:
    "JOIN note_stable_identifier_full ON note_stable_identifier.stable_identifier_path = note_stable_identifier_full.stable_identifier_path AND note_stable_identifier.stable_identifier_value = note_stable_identifier_full.stable_identifier_value
     JOIN note ON note_stable_identifier_full.note_id = note.note_id
     JOIN fact_relationship ON fact_relationship.domain_concept_id_1 = 5085 AND fact_relationship.fact_id_1 = note.note_id AND fact_relationship.relationship_concept_id = 44818790
     JOIN procedure_occurrence ON fact_relationship.domain_concept_id_2 = 10 AND fact_relationship.fact_id_2 = procedure_occurrence.procedure_occurrence_id AND procedure_occurrence.procedure_concept_id = 4019097",
     where_clause: "note.note_title = 'Interpretation'").first_or_create

     abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
       predicate: 'has_mgmt_status',
       display_name: 'MGMT promoter methylation status Status',
       abstractor_object_type: radio_button_list_object_type,
       preferred_name: 'MGMT').first_or_create

    abstractor_subject = Abstractor::AbstractorSubject.where(:subject_type => 'NoteStableIdentifier', :abstractor_abstraction_schema => abstractor_abstraction_schema, namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace_molecular_pathology.id).first_or_create
    Abstractor::AbstractorAbstractionSource.where(abstractor_subject: abstractor_subject, from_method: 'note_text', :abstractor_rule_type => name_value_rule, abstractor_abstraction_source_type: source_type_custom_nlp_suggestion, custom_nlp_provider: 'custom_nlp_provider_clamp').first_or_create
  end

  desc "Clamp Dictionary"
  task(clamp_dictionary: :environment) do  |t, args|
    dictionary_items = []

    predicates = []
    predicates << 'has_cancer_site'
    predicates << 'has_cancer_histology'
    predicates << 'has_metastatic_cancer_histology'
    predicates << 'has_metastatic_cancer_primary_site'
    predicates << 'has_cancer_site_laterality'
    predicates << 'has_cancer_recurrence_status'
    predicates << 'has_cancer_who_grade'

    # positive_negative
    predicates << 'has_idh1_status'
    predicates << 'has_idh2_status'
    predicates << 'has_mgmt_status'

    # deleted_non_deleted
    predicates << 'has_1p_status'
    predicates << 'has_19q_status'
    predicates << 'has_10q_PTEN_status'
    predicates << 'has_10q_PTEN_status'

    #numbers
    predicates << 'has_ki67'
    predicates << 'has_p53'

    Abstractor::AbstractorAbstractionSchema.where(predicate: predicates).all.each do |abstractor_abstraction_schema|
      rule_type = abstractor_abstraction_schema.abstractor_subjects.first.abstractor_abstraction_sources.first.abstractor_rule_type.name
      puts 'hello'
      puts abstractor_abstraction_schema.predicate
      puts rule_type
      case rule_type
      when Abstractor::Enum::ABSTRACTOR_RULE_TYPE_VALUE
        dictionary_items.concat(create_value_dictionary_items(abstractor_abstraction_schema))
      when Abstractor::Enum::ABSTRACTOR_RULE_TYPE_NAME_VALUE
        puts 'this is the one'
        dictionary_items.concat(create_name_dictionary_items(abstractor_abstraction_schema))
        if !abstractor_abstraction_schema.positive_negative_object_type_list? && !abstractor_abstraction_schema.deleted_non_deleted_object_type_list?
          dictionary_items.concat(create_value_dictionary_items(abstractor_abstraction_schema))
        end
      end
    end
    puts 'how much?'
    puts dictionary_items.length

    File.open 'lib/setup/data_out/abstractor_clamp_data_dictionary.txt', 'w' do |f|
      dictionary_items.each do |di|
        f.puts di
      end
    end
  end

  desc "Run CLAMP pipeline"
  task(run_clamp_pipeline: :environment) do  |t, args|
   Dir.glob("#{Rails.root}/lib/setup/data_out/custom_nlp_provider_clamp/*.json").each do |file|
      puts file
      abstractor_note = ClampMapper::ProcessNote.process(JSON.parse(File.read(file)))
      File.write(file.gsub(/\/([^\/]*)\.json$/, '/archive/\1.json'), JSON.pretty_generate(abstractor_note))
      clamp_document = ClampMapper::Parser.new.read(abstractor_note)

      puts 'hello before'
      puts abstractor_note['source_id']
      note_stable_identifier = NoteStableIdentifier.find(abstractor_note['source_id'])
      puts note_stable_identifier.id
      puts abstractor_note['namespace_type']
      puts abstractor_note['namespace_id']
      puts note_stable_identifier.abstractor_abstraction_groups_by_namespace(namespace_type: abstractor_note['namespace_type'], namespace_id: abstractor_note['namespace_id']).size

      sections_grouped = clamp_document.sections.group_by do |section|
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
        clamp_document.sections.reject! { |section| section == bad_guy_section  }
      end

      #new stuff
      sections_grouped = clamp_document.sections.group_by do |section|
        section.name
      end

      if !sections_grouped['SPECIMEN'].nil? && !sections_grouped['COMMENT'].nil?
        bad_guy_sections = []
        sections_grouped['SPECIMEN'].each do |specimen_section|
          if sections_grouped['COMMENT'][0].section_begin < specimen_section.section_begin
            bad_guy_sections << specimen_section
          end
        end
      end

      bad_guy_sections.each do |bad_guy_section|
        clamp_document.sections.reject! { |section| section == bad_guy_section  }
      end
      #end new stuf

      #new stuff 2
      sections_grouped = clamp_document.sections.group_by do |section|
        section.name
      end

      if sections_grouped['SPECIMEN'].nil? && !sections_grouped['COMMENT'].nil?
        puts "we are adding!"
        clamp_document.add_named_entity(0, sections_grouped['COMMENT'][0].section_begin-2, 'SPECIMEN', 'present', true)
      end
      #end new stuf 2

      section_abstractor_abstraction_group_map = {}
      if clamp_document.sections.any?
        note_stable_identifier.abstractor_abstraction_groups_by_namespace(namespace_type: abstractor_note['namespace_type'], namespace_id: abstractor_note['namespace_id']).each do |abstractor_abstraction_group|
          puts 'hello'
          puts abstractor_abstraction_group.abstractor_subject_group.name

          if abstractor_abstraction_group.anchor?
            puts 'we have an anchor'
            anchor_predicate = abstractor_abstraction_group.anchor.abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate
            anchor_sections = []
            abstractor_abstraction_group.anchor.abstractor_abstraction.abstractor_subject.abstractor_abstraction_sources.each do |abstractor_abstraction_source|
              abstractor_abstraction_source.abstractor_abstraction_source_sections.each do |abstractor_abstraction_source_section|
                anchor_sections << abstractor_abstraction_source_section.abstractor_section.name
              end
            end
            anchor_sections.uniq!
            anchor_named_entities = clamp_document.named_entities.select { |named_entity|  named_entity.semantic_tag_attribute == anchor_predicate && !named_entity.negated? && named_entity.sentence.section && anchor_sections.include?(named_entity.sentence.section.name) }
            anchor_named_entity_sections = anchor_named_entities.group_by{ |anchor_named_entity|  anchor_named_entity.sentence.section.section_range }.keys.sort_by(&:min)

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

      abstractor_note['abstractor_abstraction_schemas'].each do |abstractor_abstraction_schema|
        abstractor_abstraction = Abstractor::AbstractorAbstraction.find(abstractor_abstraction_schema['abstractor_abstraction_id'])
        puts abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate
        abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.find(abstractor_abstraction_schema['abstractor_abstraction_source_id'])
        abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.find(abstractor_abstraction_schema['abstractor_abstraction_schema_id'])

        puts "abstractor_abstraction_schema['abstractor_abstraction_source_id']"
        puts abstractor_abstraction_schema['abstractor_abstraction_source_id']

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
        false,                                #suggestion[:unknown].to_s.to_boolean
        true,                                 #suggestion[:not_applicable].to_s.to_boolean
        nil,
        nil,
        false                                 #suggestion[:negated].to_s.to_boolean
        )

        # ABSTRACTOR_RULE_TYPE_UNKNOWN = 'unknown'
        case abstractor_abstraction_source.abstractor_rule_type.name
        when Abstractor::Enum::ABSTRACTOR_RULE_TYPE_VALUE
          named_entities = clamp_document.named_entities.select { |named_entity|  named_entity.semantic_tag_attribute == abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate }
          puts 'here is the predicate'
          puts abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate
          puts 'how much you got?'
          puts named_entities.size
          suggested = false
          if named_entities.any?
            named_entities.each do |named_entity|
              abstractor_abstraction.reload
              puts 'here is the note'
              puts clamp_document.text

              puts 'named_entity_begin'
              puts named_entity.named_entity_begin

              puts 'named_entity_end'
              puts named_entity.named_entity_end

              puts 'sentence_begin'
              puts named_entity.sentence.sentence_begin

              puts 'sentence_end'
              puts named_entity.sentence.sentence_end

              puts 'match_value'
              puts clamp_document.text[named_entity.named_entity_begin..named_entity.named_entity_end]
              puts 'sentence_match_value'
              puts clamp_document.text[named_entity.sentence.sentence_begin..named_entity.sentence.sentence_end]

              section_name = nil
              aa = abstractor_abstraction
              if named_entity.sentence.section.present?
                puts 'step 1'
                puts named_entity.sentence.section.section_range
                puts 'more'
                puts section_abstractor_abstraction_group_map
                if section_abstractor_abstraction_group_map[named_entity.sentence.section.section_range].present?
                  puts 'step 2'
                  section_abstractor_abstraction_group_map[named_entity.sentence.section.section_range].each do |abstractor_abstraction_group|
                    abstractor_abstraction_group.abstractor_abstraction_group_members.each do |abstractor_abstraction_group_member|
                      if abstractor_abstraction_group_member.abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate == named_entity.semantic_tag_attribute
                        puts 'hello ninny!'
                        puts named_entity.semantic_tag_attribute
                        aa = abstractor_abstraction_group_member.abstractor_abstraction
                        section_name = named_entity.sentence.section.name

                        suggested_value = named_entity.semantic_tag_value.gsub(' , ', ',')
                        suggested_value = suggested_value.gsub(' - ', '-')

                        abstractor_suggestion = aa.abstractor_subject.suggest(
                        aa,
                        abstractor_abstraction_source,
                        clamp_document.text[named_entity.named_entity_begin..named_entity.named_entity_end], #suggestion_source[:match_value],
                        clamp_document.text[named_entity.sentence.sentence_begin..named_entity.sentence.sentence_end], #suggestion_source[:sentence_match_value]
                        abstractor_note['source_id'],
                        abstractor_note['source_type'],
                        abstractor_note['source_method'],
                        section_name, #suggestion_source[:section_name]
                        suggested_value,    #suggestion[:value]
                        false,                              #suggestion[:unknown].to_s.to_boolean
                        false,                              #suggestion[:not_applicable].to_s.to_boolean
                        nil,
                        nil,
                        named_entity.negated?               #suggestion[:negated].to_s.to_boolean
                        )

                      end
                    end
                  end
                else
                  puts 'step 3'
                  suggested_value = named_entity.semantic_tag_value.gsub(' , ', ',')
                  suggested_value = suggested_value.gsub(' - ', '-')
                  section_name = named_entity.sentence.section.name
                  abstractor_suggestion = aa.abstractor_subject.suggest(
                  aa,
                  abstractor_abstraction_source,
                  clamp_document.text[named_entity.named_entity_begin..named_entity.named_entity_end], #suggestion_source[:match_value],
                  clamp_document.text[named_entity.sentence.sentence_begin..named_entity.sentence.sentence_end], #suggestion_source[:sentence_match_value]
                  abstractor_note['source_id'],
                  abstractor_note['source_type'],
                  abstractor_note['source_method'],
                  section_name, #suggestion_source[:section_name]
                  suggested_value,    #suggestion[:value]
                  false,                              #suggestion[:unknown].to_s.to_boolean
                  false,                              #suggestion[:not_applicable].to_s.to_boolean
                  nil,
                  nil,
                  named_entity.negated?               #suggestion[:negated].to_s.to_boolean
                  )
                end
              else
                puts 'we got to be a good person'
                suggested_value = named_entity.semantic_tag_value.gsub(' , ', ',')
                suggested_value = suggested_value.gsub(' - ', '-')

                abstractor_suggestion = aa.abstractor_subject.suggest(
                aa,
                abstractor_abstraction_source,
                clamp_document.text[named_entity.named_entity_begin..named_entity.named_entity_end], #suggestion_source[:match_value],
                clamp_document.text[named_entity.sentence.sentence_begin..named_entity.sentence.sentence_end], #suggestion_source[:sentence_match_value]
                abstractor_note['source_id'],
                abstractor_note['source_type'],
                abstractor_note['source_method'],
                section_name, #suggestion_source[:section_name]
                suggested_value,    #suggestion[:value]
                false,                              #suggestion[:unknown].to_s.to_boolean
                false,                              #suggestion[:not_applicable].to_s.to_boolean
                nil,
                nil,
                named_entity.negated?               #suggestion[:negated].to_s.to_boolean
                )
              end
              if !named_entity.negated?
                suggested = true
              end
            end
          end
          if !suggested
            # abstractor_abstraction.set_unknown!
            abstractor_abstraction.set_not_applicable!
          end
        when Abstractor::Enum::ABSTRACTOR_RULE_TYPE_NAME_VALUE
          named_entities = clamp_document.named_entities.select { |named_entity|  named_entity.semantic_tag_attribute == abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate }
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
            named_entities = clamp_document.named_entities.select { |named_entity|  named_entity.semantic_tag_attribute == abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate }
            puts 'how much you got?'
            puts named_entities.size
            suggested = false
            suggestions = []
            if abstractor_abstraction_schema.deleted_non_deleted_object_type_list?
              named_entities_names = named_entities.select { |named_entity|  named_entity.semantic_tag_value_type == 'Name' }
              named_entities_values = clamp_document.named_entities.select { |named_entity| named_entity.semantic_tag_attribute == 'deleted_non_deleted' && named_entity.semantic_tag_value_type == 'Value'  }

              if named_entities_names.any?
                named_entities_names.each do |named_entity_name|
                  abstractor_abstraction.reload
                  values = named_entities_values.select { |named_entities_value| named_entity_name.sentence == named_entities_value.sentence }
                  suggested = false

                  if named_entity_name.sentence.section
                    section_name = named_entity_name.sentence.section.name
                  else
                    section_name = nil
                  end

                  if values.any?
                    values.each do |value|
                      abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
                      abstractor_abstraction,
                      abstractor_abstraction_source,
                      clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:match_value],
                      clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:sentence_match_value]
                      abstractor_note['source_id'],
                      abstractor_note['source_type'],
                      abstractor_note['source_method'],
                      section_name, #suggestion_source[:section_name]
                      value.semantic_tag_value,                 #suggestion[:value]
                      false,                                     #suggestion[:unknown].to_s.to_boolean
                      false,                                     #suggestion[:not_applicable].to_s.to_boolean
                      nil,
                      nil,
                      (named_entity_name.negated? || value.negated?)   #suggestion[:negated].to_s.to_boolean
                      )
                      if !named_entity_name.negated? && !value.negated?
                        suggestions << abstractor_suggestion
                        suggested = true
                        if canonical_format?(clamp_document.text[named_entity_name.named_entity_begin..named_entity_name.named_entity_end], clamp_document.text[value.named_entity_begin..value.named_entity_end], clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end])
                          abstractor_suggestion.accepted = true
                          abstractor_suggestion.save!
                        end
                      end
                    end
                  else
                    if !named_entity_name.negated?
                      suggested = true
                      abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
                      abstractor_abstraction,
                      abstractor_abstraction_source,
                      clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:match_value],
                      clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:sentence_match_value]
                      abstractor_note['source_id'],
                      abstractor_note['source_type'],
                      abstractor_note['source_method'],
                      section_name, #suggestion_source[:section_name]
                      nil,                 #suggestion[:value]
                      true,                                     #suggestion[:unknown].to_s.to_boolean
                      false,                                     #suggestion[:not_applicable].to_s.to_boolean
                      nil,
                      nil,
                      false,  #suggestion[:negated].to_s.to_boolean
                      )
                    end
                  end
                end
              end
            elsif abstractor_abstraction_schema.positive_negative_object_type_list?
              named_entities_names = named_entities.select { |named_entity|  named_entity.semantic_tag_value_type == 'Name' }
              named_entities_values = clamp_document.named_entities.select { |named_entity| named_entity.semantic_tag_attribute == 'positive_negative'  && named_entity.semantic_tag_value_type == 'Value'  }

              if named_entities_names.any?
                named_entities_names.each do |named_entity_name|
                  abstractor_abstraction.reload
                  values = named_entities_values.select { |named_entities_value| named_entity_name.sentence == named_entities_value.sentence }
                  if values.any?
                    values.each do |value|
                      if named_entity_name.sentence.section
                        section_name = named_entity_name.sentence.section.name
                      else
                        section_name = nil
                      end

                      abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
                      abstractor_abstraction,
                      abstractor_abstraction_source,
                      clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:match_value],
                      clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:sentence_match_value]
                      abstractor_note['source_id'],
                      abstractor_note['source_type'],
                      abstractor_note['source_method'],
                      section_name, #suggestion_source[:section_name]
                      value.semantic_tag_value,                 #suggestion[:value]
                      false,                                     #suggestion[:unknown].to_s.to_boolean
                      false,                                     #suggestion[:not_applicable].to_s.to_boolean
                      nil,
                      nil,
                      false   #suggestion[:negated].to_s.to_boolean
                      )
                      suggestions << abstractor_suggestion
                      suggested = true
                      if canonical_format?(clamp_document.text[named_entity_name.named_entity_begin..named_entity_name.named_entity_end], clamp_document.text[value.named_entity_begin..value.named_entity_end], clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end])
                        abstractor_suggestion.accepted = true
                        abstractor_suggestion.save!
                      end
                    end
                  else
                    if !named_entity_name.negated?
                      suggested = true
                      abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
                      abstractor_abstraction,
                      abstractor_abstraction_source,
                      clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:match_value],
                      clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:sentence_match_value]
                      abstractor_note['source_id'],
                      abstractor_note['source_type'],
                      abstractor_note['source_method'],
                      nil, #suggestion_source[:section_name]
                      nil,                 #suggestion[:value]
                      true,                                     #suggestion[:unknown].to_s.to_boolean
                      false,                                     #suggestion[:not_applicable].to_s.to_boolean
                      nil,
                      nil,
                      false   #suggestion[:negated].to_s.to_boolean
                      )
                    end
                  end
                end
              end
            end
            if !suggested
              # abstractor_abstraction.set_unknown!
              abstractor_abstraction.set_not_applicable!
            else
              suggestions.uniq!
              if suggestions.size == 1
                abstractor_suggestion = suggestions.first
                abstractor_suggestion.accepted = true
                abstractor_suggestion.save!
              end
            end
          when Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_NUMBER, Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_NUMBER_LIST
            named_entities_names = named_entities.select { |named_entity|  named_entity.semantic_tag_value_type == 'Name' }
            named_entities_values = clamp_document.named_entities.select { |named_entity| named_entity.semantic_tag_attribute == 'number' && named_entity.semantic_tag_value_type == 'Value'  }
            suggested = false
            suggestions = []
            if named_entities_names.any?
              named_entities_names.each do |named_entity_name|
                values = named_entities_values.select { |named_entities_value| named_entity_name.sentence == named_entities_value.sentence }
                values.reject! { |value| named_entity_name.overlap?(value) }
                move = true
                if named_entity_name.sentence.section
                  section_name = named_entity_name.sentence.section.name
                else
                  section_name = nil
                end

                if values.size == 2 #&& values.last.semantic_tag_value.scan('%').present?
                  value_last = values.last.semantic_tag_value.gsub('%', '')
                  sentence = clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end]
                  regexp = Regexp.new("#{values.first.semantic_tag_value}\-#{value_last}\%")
                  match = sentence.match(regexp)
                  if match
                    values.first.semantic_tag_value = (Percentage.new((((values.first.semantic_tag_value.to_f + values.last.semantic_tag_value.to_f)/2)) / 100)).value.to_s
                    abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
                    abstractor_abstraction,
                    abstractor_abstraction_source,
                    clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:match_value],
                    clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:sentence_match_value]
                    abstractor_note['source_id'],
                    abstractor_note['source_type'],
                    abstractor_note['source_method'],
                    section_name,          #suggestion_source[:section_name]
                    values.first.semantic_tag_value,                         #suggestion[:value]
                    false,                                            #suggestion[:unknown].to_s.to_boolean
                    false,                                            #suggestion[:not_applicable].to_s.to_boolean
                    nil,
                    nil,
                    (named_entity_name.negated? || values.first.negated?)    #suggestion[:negated].to_s.to_boolean
                    )
                    if !named_entity_name.negated? && !values.first.negated?
                      suggestions << abstractor_suggestion
                      suggested = true
                      # if canonical_format?(clamp_document.text[named_entity_name.named_entity_begin..named_entity_name.named_entity_end], clamp_document.text[value.named_entity_begin..value.named_entity_end], clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end])
                      #   abstractor_suggestion.accepted = true
                      #   abstractor_suggestion.save!
                      # end
                    end
                    move = false
                  end
                end

                if move && values.any? && values.size <= 4
                  values.each do |value|
                    abstractor_abstraction.reload
                    if value.semantic_tag_value.scan('%').present?
                      value.semantic_tag_value = (Percentage.new(value.semantic_tag_value).to_f / 100).to_s
                    end

                    if !named_entity_name.overlap?(value)
                      abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
                      abstractor_abstraction,
                      abstractor_abstraction_source,
                      clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:match_value],
                      clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:sentence_match_value]
                      abstractor_note['source_id'],
                      abstractor_note['source_type'],
                      abstractor_note['source_method'],
                      section_name,          #suggestion_source[:section_name]
                      value.semantic_tag_value,                         #suggestion[:value]
                      false,                                            #suggestion[:unknown].to_s.to_boolean
                      false,                                            #suggestion[:not_applicable].to_s.to_boolean
                      nil,
                      nil,
                      (named_entity_name.negated? || value.negated?)    #suggestion[:negated].to_s.to_boolean
                      )
                      if !named_entity_name.negated? && !value.negated?
                        suggestions << abstractor_suggestion
                        suggested = true
                        # if canonical_format?(clamp_document.text[named_entity_name.named_entity_begin..named_entity_name.named_entity_end], clamp_document.text[value.named_entity_begin..value.named_entity_end], clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end])
                        #   abstractor_suggestion.accepted = true
                        #   abstractor_suggestion.save!
                        # end
                      end
                    end
                  end
                end

                if values.empty?
                  if !named_entity_name.negated?
                    abstractor_suggestion = abstractor_abstraction.abstractor_subject.suggest(
                    abstractor_abstraction,
                    abstractor_abstraction_source,
                    clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:match_value],
                    clamp_document.text[named_entity_name.sentence.sentence_begin..named_entity_name.sentence.sentence_end], #suggestion_source[:sentence_match_value]
                    abstractor_note['source_id'],
                    abstractor_note['source_type'],
                    abstractor_note['source_method'],
                    nil,          #suggestion_source[:section_name]
                    nil,                         #suggestion[:value]
                    true,                                            #suggestion[:unknown].to_s.to_boolean
                    false,                                            #suggestion[:not_applicable].to_s.to_boolean
                    nil,
                    nil,
                    named_entity_name.negated?    #suggestion[:negated].to_s.to_boolean
                    )
                  end
                end
              end
            end
            if !suggested
              puts 'number not suggested!'
              abstractor_abstraction.set_not_applicable!
            else
              puts 'number is suggested!'
              suggestions.uniq!
              puts 'here is the size'
              puts suggestions.size
              if suggestions.size == 1
                puts 'auto accepting!'
                abstractor_suggestion = suggestions.first
                abstractor_suggestion.accepted = true
                abstractor_suggestion.save!
              end
            end
          end
        end
      end

      #Post-processing across all schemas within an abstraction group
      puts 'hello before'
      puts abstractor_note['source_id']
      puts 'here is note_stable_identifier.id'
      puts note_stable_identifier.id
      puts abstractor_note['namespace_type']
      puts abstractor_note['namespace_id']
      puts note_stable_identifier.abstractor_abstraction_groups_by_namespace(namespace_type: abstractor_note['namespace_type'], namespace_id: abstractor_note['namespace_id']).size
      abstractor_abstraction_groups = note_stable_identifier.abstractor_abstraction_groups_by_namespace(namespace_type: abstractor_note['namespace_type'], namespace_id: abstractor_note['namespace_id'])
      note_stable_identifier.abstractor_abstraction_groups_by_namespace(namespace_type: abstractor_note['namespace_type'], namespace_id: abstractor_note['namespace_id']).each do |abstractor_abstraction_group|
        puts 'hello'
        puts abstractor_abstraction_group.abstractor_subject_group.name
        other_abstractor_abstraction_groups = abstractor_abstraction_groups - [abstractor_abstraction_group]
        if !abstractor_abstraction_group.anchor.abstractor_abstraction.only_less_specific_suggested? || (abstractor_abstraction_group.anchor.abstractor_abstraction.only_less_specific_suggested? && other_abstractor_abstraction_groups.detect { |other_abstractor_abstraction_group| other_abstractor_abstraction_group.anchor.abstractor_abstraction.suggested? })
          abstractor_abstraction_group.abstractor_abstraction_group_members.not_deleted.each do |abstractor_abstraction_group_member|
            puts abstractor_abstraction_group_member.abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate

            # member suggested
            if abstractor_abstraction_group_member.abstractor_abstraction.suggested?
              #anchor suggested
              if abstractor_abstraction_group.anchor.abstractor_abstraction.suggested?
                if abstractor_abstraction_group_member.abstractor_abstraction.only_less_specific_suggested?
                  abstractor_abstraction_group_member.abstractor_abstraction.set_only_suggestion!
                end
              #anchor not suggested
              else
                abstractor_abstraction_group_member.abstractor_abstraction.set_not_applicable!
              end
            #member not suggested
            else
              #anchor suggested
              if abstractor_abstraction_group.anchor.abstractor_abstraction.suggested?
                if abstractor_abstraction_group_member.abstractor_abstraction.only_less_specific_suggested?
                  abstractor_abstraction_group_member.abstractor_abstraction.set_only_suggestion!
                elsif abstractor_abstraction_group_member.abstractor_abstraction.detault_suggested_value?
                  abstractor_abstraction_group_member.abstractor_abstraction.set_detault_suggested_value!(abstractor_note['source_id'], abstractor_note['source_type'], abstractor_note['source_method'],)
                else
                  abstractor_abstraction_group_member.abstractor_abstraction.set_not_applicable!
                end
              #anchor not suggested
              else
                abstractor_abstraction_group_member.abstractor_abstraction.set_not_applicable!
              end
            end
          end
        end
      end

      # Post-processing across all schemas within an abstraction group.  If only less specific suggested.
      puts 'hello before'
      puts abstractor_note['source_id']
      note_stable_identifier = NoteStableIdentifier.find(abstractor_note['source_id'])
      puts 'here is note_stable_identifier.id'
      puts note_stable_identifier.id
      puts abstractor_note['namespace_type']
      puts abstractor_note['namespace_id']
      puts note_stable_identifier.abstractor_abstraction_groups_by_namespace(namespace_type: abstractor_note['namespace_type'], namespace_id: abstractor_note['namespace_id']).size
      abstractor_abstraction_groups = note_stable_identifier.abstractor_abstraction_groups_by_namespace(namespace_type: abstractor_note['namespace_type'], namespace_id: abstractor_note['namespace_id'])
      note_stable_identifier.abstractor_abstraction_groups_by_namespace(namespace_type: abstractor_note['namespace_type'], namespace_id: abstractor_note['namespace_id']).each do |abstractor_abstraction_group|
        other_abstractor_abstraction_groups = abstractor_abstraction_groups - [abstractor_abstraction_group]
        puts 'hello'
        puts abstractor_abstraction_group.abstractor_subject_group.name
        if abstractor_abstraction_group.anchor.abstractor_abstraction.only_less_specific_suggested? && !other_abstractor_abstraction_groups.detect { |other_abstractor_abstraction_group| other_abstractor_abstraction_group.anchor.abstractor_abstraction.suggested? }
          abstractor_abstraction_group.abstractor_abstraction_group_members.not_deleted.each do |abstractor_abstraction_group_member|
            puts abstractor_abstraction_group_member.abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate
            if abstractor_abstraction_group_member.anchor?
              abstractor_abstraction_group_member.abstractor_abstraction.set_only_suggestion!
            else
              if abstractor_abstraction_group_member.abstractor_abstraction.suggested?
                if abstractor_abstraction_group_member.abstractor_abstraction.only_less_specific_suggested?
                  abstractor_abstraction_group_member.abstractor_abstraction.set_only_suggestion!
                end
              else
                puts 'not suggested'
                if abstractor_abstraction_group_member.abstractor_abstraction.only_less_specific_suggested?
                  abstractor_abstraction_group_member.abstractor_abstraction.set_only_suggestion!
                elsif abstractor_abstraction_group_member.abstractor_abstraction.detault_suggested_value?
                  abstractor_abstraction_group_member.abstractor_abstraction.set_detault_suggested_value!(abstractor_note['source_id'], abstractor_note['source_type'], abstractor_note['source_method'],)
                else
                  abstractor_abstraction_group_member.abstractor_abstraction.set_not_applicable!
                end
              end
            end
          end
        end
      end

      File.delete(file)
    end
  end

  desc "Migrate calculate performance"
  task(migrate_calculate_performance: :environment) do  |t, args|
    misses = []
    misses_latest_old = Roo::Spreadsheet.open('lib/setup/data/compare/misses_latest_old.xlsx')
    misses_map = {
       'note_id' => 0,
       'value_old_normalized' => 1,
       'value_new_normalized' => 2,
       'source' => 3,
       'target' => 4,
       'reason' => 5,
       'histology' => 6,
       'category' => 7,
       'stable_identifier_value' => 8
    }

    for i in 2..misses_latest_old.sheet(0).last_row do
      puts 'row'
      puts i
      miss = {}
      miss['note_id'] = misses_latest_old.sheet(0).row(i)[misses_map['note_id']]
      miss['value_old_normalized'] = misses_latest_old.sheet(0).row(i)[misses_map['value_old_normalized']]
      miss['value_new_normalized'] = misses_latest_old.sheet(0).row(i)[misses_map['value_new_normalized']]
      miss['source'] = misses_latest_old.sheet(0).row(i)[misses_map['source']]
      miss['target'] = misses_latest_old.sheet(0).row(i)[misses_map['target']]
      miss['reason'] = misses_latest_old.sheet(0).row(i)[misses_map['reason']]
      miss['histology'] = misses_latest_old.sheet(0).row(i)[misses_map['histology']]
      miss['category'] = misses_latest_old.sheet(0).row(i)[misses_map['category']]
      miss['stable_identifier_value'] = misses_latest_old.sheet(0).row(i)[misses_map['stable_identifier_value']]
      misses << miss
    end

    misses_latest_new = CSV.new(File.open('lib/setup/data/compare/misses_latest_new.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")

    headers = ['note_id',	'value_old_normalized',	'value_new_normalized',	'source',	'target',	'reason',	'histology',	'category', 'stable_identifier_value', 'value_new_normalized_raw']
    row_header = CSV::Row.new(headers, headers, true)
    row_template = CSV::Row.new(headers, [], false)

    CSV.open('lib/setup/data/compare/misses_latest_new_curated.csv', "wb") do |csv|
      csv << row_header
      misses_latest_new.each do |miss_latest_new|
        row = row_template.dup
        puts miss_latest_new['note_id']
        row['note_id'] = miss_latest_new['note_id']
        puts miss_latest_new['value_old_normalized']
        row['value_old_normalized'] = miss_latest_new['value_old_normalized']
        row['value_new_normalized'] = miss_latest_new['value_new_normalized']
        row['stable_identifier_value'] = miss_latest_new['stable_identifier_value']
        row['value_new_normalized_raw'] = miss_latest_new['value_new_normalized_raw']
        miss = misses.detect { |miss| miss['stable_identifier_value'].to_s == miss_latest_new['stable_identifier_value'].to_s && miss['value_old_normalized'] == miss_latest_new['value_old_normalized'] }

        if miss.present?
          puts 'not so much'
          row['source'] = miss['source']
          row['target'] = miss['target']
          row['reason'] = miss['reason']
          row['histology'] = miss['histology']
          row['category'] = miss['category']
        else
          puts 'same old'
          row['source'] = miss_latest_new['source']
          row['target'] = miss_latest_new['target']
          row['reason'] = miss_latest_new['reason']
          row['histology'] = miss_latest_new['histology']
          row['category'] = miss_latest_new['category']
        end
        csv << row
      end
    end
    ##metastatc
    misses = []
    misses_latest_old = Roo::Spreadsheet.open('lib/setup/data/compare/misses_metastatic_latest_old.xlsx')
    misses_map = {
       'note_id' => 0,
       'value_old_normalized' => 1,
       'value_new_normalized' => 2,
       'source' => 3,
       'target' => 4,
       'reason' => 5,
       'histology' => 6,
       'category' => 7,
       'stable_identifier_value' => 8
    }

    for i in 2..misses_latest_old.sheet(0).last_row do
      puts 'row'
      puts i
      miss = {}
      miss['note_id'] = misses_latest_old.sheet(0).row(i)[misses_map['note_id']]
      miss['value_old_normalized'] = misses_latest_old.sheet(0).row(i)[misses_map['value_old_normalized']]
      miss['value_new_normalized'] = misses_latest_old.sheet(0).row(i)[misses_map['value_new_normalized']]
      miss['source'] = misses_latest_old.sheet(0).row(i)[misses_map['source']]
      miss['target'] = misses_latest_old.sheet(0).row(i)[misses_map['target']]
      miss['reason'] = misses_latest_old.sheet(0).row(i)[misses_map['reason']]
      miss['histology'] = misses_latest_old.sheet(0).row(i)[misses_map['histology']]
      miss['category'] = misses_latest_old.sheet(0).row(i)[misses_map['category']]
      miss['stable_identifier_value'] = misses_latest_old.sheet(0).row(i)[misses_map['stable_identifier_value']]
      misses << miss
    end

    misses_latest_new = CSV.new(File.open('lib/setup/data/compare/misses_metastatic_latest_new.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")

    headers = ['note_id',	'value_old_normalized',	'value_new_normalized',	'source',	'target',	'reason',	'histology',	'category', 'stable_identifier_value',  'value_new_normalized_raw']
    row_header = CSV::Row.new(headers, headers, true)
    row_template = CSV::Row.new(headers, [], false)

    CSV.open('lib/setup/data/compare/misses_metastatic_latest_new_curated.csv', "wb") do |csv|
      csv << row_header
      misses_latest_new.each do |miss_latest_new|
        row = row_template.dup
        puts miss_latest_new['note_id']
        row['note_id'] = miss_latest_new['note_id']
        puts miss_latest_new['value_old_normalized']
        row['value_old_normalized'] = miss_latest_new['value_old_normalized']
        row['value_new_normalized'] = miss_latest_new['value_new_normalized']
        row['stable_identifier_value'] = miss_latest_new['stable_identifier_value']
        row['value_new_normalized_raw'] = miss_latest_new['value_new_normalized_raw']
        miss = misses.detect { |miss| miss['stable_identifier_value'].to_s == miss_latest_new['stable_identifier_value'].to_s && miss['value_old_normalized'] == miss_latest_new['value_old_normalized'] }

        if miss.present?
          puts 'not so much'
          row['source'] = miss['source']
          row['target'] = miss['target']
          row['reason'] = miss['reason']
          row['histology'] = miss['histology']
          row['category'] = miss['category']
        else
          puts 'same old'
          row['source'] = miss_latest_new['source']
          row['target'] = miss_latest_new['target']
          row['reason'] = miss_latest_new['reason']
          row['histology'] = miss_latest_new['histology']
          row['category'] = miss_latest_new['category']
        end
        csv << row
      end
    end

    ##site
    misses = []
    misses_latest_old = Roo::Spreadsheet.open('lib/setup/data/compare/misses_has_cancer_site_curated_old.xlsx')
    misses_map = {
       'note_id' => 0,
       'abstractor_subject_group_name' => 1,
       'value_old_normalized' => 2,
       'value_new_normalized' => 3,
       'source' => 4,
       'target' => 5,
       'reason' => 6,
       'site' => 7,
       'category' => 8,
       'stable_identifier_value' => 10
    }

    for i in 2..misses_latest_old.sheet(0).last_row do
      puts 'row'
      puts i
      miss = {}
      miss['note_id'] = misses_latest_old.sheet(0).row(i)[misses_map['note_id']]
      miss['value_old_normalized'] = misses_latest_old.sheet(0).row(i)[misses_map['value_old_normalized']]
      miss['value_new_normalized'] = misses_latest_old.sheet(0).row(i)[misses_map['value_new_normalized']]
      miss['source'] = misses_latest_old.sheet(0).row(i)[misses_map['source']]
      miss['target'] = misses_latest_old.sheet(0).row(i)[misses_map['target']]
      miss['reason'] = misses_latest_old.sheet(0).row(i)[misses_map['reason']]
      miss['site'] = misses_latest_old.sheet(0).row(i)[misses_map['site']]
      miss['category'] = misses_latest_old.sheet(0).row(i)[misses_map['category']]
      miss['stable_identifier_value'] = misses_latest_old.sheet(0).row(i)[misses_map['stable_identifier_value']]
      misses << miss
    end

    misses_latest_new = CSV.new(File.open('lib/setup/data/compare/misses_has_cancer_site_new.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")

    headers = ['note_id',	'abstractor_subject_group_name','value_old_normalized',	'value_new_normalized',	'source',	'target',	'reason',	'site',	'category', 'group', 'stable_identifier_value', 'value_new_normalized_raw']
    row_header = CSV::Row.new(headers, headers, true)
    row_template = CSV::Row.new(headers, [], false)

    CSV.open('lib/setup/data/compare/misses_has_cancer_site_new_curated.csv', "wb") do |csv|
      csv << row_header
      misses_latest_new.each do |miss_latest_new|
        row = row_template.dup
        puts miss_latest_new['note_id']
        row['note_id'] = miss_latest_new['note_id']
        puts miss_latest_new['value_old_normalized']
        row['abstractor_subject_group_name'] = miss_latest_new['abstractor_subject_group_name']
        row['value_old_normalized'] = miss_latest_new['value_old_normalized']
        row['value_new_normalized'] = miss_latest_new['value_new_normalized']
        row['stable_identifier_value'] = miss_latest_new['stable_identifier_value']
        row['value_new_normalized_raw'] = miss_latest_new['value_new_normalized_raw']
        miss = misses.detect { |miss| miss['stable_identifier_value'].to_s == miss_latest_new['stable_identifier_value'].to_s && miss['value_old_normalized'] == miss_latest_new['value_old_normalized'] }

        if miss.present?
          puts 'not so much'
          row['source'] = miss['source']
          row['target'] = miss['target']
          row['reason'] = miss['reason']
          row['site'] = miss['site']
          row['category'] = miss['category']
          row['group'] = miss_latest_new['group']
        else
          puts 'same old'
          row['source'] = miss_latest_new['source']
          row['target'] = miss_latest_new['target']
          row['reason'] = miss_latest_new['reason']
          row['site'] = miss_latest_new['site']
          row['category'] = miss_latest_new['category']
          row['group'] = miss_latest_new['group']
        end
        csv << row
      end
    end
  end

  desc "Calculate performance"
  task(calculate_performance: :environment) do  |t, args|
    NlpComparison.delete_all
    old_suggestions = CSV.new(File.open('lib/setup/data/mbti_data_development.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")

    old_suggestions.each do |old_suggestion|
      puts old_suggestion['note_id'].to_i
      if NlpComparison.where(abstractor_abstraction_id_old: old_suggestion['abstractor_abstraction_id_old'].to_i).first.blank?
        nlp_comparison = NlpComparison.new
        nlp_comparison.note_id = old_suggestion['note_id'].to_i
        nlp_comparison.abstractor_abstraction_id_old = old_suggestion['abstractor_abstraction_id_old'].to_i
        nlp_comparison.stable_identifier_path = old_suggestion['stable_identifier_path']
        nlp_comparison.stable_identifier_value = old_suggestion['stable_identifier_value']
        nlp_comparison.note_stable_identifier_id_old = old_suggestion['note_stable_identifier_id']
        nlp_comparison.abstractor_subject_group_name = old_suggestion['abstractor_subject_group_name']
        if old_suggestion['abstractor_abstraction_group_id'].present?
          nlp_comparison.abstractor_abstraction_group_id_old = old_suggestion['abstractor_abstraction_group_id'].to_i
        else
          nlp_comparison.abstractor_abstraction_group_id_old = nil
        end
        nlp_comparison.predicate_old = old_suggestion['predicate']
        nlp_comparison.predicate = map_predicate(old_suggestion['predicate'])
        nlp_comparison.value_old = old_suggestion['value']
        if old_suggestion['abstractor_abstraction_group_id'].present?
          nlp_comparison.value_old_normalized = old_suggestion['value']
        end
        nlp_comparison.save!
      end
    end

    NlpComparison.select('DISTINCT stable_identifier_value').each do |nlp_comparison|
      NlpComparison.where("stable_identifier_value = ? AND abstractor_subject_group_name = 'Primary Cancer'", nlp_comparison.stable_identifier_value).select('DISTINCT abstractor_abstraction_group_id_old').each_with_index do |nlp_comparison2, i|
        NlpComparison.where(abstractor_abstraction_group_id_old: nlp_comparison2.abstractor_abstraction_group_id_old).update_all(abstractor_subject_group_counter: i+1)
      end
    end

    NlpComparison.select('DISTINCT stable_identifier_value').each do |nlp_comparison|
      NlpComparison.where("stable_identifier_value = ? AND abstractor_subject_group_name = 'Metastatic Cancer'", nlp_comparison.stable_identifier_value).select('DISTINCT abstractor_abstraction_group_id_old').each_with_index do |nlp_comparison2, i|
        NlpComparison.where(abstractor_abstraction_group_id_old: nlp_comparison2.abstractor_abstraction_group_id_old).update_all(abstractor_subject_group_counter: i+1)
      end
    end

    new_suggestions = CSV.new(File.open('lib/setup/data/mbti_data_development_new.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    new_suggestions = new_suggestions.map { |new_suggestion| { stable_identifier_value: new_suggestion['stable_identifier_value'], predicate: new_suggestion['predicate'], value: new_suggestion['value'], abstractor_abstraction_group_id: new_suggestion['abstractor_abstraction_group_id'] } }.uniq

    new_suggestions.each do |new_suggestion|
      if new_suggestion[:abstractor_abstraction_group_id].blank?
        NlpComparison.where(stable_identifier_value: new_suggestion[:stable_identifier_value], predicate: new_suggestion[:predicate]).update_all(value_new: new_suggestion[:value])
      end
    end

    NlpComparison.where("value_old != 'not applicable' AND value_new != 'not applicable' AND value_old IS NOT NULL AND value_old IS NOT NULL AND predicate IN ('has_ki67','has_p53')").update_all('value_old_float = CAST ( value_old AS float )')
    NlpComparison.where("value_old != 'not applicable' AND value_new != 'not applicable' AND value_old IS NOT NULL AND value_old IS NOT NULL AND predicate IN ('has_ki67','has_p53')").update_all('value_new_float = CAST ( value_new AS float )')
    NlpComparison.where("value_old_float/100 = value_new_float").update_all('value_old_float = value_old_float/100')
    NlpComparison.where("value_old_float IS NOT NULL AND predicate IN ('has_ki67','has_p53')").update_all('value_old_normalized = CAST ( value_old_float AS varchar(255) )')
    NlpComparison.where("value_new_float IS NOT NULL AND predicate IN ('has_ki67','has_p53')").update_all('value_new_normalized = CAST ( value_new_float AS varchar(255) )')
    NlpComparison.where("value_old_float IS NULL AND predicate IN ('has_ki67','has_p53')").update_all('value_old_normalized = value_old')
    NlpComparison.where("value_new_float IS NULL AND predicate IN ('has_ki67','has_p53')").update_all('value_new_normalized = value_new')
    NlpComparison.where("predicate NOT IN('has_ki67','has_p53')").update_all('value_old_normalized = value_old')
    NlpComparison.where("abstractor_abstraction_group_id_old IS NULL AND predicate NOT IN('has_ki67','has_p53')").update_all('value_old_normalized = value_old')
    NlpComparison.where("abstractor_abstraction_group_id_old IS NULL AND predicate NOT IN('has_ki67','has_p53')").update_all('value_new_normalized = value_new')

    new_suggestions = CSV.new(File.open('lib/setup/data/mbti_data_development_new.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    new_suggestions = new_suggestions.map { |new_suggestion| { stable_identifier_value: new_suggestion['stable_identifier_value'], predicate: new_suggestion['predicate'], value: new_suggestion['value'], abstractor_abstraction_group_id: new_suggestion['abstractor_abstraction_group_id'],  abstractor_subject_group_name: new_suggestion['abstractor_subject_group_name'], note_id: new_suggestion['note_id'] } }.uniq
    new_has_cancer_histology_suggestions = new_suggestions.select { |new_suggestion| new_suggestion[:predicate] == 'has_cancer_histology' }

    new_has_cancer_histology_suggestions.each do |new_has_cancer_histology_suggestion|
      nlp_comparisons = NlpComparison.where(stable_identifier_value: new_has_cancer_histology_suggestion[:stable_identifier_value], predicate: 'has_cancer_histology')
      nlp_comparisons.each do |nlp_comparison|
        nlp_comparison.value_new_normalized_raw = new_has_cancer_histology_suggestion[:value]
        nlp_comparison.save!

        nlp_comparisons_other_fields = NlpComparison.where("abstractor_abstraction_group_id_old = ? AND predicate != 'has_cancer_histology'", nlp_comparison.abstractor_abstraction_group_id_old)
        nlp_comparisons_other_fields.each do |nlp_comparison_other_field|
          new_suggestion = new_suggestions.detect { |new_suggestion| new_suggestion[:stable_identifier_value] == new_has_cancer_histology_suggestion[:stable_identifier_value] && new_suggestion[:predicate] == nlp_comparison_other_field.predicate }
          if new_suggestion.present? && new_suggestion[:value].present?
            nlp_comparison_other_field.value_new_normalized_raw = new_suggestion[:value]
            nlp_comparison_other_field.save!
          end
        end
      end

      nlp_comparisons = NlpComparison.where(stable_identifier_value: new_has_cancer_histology_suggestion[:stable_identifier_value], predicate: 'has_cancer_histology', value_old: new_has_cancer_histology_suggestion[:value])
      # nlp_comparison = nlp_comparison.first

      puts 'before the storm'
      nlp_comparisons.each do |nlp_comparison|
        puts 'round 1'
        nlp_comparison.value_new = new_has_cancer_histology_suggestion[:value]
        nlp_comparison.value_new_normalized = new_has_cancer_histology_suggestion[:value]
        nlp_comparison.abstractor_abstraction_group_id_new = new_has_cancer_histology_suggestion[:abstractor_abstraction_group_id]
        nlp_comparison.save!

        nlp_comparisons_other_fields = NlpComparison.where("abstractor_abstraction_group_id_old = ? AND predicate != 'has_cancer_histology'", nlp_comparison.abstractor_abstraction_group_id_old)
        nlp_comparisons_other_fields.each do |nlp_comparison_other_field|
          new_suggestion = new_suggestions.detect { |new_suggestion| new_suggestion[:abstractor_abstraction_group_id] == new_has_cancer_histology_suggestion[:abstractor_abstraction_group_id] && new_suggestion[:predicate] == nlp_comparison_other_field.predicate }
          if new_suggestion.present? && new_suggestion[:value].present?
            nlp_comparison_other_field.value_new = new_suggestion[:value]
            nlp_comparison_other_field.value_new_normalized = new_suggestion[:value]
            nlp_comparison_other_field.abstractor_abstraction_group_id_new = new_suggestion[:abstractor_abstraction_group_id]
            nlp_comparison_other_field.save!
          end
        end
      end

      if new_has_cancer_histology_suggestion[:value].present?
        icdo3_histology_code = new_has_cancer_histology_suggestion[:value].scan(/\(\d{4}\/\d\)/).first
        if icdo3_histology_code.present?
          nlp_comparisons = NlpComparison.where(stable_identifier_value: new_has_cancer_histology_suggestion[:stable_identifier_value], predicate: 'has_cancer_histology').where("value_old like '%#{icdo3_histology_code}'")
          nlp_comparisons.each do |nlp_comparison|
            puts 'round 2'
            nlp_comparison.value_new = new_has_cancer_histology_suggestion[:value]
            nlp_comparison.value_new_normalized = new_has_cancer_histology_suggestion[:value]
            nlp_comparison.abstractor_abstraction_group_id_new = new_has_cancer_histology_suggestion[:abstractor_abstraction_group_id]
            nlp_comparison.save!

            nlp_comparisons_other_fields = NlpComparison.where("abstractor_abstraction_group_id_old = ? AND predicate != 'has_cancer_histology'", nlp_comparison.abstractor_abstraction_group_id_old)
            nlp_comparisons_other_fields.each do |nlp_comparison_other_field|
              new_suggestion = new_suggestions.detect { |new_suggestion| new_suggestion[:abstractor_abstraction_group_id] == new_has_cancer_histology_suggestion[:abstractor_abstraction_group_id] && new_suggestion[:predicate] == nlp_comparison_other_field.predicate }
              if new_suggestion.present? && new_suggestion[:value].present?
                nlp_comparison_other_field.value_new = new_suggestion[:value]
                nlp_comparison_other_field.value_new_normalized = new_suggestion[:value]
                nlp_comparison_other_field.abstractor_abstraction_group_id_new = new_suggestion[:abstractor_abstraction_group_id]
                nlp_comparison_other_field.save!
              end
            end
          end
        end
      end

      if new_has_cancer_histology_suggestion[:value] == 'glioblastoma (9440/3)'
        nlp_comparisons = NlpComparison.where(stable_identifier_value: new_has_cancer_histology_suggestion[:stable_identifier_value], predicate: 'has_cancer_histology', value_old: ['glioblastoma, idh-mutant (9445/3)', 'glioblastoma, idh-wildtype (9440/3)'])
        nlp_comparisons.each do |nlp_comparison|
          puts 'round 3'
          nlp_comparison.value_new = new_has_cancer_histology_suggestion[:value]
          nlp_comparison.value_new_normalized = new_has_cancer_histology_suggestion[:value]
          nlp_comparison.abstractor_abstraction_group_id_new = new_has_cancer_histology_suggestion[:abstractor_abstraction_group_id]
          nlp_comparison.save!

          nlp_comparisons_other_fields = NlpComparison.where("abstractor_abstraction_group_id_old = ? AND predicate != 'has_cancer_histology'", nlp_comparison.abstractor_abstraction_group_id_old)
          nlp_comparisons_other_fields.each do |nlp_comparison_other_field|
            new_suggestion = new_suggestions.detect { |new_suggestion| new_suggestion[:abstractor_abstraction_group_id] == new_has_cancer_histology_suggestion[:abstractor_abstraction_group_id] && new_suggestion[:predicate] == nlp_comparison_other_field.predicate }
            if new_suggestion.present? && new_suggestion[:value].present?
              nlp_comparison_other_field.value_new = new_suggestion[:value]
              nlp_comparison_other_field.value_new_normalized = new_suggestion[:value]
              nlp_comparison_other_field.abstractor_abstraction_group_id_new = new_suggestion[:abstractor_abstraction_group_id]
              nlp_comparison_other_field.save!
            end
          end
        end
      end

      if new_has_cancer_histology_suggestion[:value] == 'not applicable'
        nlp_comparisons = NlpComparison.where(stable_identifier_value: new_has_cancer_histology_suggestion[:stable_identifier_value], predicate: 'has_cancer_histology', value_old_normalized: ['no evidence of tumor'])
        nlp_comparisons.each do |nlp_comparison|
          puts 'round 2'
          nlp_comparison.value_new = new_has_cancer_histology_suggestion[:value]
          nlp_comparison.value_new_normalized = new_has_cancer_histology_suggestion[:value]
          nlp_comparison.abstractor_abstraction_group_id_new = new_has_cancer_histology_suggestion[:abstractor_abstraction_group_id]
          nlp_comparison.save!

          nlp_comparisons_other_fields = NlpComparison.where("abstractor_abstraction_group_id_old = ? AND predicate != 'has_cancer_histology'", nlp_comparison.abstractor_abstraction_group_id_old)
          nlp_comparisons_other_fields.each do |nlp_comparison_other_field|
            new_suggestion = new_suggestions.detect { |new_suggestion| new_suggestion[:abstractor_abstraction_group_id] == new_has_cancer_histology_suggestion[:abstractor_abstraction_group_id] && new_suggestion[:predicate] == nlp_comparison_other_field.predicate }
            if new_suggestion.present? && new_suggestion[:value].present?
              nlp_comparison_other_field.value_old_normalized = new_suggestion[:value]
              nlp_comparison_other_field.value_new = new_suggestion[:value]
              nlp_comparison_other_field.value_new_normalized = new_suggestion[:value]
              nlp_comparison_other_field.abstractor_abstraction_group_id_new = new_suggestion[:abstractor_abstraction_group_id]
              nlp_comparison_other_field.save!
            end
          end
        end
      end

      if new_has_cancer_histology_suggestion[:value] == 'gliosis'
        nlp_comparisons = NlpComparison.where(stable_identifier_value: new_has_cancer_histology_suggestion[:stable_identifier_value], predicate: 'has_cancer_histology', value_old_normalized: ['not applicable'])
        nlp_comparisons.each do |nlp_comparison|
          puts 'round 2'
          nlp_comparison.value_new = new_has_cancer_histology_suggestion[:value]
          nlp_comparison.value_new_normalized = new_has_cancer_histology_suggestion[:value]
          nlp_comparison.abstractor_abstraction_group_id_new = new_has_cancer_histology_suggestion[:abstractor_abstraction_group_id]
          nlp_comparison.save!

          nlp_comparisons_other_fields = NlpComparison.where("abstractor_abstraction_group_id_old = ? AND predicate != 'has_cancer_histology'", nlp_comparison.abstractor_abstraction_group_id_old)
          nlp_comparisons_other_fields.each do |nlp_comparison_other_field|
            new_suggestion = new_suggestions.detect { |new_suggestion| new_suggestion[:abstractor_abstraction_group_id] == new_has_cancer_histology_suggestion[:abstractor_abstraction_group_id] && new_suggestion[:predicate] == nlp_comparison_other_field.predicate }
            if new_suggestion.present? && new_suggestion[:value].present?
              nlp_comparison_other_field.value_new = new_suggestion[:value]
              nlp_comparison_other_field.value_new_normalized = new_suggestion[:value]
              nlp_comparison_other_field.abstractor_abstraction_group_id_new = new_suggestion[:abstractor_abstraction_group_id]
              nlp_comparison_other_field.save!
            end
          end
        end
      end

      if new_has_cancer_histology_suggestion[:value] == 'ml, large b-cell, diffuse (9680/3)'
        nlp_comparisons = NlpComparison.where(stable_identifier_value: new_has_cancer_histology_suggestion[:stable_identifier_value], predicate: 'has_cancer_histology', value_old: ['malignant lymphoma (9590/3)'])
        nlp_comparisons.each do |nlp_comparison|
          puts 'round 3'
          nlp_comparison.value_new = new_has_cancer_histology_suggestion[:value]
          nlp_comparison.value_new_normalized = new_has_cancer_histology_suggestion[:value]
          nlp_comparison.abstractor_abstraction_group_id_new = new_has_cancer_histology_suggestion[:abstractor_abstraction_group_id]
          nlp_comparison.save!

          nlp_comparisons_other_fields = NlpComparison.where("abstractor_abstraction_group_id_old = ? AND predicate != 'has_cancer_histology'", nlp_comparison.abstractor_abstraction_group_id_old)
          nlp_comparisons_other_fields.each do |nlp_comparison_other_field|
            new_suggestion = new_suggestions.detect { |new_suggestion| new_suggestion[:abstractor_abstraction_group_id] == new_has_cancer_histology_suggestion[:abstractor_abstraction_group_id] && new_suggestion[:predicate] == nlp_comparison_other_field.predicate }
            if new_suggestion.present? && new_suggestion[:value].present?
              nlp_comparison_other_field.value_new = new_suggestion[:value]
              nlp_comparison_other_field.value_new_normalized = new_suggestion[:value]
              nlp_comparison_other_field.abstractor_abstraction_group_id_new = new_suggestion[:abstractor_abstraction_group_id]
              nlp_comparison_other_field.save!
            end
          end
        end
      end
    end

    new_suggestions = CSV.new(File.open('lib/setup/data/mbti_data_development_new.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    new_suggestions = new_suggestions.map { |new_suggestion| { stable_identifier_value: new_suggestion['stable_identifier_value'], predicate: new_suggestion['predicate'], value: new_suggestion['value'], abstractor_abstraction_group_id: new_suggestion['abstractor_abstraction_group_id'],  abstractor_subject_group_name: new_suggestion['abstractor_subject_group_name'], note_id: new_suggestion['note_id'] } }.uniq
    new_has_cancer_histology_suggestions = new_suggestions.select { |new_suggestion| new_suggestion[:predicate] == 'has_metastatic_cancer_histology' }

    new_has_cancer_histology_suggestions.each do |new_has_cancer_histology_suggestion|
      nlp_comparisons = NlpComparison.where(stable_identifier_value: new_has_cancer_histology_suggestion[:stable_identifier_value], predicate: 'has_metastatic_cancer_histology')
      nlp_comparisons.each do |nlp_comparison|
        nlp_comparison.value_new_normalized_raw = new_has_cancer_histology_suggestion[:value]
        nlp_comparison.save!

        nlp_comparisons_other_fields = NlpComparison.where("abstractor_abstraction_group_id_old = ? AND predicate != 'has_metastatic_cancer_histology'", nlp_comparison.abstractor_abstraction_group_id_old)
        nlp_comparisons_other_fields.each do |nlp_comparison_other_field|
          new_suggestion = new_suggestions.detect { |new_suggestion| new_suggestion[:stable_identifier_value] == new_has_cancer_histology_suggestion[:stable_identifier_value] && new_suggestion[:predicate] == nlp_comparison_other_field.predicate }
          if new_suggestion.present? && new_suggestion[:value].present?
            nlp_comparison_other_field.value_new_normalized_raw = new_suggestion[:value]
            nlp_comparison_other_field.save!
          end
        end
      end

      nlp_comparisons = NlpComparison.where(stable_identifier_value: new_has_cancer_histology_suggestion[:stable_identifier_value], predicate: 'has_metastatic_cancer_histology', value_old: new_has_cancer_histology_suggestion[:value])
      nlp_comparisons.each do |nlp_comparison|
        nlp_comparison.value_new = new_has_cancer_histology_suggestion[:value]
        nlp_comparison.value_new_normalized = new_has_cancer_histology_suggestion[:value]
        nlp_comparison.abstractor_abstraction_group_id_new = new_has_cancer_histology_suggestion[:abstractor_abstraction_group_id]
        nlp_comparison.save!

        nlp_comparisons_other_fields = NlpComparison.where("abstractor_abstraction_group_id_old = ? AND predicate != 'has_metastatic_cancer_histology'", nlp_comparison.abstractor_abstraction_group_id_old)
        nlp_comparisons_other_fields.each do |nlp_comparison_other_field|
          new_suggestion = new_suggestions.detect { |new_suggestion| new_suggestion[:abstractor_abstraction_group_id] == new_has_cancer_histology_suggestion[:abstractor_abstraction_group_id] && new_suggestion[:predicate] == nlp_comparison_other_field.predicate }
          if new_suggestion.present? && new_suggestion[:value].present?
            nlp_comparison_other_field.value_new = new_suggestion[:value]
            nlp_comparison_other_field.value_new_normalized = new_suggestion[:value]
            nlp_comparison_other_field.abstractor_abstraction_group_id_new = new_suggestion[:abstractor_abstraction_group_id]
            nlp_comparison_other_field.save!
          end
        end
      end
    end
  end
end

def create_name_dictionary_items(abstractor_abstraction_schema)
  dictionary_items = []
  puts abstractor_abstraction_schema.predicate
  abstractor_abstraction_schema.predicate_variants.each do |predicate_variant|
    predicate_variant.gsub!(',', ' , ')
    predicate_variant.gsub!('-', ' - ')
    puts 'in name add'
    dictionary_items << "#{predicate_variant}\t#{abstractor_abstraction_schema.predicate}:Name|#{predicate_variant}"
  end
  puts 'name length'
  puts dictionary_items.length
  dictionary_items
end

# ABSTRACTOR_OBJECT_TYPE_LIST                 = 'list'
# ABSTRACTOR_OBJECT_TYPE_NUMBER               = 'number'
# ABSTRACTOR_OBJECT_TYPE_BOOLEAN              = 'boolean'
# ABSTRACTOR_OBJECT_TYPE_STRING               = 'string'
# ABSTRACTOR_OBJECT_TYPE_RADIO_BUTTON_LIST    = 'radio button list'
# ABSTRACTOR_OBJECT_TYPE_DATE                 = 'date'
# ABSTRACTOR_OBJECT_TYPE_DYNAMIC_LIST         = 'dynamic list'
# ABSTRACTOR_OBJECT_TYPE_TEXT                 = 'text'
# ABSTRACTOR_OBJECT_TYPE_NUMBER_LIST          = 'number list'

def create_value_dictionary_items(abstractor_abstraction_schema)
  dictionary_items = []
  case abstractor_abstraction_schema.abstractor_object_type.value
  when Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_LIST, Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_RADIO_BUTTON_LIST, Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_NUMBER_LIST
    puts abstractor_abstraction_schema.predicate
    abstractor_abstraction_schema.abstractor_object_values.each do |abstractor_object_value|
      abstractor_object_value.object_variants.each do |object_variant|
        object_variant.gsub!(',', ' , ')
        object_variant.gsub!('-', ' - ')
        puts 'in value add'
        dictionary_items << "#{object_variant}\t#{abstractor_abstraction_schema.predicate}:Value|#{abstractor_object_value.value}"
      end
    end
  end
  puts 'value length'
  puts dictionary_items.length
  dictionary_items
end

def canonical_format?(name, value, sentence)
  canonical_format = false
  begin
    regular_expression = Regexp.new('\b' + name + '\s*\:\s*' + value.strip + '\b')
    canonical_format = sentence.scan(regular_expression).present?

    if !canonical_format
      re = '\b' + name + '\s*' + value.strip + '\b'
      regular_expression = Regexp.new('\b' + name + '\s*' + value.strip + '\b')
      canonical_format = sentence.scan(regular_expression).present?
    end
  rescue Exception => e
  end

  canonical_format
end

def map_predicate(old_predicate)
  predicate = case old_predicate
  when 'has_metastatic_cancer_site'
    'has_cancer_site'
  when 'has_metastatic_cancer_recurrence_status'
    'has_cancer_recurrence_status'
  when 'has_metastatic_cancer_site_laterality'
    'has_cancer_site_laterality'
  else
    old_predicate
  end
end