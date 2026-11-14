Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :running_records
      post "runs/:run_id/attendance", to: "reputation#confirm"
      post "runs/:run_id/ratings", to: "reputation#rate"
      get "runners/:runner_id/rating-summary", to: "reputation#summary"
      get "runners/:runner_id/running-summary", to: "reputation#running_summary"
      get "me/history", to: "reputation#history"
    end
  end
end
