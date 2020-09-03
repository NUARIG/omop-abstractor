module ClampMapper
  class Section
    attr_accessor :document, :section_begin, :section_end, :section_names, :name
    def initialize(document, section_begin, section_end)
      @document = document
      @section_begin = section_begin.to_i
      @section_end = section_end.to_i
      @named_entity = document.section_named_entities.detect { |section_named_entity| section_named_entity.named_entity_begin >= @section_begin  && section_named_entity.named_entity_end <= @section_end }
      @name = @named_entity.semantic_tag
    end
  end
end