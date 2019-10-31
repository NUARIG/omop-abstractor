abstractor_namespace = Abstractor::AbstractorNamespace.where(name: 'Surgical Pathology').first
abstractor_namespace.subject_type.constantize.missing_abstractor_namespace_event(abstractor_namespace.id).joins(abstractor_namespace.joins_clause).where(abstractor_namespace.where_clause).to_sql
abstractor_namespace.subject_type.constantize.missing_abstractor_namespace_event(abstractor_namespace.id).joins(abstractor_namespace.joins_clause).where(abstractor_namespace.where_clause).count

abstractor_namespace = Abstractor::AbstractorNamespace.where(name: 'Outside Surgical Pathology').first
abstractor_namespace.subject_type.constantize.missing_abstractor_namespace_event(abstractor_namespace.id).joins(abstractor_namespace.joins_clause).where(abstractor_namespace.where_clause).to_sql
abstractor_namespace.subject_type.constantize.missing_abstractor_namespace_event(abstractor_namespace.id).joins(abstractor_namespace.joins_clause).where(abstractor_namespace.where_clause).count
abstractor_namespace = Abstractor::AbstractorNamespace.where(name: 'Molecular Pathology').first
