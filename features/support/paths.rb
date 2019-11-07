module NavigationHelpers
  def path_to(page_name)
    case page_name

    when /the home page/
      root_path
    when /the namespace_type "(.*?)" and namespace_id (\d+) sent to the last imaging exam edit page/
      @abstractable = ImagingExam.last
      edit_imaging_exam_path(@abstractable, namespace_type: $1, namespace_id: $2)
    when /the last surgery edit page/
      @abstractable = Surgery.last
      edit_surgery_path(@abstractable)
    when /the last moomin edit page/
      @abstractable = Moomin.last
      edit_moomin_path(@abstractable)
    when /the last pathology case edit page/
      @abstractable = PathologyCase.last
      edit_pathology_case_path(@abstractable)
    when /the last encounter note edit page/
      @abstractable = EncounterNote.last
      edit_encounter_note_path(@abstractable)
    when /the last radiation therapy prescription edit page/
      @abstractable = RadiationTherapyPrescription.last
      edit_radiation_therapy_prescription_path(@abstractable)
    # Add more page name => path mappings here
    when /the radiation therapies index page/
      radiation_therapy_prescriptions_path()
    when /the encounter notes index page/
      encounter_notes_path()
    when /the last abstraction schema object values index page/
      abstraction_schema = Abstractor::AbstractorAbstractionSchema.order(:display_name).last
      Abstractor::UserInterface.abstractor_relative_path(abstractor.abstractor_abstraction_schema_abstractor_object_values_path(abstraction_schema))
    when /the abstraction schemas index page/
      Abstractor::UserInterface.abstractor_relative_path(abstractor.abstractor_abstraction_schemas_path)
    else
      if path = match_rails_path_for(page_name)
        path
      else
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in features/support/paths.rb"
      end
    end
  end

  def match_rails_path_for(page_name)
    if page_name.match(/the (.*) page/)
      return send "#{$1.gsub(" ", "_")}_path" rescue nil
    end
  end
end

World(NavigationHelpers)