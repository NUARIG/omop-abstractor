class NoteStableIdentifier < ApplicationRecord
  include Abstractor::Abstractable
  self.table_name = 'note_stable_identifier'
  belongs_to :note

  scope :search_across_fields, ->(search_token, providers, secondary_providers, options={}) do
    if search_token
      search_token.downcase!
    end
    options = { sort_column: 'note_date', sort_direction: 'asc' }.merge(options)

    s = joins('JOIN note ON note_stable_identifier.note_id = note.note_id
               JOIN concept AS note_type ON note.note_type_concept_id = note_type.concept_id
               JOIN person ON note.person_id = person.person_id
               LEFT JOIN pii_name ON person.person_id = pii_name.person_id
               ')
    s = s.select('note_stable_identifier.id, note.*, note_type.concept_name AS note_type, pii_name.first_name, pii_name.last_name, note_stable_identifier.stable_identifier_path, note_stable_identifier.stable_identifier_value')
    if search_token
      s = s.where(["lower(note.note_title) like ? OR lower(note.note_text) like ? OR lower(note_type.concept_name) like ? OR lower(pii_name.first_name) like ? OR lower(pii_name.last_name) like ? OR EXISTS (SELECT 1 FROM pii_mrn WHERE person.person_id = pii_mrn.person_id AND pii_mrn.mrn like ?)", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%","%#{search_token}%", "%#{search_token}%","%#{search_token}%"])
    end

    if providers.present?
      s = s.where("EXISTS (SELECT 1
                     FROM note JOIN note_stable_identifier ON note.note_id = note_stable_identifier.note_id
                               JOIN fact_relationship ON fact_relationship.domain_concept_id_1 = 5085 AND fact_relationship.fact_id_1 = note.note_id AND fact_relationship.relationship_concept_id = 44818790
                               JOIN procedure_occurrence ON fact_relationship.domain_concept_id_2 = 10 AND fact_relationship.fact_id_2 = procedure_occurrence.procedure_occurrence_id
                               JOIN provider ON procedure_occurrence.provider_id = provider.provider_id
                     WHERE provider.provider_name in (?))", providers)
    end

    if secondary_providers.present?
      s = s.where("EXISTS (SELECT 1
                     FROM note JOIN note_stable_identifie ON note.note_id = note_stable_identifier.note_id
                               JOIN fact_relationship ON fact_relationship.domain_concept_id_1 = 5085 AND fact_relationship.fact_id_1 = note.note_id AND fact_relationship.relationship_concept_id = 44818790
                               JOIN procedure_occurrence ON fact_relationship.domain_concept_id_2 = 10 AND fact_relationship.fact_id_2 = procedure_occurrence.procedure_occurrence_id
                               JOIN fact_relationship AS fr2 ON fr2.domain_concept_id_1 = 10 AND fr2.fact_id_1 = procedure_occurrence.procedure_occurrence_id AND fr2.relationship_concept_id = 44818888
                               JOIN procedure_occurrence pr2 ON fr2.domain_concept_id_2 = 10 AND fr2.fact_id_2 = pr2.procedure_occurrence_id
                               JOIN provider ON pr2.provider_id = provider.provider_id
                     WHERE provider.provider_name in (?))", secondary_providers)
    end


    sort = options[:sort_column] + ' ' + options[:sort_direction] + ', note.note_id ASC'
    s = s.nil? ? order(sort) : s.order(sort)

    s
  end

  scope :by_note_date, ->(date_from, date_to) do
    if (!date_from.blank? && !date_to.blank?)
      date_range = [date_from, date_to]
    else
      date_range = []
    end

    unless (date_range.first.blank? || date_range.last.blank?)
      where("note_date BETWEEN ? AND ?", Date.parse(date_range.first), (Date.parse(date_range.last) +1).to_s)
    end
  end

  def note_text
    if note.present?
      note.note_text
    end
  end
end