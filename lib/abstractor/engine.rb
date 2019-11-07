require 'cocoon'
require 'haml'
require 'will_paginate'

module Abstractor
  class Engine < ::Rails::Engine
    isolate_namespace Abstractor
    root = File.expand_path('../../', __FILE__)
    config.autoload_paths << root
    config.generators do |g|
      g.test_framework   :rspec
      g.integration_tool :rspec
      g.template_engine  :haml
    end

    # Expose egine helpers within the client app
    # https://stackoverflow.com/questions/8797690/rails-3-1-better-way-to-expose-an-engines-helper-within-the-client-app
    initializer 'my_engine.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper Abstractor::ApplicationHelper
      end
    end
  end
end
