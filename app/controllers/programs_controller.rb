class ProgramsController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :destroy]
  before_filter :current_user, :only => [:show]
   
  
  NAIVE_REVERSE = <<-END
    module Main where

  import System.Environment (getArgs)
  import Arguments
    
  main = do
    args <- getArgs
    let level = read (head args) :: Int
    print $ root (randomXS level)
    
  root = \\xs -> nrev xs
    
  nrev = \\xs -> case xs of
    [] -> []
    (y:ys) -> app (nrev ys) [y]
    
  app = \\xs ys -> case xs of
    [] -> ys
    (z:zs) -> (z:app zs ys)
  END
  
  ARGUMENTS = <<-END
    module Arguments where
  
  randomXS = \\level -> case level of
    1 -> [1..10]
    2 -> [10..100]
    3 -> [100..1000]
  END
  
  def initialize
    super
    @naive_reverse_code = NAIVE_REVERSE
    @arguments_code = ARGUMENTS
  end
  
  # GET /programs
  # GET /programs.json
  def index
    if (request.filtered_parameters["user_id"])
      @user = User.find(request.filtered_parameters["user_id"])
    end
    @programs = Program.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @programs }
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
    
    if File.extname(params[:program][:file].original_filename).eql?('.hs')    
      @program.save_file!(params[:program][:file], params[:program][:arguments])
      
      respond_to do |format|
        if @program.compiles? && @program.save
          format.html { redirect_to @program, :notice => 'Program was successfully created.' }
          format.json { render :json => @program, :status => :created, :location => @program }
        else
          @program.remove_files!
          
          format.html { render :action => "new" }
          format.json { render :json => @program.errors, :status => :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.json { render :action => @program.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /programs/1
  # DELETE /programs/1.json
  def destroy
    @program = Program.find(params[:id])
    if @current_user.id == @program.user_id
      file_name = @program.file_name
      File.delete(INPUT_DIR + file_name)
      File.delete(SUPER_DIR + file_name)
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
