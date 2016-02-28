class InvoicesController < ApplicationController
  unloadable
  before_filter :find_time_entry, :only => [:show, :edit, :update]
  before_filter :find_time_entries, :only => [:bulk_edit, :bulk_update, :destroy]
  before_filter :authorize, :only => [:show, :edit, :update, :bulk_edit, :bulk_update, :destroy]

  before_filter :find_optional_project, :only => [:new, :create, :index, :report]
  before_filter :authorize_global, :only => [:new, :create, :index, :report]
  
  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :sort
  include SortHelper
  helper :issues
  include TimelogHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :queries
  include QueriesHelper

  def index
    @project = Project.find(params[:project_id])
    #@invoices = Invoices.find(:all)
  end

  def show
  end

  def new
    @project = Project.find(params[:project_id])
    @user = User.current
    @query = TimeEntryQuery.build_from_params(params, :project => @project, :name => '_')

    sort_init(@query.sort_criteria.empty? ? [['spent_on', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    scope = time_entry_scope(:order => sort_clause).
      includes(:project, :user, :issue).
      preload(:issue => [:project, :tracker, :status, :assigned_to, :priority])

    respond_to do |format|
      format.html {
        @entry_count = scope.count
        @entry_pages = Paginator.new @entry_count, per_page_option, params['page']
        @entries = scope.offset(@entry_pages.offset).limit(@entry_pages.per_page).to_a
        @total_hours = scope.sum(:hours).to_f

        render :layout => !request.xhr?
      }
    end
  end

  def edit
  end

  private
    def find_time_entry
      @time_entry = TimeEntry.find(params[:id])
      unless @time_entry.editable_by?(User.current)
        render_403
        return false
      end
      @project = @time_entry.project
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def find_time_entries
      @time_entries = TimeEntry.where(:id => params[:id] || params[:ids]).to_a
      raise ActiveRecord::RecordNotFound if @time_entries.empty?
      raise Unauthorized unless @time_entries.all? {|t| t.editable_by?(User.current)}
      @projects = @time_entries.collect(&:project).compact.uniq
      @project = @projects.first if @projects.size == 1
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def set_flash_from_bulk_time_entry_save(time_entries, unsaved_time_entry_ids)
      if unsaved_time_entry_ids.empty?
        flash[:notice] = l(:notice_successful_update) unless time_entries.empty?
      else
        flash[:error] = l(:notice_failed_to_save_time_entries,
                          :count => unsaved_time_entry_ids.size,
                          :total => time_entries.size,
                          :ids => '#' + unsaved_time_entry_ids.join(', #'))
      end
    end

    def find_optional_project
      if params[:issue_id].present?
        @issue = Issue.find(params[:issue_id])
        @project = @issue.project
      elsif params[:project_id].present?
        @project = Project.find(params[:project_id])
      end
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    # Returns the TimeEntry scope for index and report actions
    def time_entry_scope(options={})
      scope = @query.results_scope(options)
      if @issue
        scope = scope.on_issue(@issue)
      end
      scope
    end

    def parse_params_for_bulk_time_entry_attributes(params)
      attributes = (params[:time_entry] || {}).reject {|k,v| v.blank?}
      attributes.keys.each {|k| attributes[k] = '' if attributes[k] == 'none'}
      attributes[:custom_field_values].reject! {|k,v| v.blank?} if attributes[:custom_field_values]
      attributes
    end
  end


