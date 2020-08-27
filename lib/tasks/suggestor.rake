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
  Abstractor::AbstractorNamespace.all.each do |abstractor_namespace|
    abstractor_namespace.subject_type.constantize.missing_abstractor_namespace_event(abstractor_namespace.id).joins(abstractor_namespace.joins_clause).where(abstractor_namespace.where_clause).each do |abstractable_event|
      puts 'what we got?'
      puts abstractable_event.id
      child_pid = fork do
        if options[:multiple]
          abstractable_event.abstract_multiple(namespace_type: Abstractor::AbstractorNamespace.to_s, namespace_id: abstractor_namespace.id)
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