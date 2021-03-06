class ToursController < ApplicationController
  respond_to :json, :html

  load_and_authorize_resource :only => [:delete, :update]

  def index
    @tours = Tour.asc
    respond_with @tours
  end

  def show
    @title = params[:title]
    @tour = Tour.where(title: @title).first
    respond_with @tour
  end

  def update
    @tour = Tour.find_or_create_by(title: params[:title])
    @tour.update_attributes(params[:tour])
    render :json => {:success => true}
  end

  def delete
    @_title = params[:title]
    @tour = Tour.find_by(title: @_title)
    @tour.delete()
    render :json => {:success => true}
  end

end
