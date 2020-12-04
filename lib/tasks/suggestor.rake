require 'csv'
namespace :suggestor do
  desc 'Make suggestions'
  task(do: :environment) do |t, args|
    abstractor_suggestor(multiple: false)
  end

  task(do_multiple: :environment) do |t, args|
    abstractor_suggestor(multiple: true)
  end
end

def abstractor_suggestor(options = {})
  options.reverse_merge!({ multiple: false })
  stable_identifier_values = CSV.new(File.open('lib/setup/data/stable_identifier_values.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
  stable_identifier_values = stable_identifier_values.map { |stable_identifier_value| stable_identifier_value['stable_identifier_value'] }
  Abstractor::AbstractorNamespace.all.each do |abstractor_namespace|
    puts abstractor_namespace.subject_type.constantize.missing_abstractor_namespace_event(abstractor_namespace.id).joins(abstractor_namespace.joins_clause).where(abstractor_namespace.where_clause).to_sql
    puts 'hello'
    puts abstractor_namespace.subject_type.constantize.missing_abstractor_namespace_event(abstractor_namespace.id).joins(abstractor_namespace.joins_clause).where(abstractor_namespace.where_clause).size
    abstractor_namespace.subject_type.constantize.missing_abstractor_namespace_event(abstractor_namespace.id).joins(abstractor_namespace.joins_clause).where(abstractor_namespace.where_clause).where(stable_identifier_value: stable_identifier_values).each do |abstractable_event|
      puts 'what we got?'
      puts abstractable_event.id
      child_pid = fork do
        if options[:multiple]
          puts 'here is the stable_identifier_value'
          puts abstractable_event.stable_identifier_value

          note_titles = ['Microscopic Description', 'Addendum']
          procedure_occurrence_options = {}
          procedure_occurrence_options[:username] = 'mjg994'
          procedure_occurrence_options[:include_parent_procedures] = false
          note = abstractable_event.note
          note_options = {}
          note_options[:username] = 'mjg994'
          note_options[:except_notes] = [note]
          note.procedure_occurences(procedure_occurrence_options).each do |procedure_occurence|
            procedure_occurence.notes(note_options).each do |other_note|
              if note_titles.include?(other_note.note_title)
                note.note_text = "#{note.note_text}\n----------------------------------\n#{other_note.note_title}\n----------------------------------\n#{other_note.note_text}"
                note.save!
                note.reload
              else
                puts 'not so much'
              end
            end

            abstractable_event.reload

            abstractable_event.abstract_multiple(namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace.id)
          end
        else
          abstractable_event.abstract(namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace.id)
        end
        abstractor_namespace.abstractor_namespace_events.build(eventable: abstractable_event)
        abstractor_namespace.save!
      end
      Process.wait(child_pid)
    end
  end
end