Redmine::Plugin.register :direct_invoice do
  name 'Direct Invoice plugin'
  author 'Aleksandar Pavić'
  description 'Per specification from Jan Kocis'
  version '0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  permission :invoices, { :invoices => [:index, :add] }, :public => true
  menu :project_menu, :direct_invoice, { :controller => 'invoices', :action => 'index' }, :caption => 'Invoices', :after => :activity, :param => :project_id
  project_module :direct_invoice do
      permission :direct_invoice, :invoices => :index
      permission :direct_invoice, :invoices => :add
  end
end
