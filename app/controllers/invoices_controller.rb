class InvoicesController < ApplicationController
  unloadable


  def index
    @project = Project.find(params[:project_id])
    #@invoices = Invoices.find(:all)
  end

  def show
  end

  def add
  end

  def edit
  end
end
