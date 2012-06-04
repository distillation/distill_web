class ProgramsController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :destroy]
  before_filter :current_user, :only => [:show]
  FILES_ROOT = Rails.root.to_s + "/public/files/"
  INPUT_DIR = FILES_ROOT + "inputs/"
  SUPER_DIR = FILES_ROOT + "super/" 
  DISTILL_DIR = FILES_ROOT + 'distill/' 
  
  
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
    puts "obble"
    if @current_user
      @new_timing = Timing.new
      @new_timing.user_id = @current_user.id
      @new_timing.program_id = @program.id
    end
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
    @program.user_id = @current_user.id
    uploaded_file = params[:program][:file]
    
    if File.extname(uploaded_file.original_filename).eql?('.hs')    
      chomped_file_name = uploaded_file.original_filename.chomp(File.extname(uploaded_file.original_filename))
    
      #account for previously existing directories of the same name
      #TODO: Better solution.
      if File.exists?(INPUT_DIR + chomped_file_name + '.hs')
        i = 1
        while File.exists?(INPUT_DIR + chomped_file_name + i.to_s + '.hs')
          i += 1
        end
        chomped_file_name << i.to_s
      end
      
      @program.file_name = chomped_file_name + '.hs'
      
      #Save uploaded file
      transformer_file = FILES_ROOT + chomped_file_name
      normal_file_hs = INPUT_DIR + @program.file_name
      File.open(normal_file_hs, 'w') { |file|
        file.write(uploaded_file.read)
        file.close
      }
      
      `#{Haskell.transformer} super #{transformer_file}`
      
      if File.exists?(SUPER_DIR + @program.file_name)
      
        @program.lines = `wc -l #{normal_file_hs}`.to_i
        @program.size = File.size(normal_file_hs) / 1000 #size in kB
        @program.size = 1 if @program.size == 0
        
        respond_to do |format|
          if @program.save
            format.html { redirect_to @program, :notice => 'Program was successfully created.' }
            format.json { render :json => @program, :status => :created, :location => @program }
          else
            format.html { render :action => "new" }
            format.json { render :json => @program.errors, :status => :unprocessable_entity }
          end
        end
      else
        File.delete normal_file_hs
        
        respond_to do |format|
            format.html { render :action => "new" }
            format.json { render :action => @program.errors, :status => :unprocessable_entity }
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
