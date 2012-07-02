class ProgramsController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :destroy]
  before_filter :current_user, :only => [:show]
  
  # GET /programs
  # GET /programs.json
  def index
    @programs = Program.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /programs/1
  # GET /programs/1.json
  def show
    @program = Program.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @program }
    end
  end

  # GET /programs/new
  # GET /programs/new.json
  def new
    @program = Program.new
    @program.user_id = @current_user.id
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @program }
    end
  end

  # POST /programs
  # POST /programs.json
  def create
    @program = Program.new(params[:program])
    @program.user = @current_user
    
    if (params[:program][:file].nil?)
      @program.errors[:file] << "You must upload a program file"
      if (params[:program][:arguments].nil?)
        @program.errors[:arguments]  << "You must also upload an arguments file"
      end
      @program.valid?
      
      respond_to do |format|
        format.html { render :action => "new" }
        format.json { render :action => @program.errors, :status => :unprocessable_entity }
      end
    elsif (params[:program][:arguments].nil?)
      @program.errors[:arguments] << "You must upload an arguments file"
      @program.valid?
      
      respond_to do |format|
        format.html { render :action => "new" }
        format.json { render :action => @program.errors, :status => :unprocessable_entity }
      end
    elsif File.extname(params[:program][:file].original_filename).eql?('.hs')    
      @program.save_file!(params[:program][:file], params[:program][:arguments])
      if @program.compiles?
        @program.remove_files!
        respond_to do |format|
          if @program.save
            @program.asynch_benchmark_program
            flash[:success] = 'Program successfully submitted, you will be emailed when benchmarking is complete.'
            format.html { redirect_to @program }
            format.json { render :json => @program, :status => :created, :location => @program }
          else
            format.html { render :action => "new" }
            format.json { render :action => @program.errors, :status => :unprocessable_entity }
          end
        end
      else
        @program.remove_files!
        respond_to do |format|
          format.html { render :action => "new" }
          format.json { render :action => @program.errors, :status => :unprocessable_entity }
        end  
      end
    end
  end

  # DELETE /programs/1
  # DELETE /programs/1.json
  def destroy
    @program = Program.find(params[:id])
    if @current_user.id == @program.user_id
      @program.remove_files!
      @program.destroy

      respond_to do |format|
        format.html { redirect_to programs_url }
        format.json { head :no_content }
      end
    else
      flash[:notice] = 'You may only delete programs you own!'
      redirect_to program_path(@program)
    end
  end
end
