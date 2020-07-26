module ClampMapper
  class Section
    attr_accessor :section_begin, :section_end, :section_names
    def initialize(section_begin, section_end, section_names)
      @section_begin = section_begin
      @section_end = section_end
      @section_names = []
      section_names.split('||').compact.each do |section_name|
        if section_name.present?
          @section_names << section_name
        end
      end
    end
  end
end