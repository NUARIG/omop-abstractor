require './lib/clamp_mapper/section'
require './lib/clamp_mapper/sentence'
require './lib/clamp_mapper/named_entity'
module ClampMapper
  class Document
    attr_accessor :xmi_document, :name, :text, :sections, :sentences, :named_entities
    def initialize(document, name)
      @xmi_document = document
      @name = name
      @text = @xmi_document.xpath("//cas:Sofa")[0].attributes['sofaString'].value

      @sections = []
      @xmi_document.xpath("//textspan:Segment").each do |section|
        @sections << ClampMapper::Section.new(section.attributes['begin'].value, section.attributes['end'].value, section.attributes['preferredText'].value)
      end

      @sentences = []
      @xmi_document.xpath("//textspan:Sentence").each do |sentence|
        @sentences << ClampMapper::Sentence.new(sentence.attributes['begin'].value, sentence.attributes['end'].value, sentence.attributes['sentenceNumber'].value, sentence.attributes['segmentId'].value)
      end

      @named_entities = []
      @xmi_document.xpath("//typesystem:ClampNameEntityUIMA").each do |named_entity|
        @named_entities << ClampMapper::NamedEntity.new(named_entity.attributes['begin'].value, named_entity.attributes['end'].value, named_entity.attributes['semanticTag'].value, named_entity.attributes['assertion'].value)
      end
    end
  end
end