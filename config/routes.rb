Automidnight::Application.routes.draw do
  mount RailsEmailPreview::Engine, at: 'emails' if defined?(RailsEmailPreview::Engine)

  resources :voice_answers, only: [:index]

  resource :subscription, controller: :subscription, only: [:create] do
    resource :confirm, module: :subscription, only: [:show]
    resource :unsubscribe, module: :subscription, only: [:show]
  end

  get '/.well-known/status' => 'status#check'

  resources :calls, only: [:create] do
    scope module: :calls do
      resource :consent, only: [:create]
      resources :questions, only: [:create] do
        resource :answer, only: [:create]
      end
    end
  end

  root to: 'landing#index'
end
