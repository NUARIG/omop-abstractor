module ClampMapper
  class NamedEntity
    attr_accessor :document, :named_entity_begin, :named_entity_end, :semantic_tag, :semantic_tag_attribute, :semantic_tag_value,:assertion, :is_section, :sentence
    def initialize(document, named_entity_begin, named_entity_end, semantic_tag, assertion, is_section)
      @document = document
      @named_entity_begin = named_entity_begin.to_i
      @named_entity_end = named_entity_end.to_i
      @semantic_tag = semantic_tag
      @semantic_tag_attribute, @semantic_tag_value = semantic_tag.split('|')
      @assertion = assertion
      @is_section = is_section
      @sentence = document.sentences.detect { |sentence| @named_entity_begin >= sentence.sentence_begin  && @named_entity_end <= sentence.sentence_end  }
    end

    def negated?
      @assertion == 'absent'
    end
  end
end