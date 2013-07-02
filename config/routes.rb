PolarisManage::Application.routes.draw do
  resources :promotions do
    get "search", on: :collection
    post "delete_promotion", to: "promotions#delete_promotion", on: :collection
    post "get_promotions_report", on: :collection
    post "download_csv", on: :collection
    post "change_data", on: :collection
    get "promotion_table", on: :collection
  end
  resources :users do
    get "change_lang", on: :collection
    post "get_users_list", on: :collection
    get "search", on: :collection
    post "enable_disable_user", on: :collection
    post "change_company_list", on: :collection
  end
  resources :roles
  resources :conversions do
    get "get_tag", on: :member
    post "change_current_id", on: :collection
  end
  resources :clients do
    post "del_client", to: "clients#del_client", on: :collection
    post "get_promotions_list", on: :collection
  end
  resources :agencies do
    post "get_agencies_list", on: :collection
  end
  resources :sessions, only: [:new, :create] do
    post "resend_password", on: :collection
  end
  match "/signin",  to: "sessions#new"
  match "/signout", to: "sessions#signout"
  root to: "clients#index"
  resources :accounts, only: [:new, :create, :edit, :update] do
    post "change_medias_list", on: :collection
  end
  resources :click_logs, only: [:index] do
    post "get_logs_list", on: :collection
    post "download_csv", on: :collection
    post "change_accounts_list", on: :collection
  end
  resources :conversion_promotion_logs, only: [:index] do
    post "get_conversion_logs_list", on: :collection 
    post "download_csv", on: :collection
    post "change_accounts_list", on: :collection
  end
  resources :url_settings do
    post "get_urls_list", on: :collection
    post "download_csv", on: :collection
    get "download_template", on: :collection
  end
  resources :background_jobs do
    get "upload", on: :collection
    get "download", on: :collection
    get "inprogress", on: :collection
    post "notification", on: :collection
    get "download_file", on: :collection
    post "kill_job", to: "background_jobs#kill_job", on: :collection
  end
  resources :imports
  mount Resque::Server, at: '/resque'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
