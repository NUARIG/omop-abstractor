module ClampMapper
  class NamedEntity
    attr_accessor :named_entity_begin, :named_entity_end, :semantic_tag, :assertion
    def initialize(named_entity_begin, named_entity_end, semantic_tag, assertion)
      @named_entity_begin = named_entity_begin
      @named_entity_end = named_entity_end
      @semantic_tag = semantic_tag
      @assertion = assertion
    end
  end
end