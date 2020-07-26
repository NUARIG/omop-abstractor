module ClampMapper
  class Sentence
    attr_accessor :sentence_begin, :sentence_end, :sentence_number, :section
    def initialize(sentence_begin, sentence_end, sentence_number, section)
      @sentence_begin = sentence_begin
      @sentence_end = sentence_end
      @sentence_number = sentence_number
      @section = section
    end
  end
end