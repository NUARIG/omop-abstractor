module Abstractor
  class AbstractorNamespace < ActiveRecord::Base
    has_many :abstractor_namespace_events, dependent: :destroy
  end
end