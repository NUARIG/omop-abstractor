Rails.application.routes.draw do
  devise_for :users
  root 'home#index'
  resources :abstractor_abstraction_groups do
    member do
      put :update_wokflow_status
    end
  end

  resources :abstractor_abstractions do
    collection do
      put :update_all
      put :discard
      put :undiscard
      put :update_wokflow_status
    end
    member do
      put :clear
    end
    resources :abstractor_suggestions
  end

  resources :abstractor_abstraction_schemas, only: [:index, :show] do
    resources :abstractor_object_values
  end

  resources :abstractor_rules do
  end

  resources :notes do
    collection { get :next_note }
    collection { get :previous_note }
  end
  resources :providers, only: :index
  resources :users, only: :show

  #for testing
  resources :encounter_notes, :only => :edit
  resources :imaging_exams, :only => :edit
  resources :moomins, :only => :edit
  resources :radiation_therapy_prescriptions, :only => :edit
  resources :pathology_cases, :only => :edit
  resources :surgeries, :only => :edit


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
