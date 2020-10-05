# class Note < ApplicationRecord
class Note < ActiveRecord::Base
  self.table_name = 'note'
  self.primary_key = 'note_id'
  belongs_to :note_type, class_name: 'Concept', foreign_key: 'note_type_concept_id'
  belongs_to :note_class, class_name: 'Concept', foreign_key: 'note_class_concept_id'
  belongs_to :person, class_name: 'Person', foreign_key: 'person_id', optional: true
  belongs_to :provider, class_name: 'Provider', foreign_key: 'provider_id', optional: true

  def other_notes(options ={})
    abstractor_abstraction_status = options[:abstractor_abstraction_status] || Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW
    namespace_id = options[:namespace_id].blank? ? nil : options[:namespace_id]
    if namespace_id.present?
      namespace_type = Abstractor::AbstractorNamespace.to_s
    end
    NoteStableIdentifier.search_across_fields(nil, nil, nil, {}).where('note.person_id = ? AND note.note_id != ?', self.person_id, self.note_id).by_abstractor_abstraction_status(abstractor_abstraction_status, namespace_type: namespace_type, namespace_id: namespace_id)
  end

  def procedure_occurences(options={})
    options.reverse_merge!({ include_parent_procedures: true })
    get_procedures(options)
  end

  def note_stable_identifier
    if NoteStableIdentifierFull.where(note_id: self.note_id).first
      NoteStableIdentifierFull.where(note_id: self.note_id).first.note_stable_identifier
    end
  end

  private

    def get_procedures(options)
      domain_concept_procedure = Concept.domain_concepts.where(concept_name: 'Procedure').first
      domain_concept_note = Concept.domain_concepts.where(concept_name: 'Note').first
      relationship_has_proc_context = Relationship.where(relationship_id: 'Has proc context').first
      procedure_occurence_ids = FactRelationship.where(domain_concept_id_1: domain_concept_note.concept_id, fact_id_1: self.note_id, domain_concept_id_2: domain_concept_procedure.concept_id, relationship_concept_id: relationship_has_proc_context.relationship_concept_id).map(&:fact_id_2)
      procedures = SqlAudit.find_and_audit(options[:username], ProcedureOccurrence.where(procedure_occurrence_id: procedure_occurence_ids))
      procedures = procedures.to_a
      if options[:include_parent_procedures]
        procedures_temp = procedures.dup
        procedures_temp.each do |procedure|
          procedures.concat(procedure.procedure_occurences(username: options[:username]))
        end
      end
      procedures
    end
end