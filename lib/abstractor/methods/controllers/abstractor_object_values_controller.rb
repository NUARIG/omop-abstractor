module Abstractor
  module Methods
    module Controllers
      module AbstractorObjectValuesController
        def self.included(base)
          base.send :helper, :all
          base.send :before_action, :authenticate_user!
          base.send :before_action, :set_abstractor_abstraction_schema
          base.send :before_action, :set_abstractor_object_value, except: [:index, :new, :create]
        end

        def index
          @abstractor_object_values = @abstractor_abstraction_schema.abstractor_object_values.not_deleted.order(:value).search_across_fields(params[:search]).order(:value).paginate(per_page: 10, page: params[:page])
        end

        def new
          @abstractor_object_value = Abstractor::AbstractorObjectValue.new
        end

        def create
          @abstractor_object_value = Abstractor::AbstractorObjectValue.new(abstractor_object_value_params)
          @abstractor_object_value.abstractor_abstraction_schemas << @abstractor_abstraction_schema
          if @abstractor_object_value.save
            redirect_to action: :index
          else
            render :new
          end
        end

        def edit
        end

        def update
          params[:abstractor_abstractor_object_value][:abstractor_object_value_variants_attributes].each do |key, values|
            values[:soft_delete] = values[:_destroy] if values[:id].present?
          end
          if @abstractor_object_value.update_attributes(abstractor_object_value_params)
            redirect_to action: :index
          else
            render :edit
          end
        end

        def destroy
          @abstractor_object_value.soft_delete!
          redirect_to action: :index
        end

        private
          def set_abstractor_abstraction_schema
            @abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.find(params[:abstractor_abstraction_schema_id])
          end

          def set_abstractor_object_value
            @abstractor_object_value = Abstractor::AbstractorObjectValue.find(params[:id])
          end

          def abstractor_object_value_params
            params.require(:abstractor_abstractor_object_value).permit(
              :id,
              :value,
              :vocabulary,
              :vocabulary_version,
              :vocabulary_code,
              :comments,
              :case_sensitive,
              abstractor_object_value_variants_attributes: [
                :id, :value, :case_sensitive, :soft_delete
              ]
            )

          end
      end
    end
  end
end