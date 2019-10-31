module Abstractor
  module Methods
    module Controllers
      module AbstractorAbstractionSchemasController
        def self.included(base)
          base.send :helper, :all
          base.send :before_action, :authenticate_user!
          base.send :before_action, :set_abstractor_abstraction_schema, only: :show
        end

        def index
          @abstractor_abstraction_schemas = Abstractor::AbstractorAbstractionSchema.not_deleted.order(:display_name)
        end

        def show
          respond_to do |format|
            format.json { render json: Abstractor::Serializers::AbstractorAbstractionSchemaSerializer.new(@abstractor_abstraction_schema).as_json }
          end
        end

        private
          def set_abstractor_abstraction_schema
            @abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.find(params[:id])
          end
      end
    end
  end
end