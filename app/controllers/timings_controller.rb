class TimingsController < ApplicationController
  FILES_ROOT = Rails.root.to_s + "/public/files/"
  INPUT_DIR = FILES_ROOT + "inputs/"
  SUPER_DIR = FILES_ROOT + "super/" 
  #DISTILL_DIR = FILES_ROOT + 'distill/'
  TEST_CASE_DIR = FILES_ROOT + "/testcases/"
  
  # GET /timings
  # GET /timings.json
  def index
    @timings = Timing.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @timings }
    end
  end

  # GET /timings/1
  # GET /timings/1.json
  def show
    @timing = Timing.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @timing }
    end
  end

  # GET /timings/new
  # GET /timings/new.json
  def new
    @timing = Timing.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @timing }
    end
  end

  # GET /timings/1/edit
  def edit
    @timing = Timing.find(params[:id])
  end

  # POST /timings
  # POST /timings.json
  def create
    @timing = Timing.new(params[:timing])
    if @timing.time_normal && @timing.time_normal(true) && @timing.time_supercompiled && @timing.time_supercompiled(true)
      respond_to do |format|
        if @timing.save
          format.html { redirect_to @timing, :notice => 'Timing was successfully created.' }
          format.json { render :json => @timing, :status => :created, :location => @timing }
        else
          format.html { render :action => "new" }
          format.json { render :json => @timing.errors, :status => :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.json { render :json => @timing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /timings/1
  # PUT /timings/1.json
  def update
    @timing = Timing.find(params[:id])

    respond_to do |format|
      if @timing.update_attributes(params[:timing])
        format.html { redirect_to @timing, :notice => 'Timing was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @timing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /timings/1
  # DELETE /timings/1.json
  def destroy
    @timing = Timing.find(params[:id])
    @timing.destroy

    respond_to do |format|
      format.html { redirect_to timings_url }
      format.json { head :no_content }
    end
  end
end
