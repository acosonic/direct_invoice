# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'invoices', :to => 'invoices#index'
get 'invoices/new', :to => 'invoices#new'

