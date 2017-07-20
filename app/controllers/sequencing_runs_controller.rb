class SequencingRunsController < ApplicationController
  before_action :set_sequencing_run, only: [:show, :edit, :update, :destroy, :new_sequencing_result]
	before_action :set_sequencing_request
	skip_after_action :verify_authorized, only: [:new_sequencing_result]

	def new_sequencing_result
		@sequencing_result = @sequencing_run.sequencing_results.build	
		render layout: "fieldset_sequencing_result", partial: "sequencing_results/form"
		return
	end

  def index
    @sequencing_runs = policy_scope(SequencingRun).order("lower(name)")
  end

  def show
		authorize @sequencing_run
  end

  def new
    @sequencing_run = @sequencing_request.build_sequencing_run
		authorize @sequencing_run
  end

  def edit
		authorize @sequencing_run
  end

  def create
    @sequencing_run = @sequencing_request.build_sequencing_run(sequencing_run_params)
		authorize @sequencing_run
		@sequencing_run.user = current_user

    respond_to do |format|
      if @sequencing_run.save
        format.html { redirect_to [@sequencing_request,@sequencing_run], notice: 'Sequencing run was successfully created.' }
        format.json { render json: @sequencing_run, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @sequencing_run.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
		authorize @sequencing_run
    respond_to do |format|
      if @sequencing_run.update(sequencing_run_params)
        format.html { redirect_to [@sequencing_request,@sequencing_run], notice: 'Sequencing run was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @sequencing_run.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
		authorize @sequencing_run
    @sequencing_run.destroy
    respond_to do |format|
      format.html { redirect_to @sequencing_request}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sequencing_run
      @sequencing_run = SequencingRun.find(params[:id])
    end

		def set_sequencing_request
			@sequencing_request = SequencingRequest.find(params[:sequencing_request_id])
		end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sequencing_run_params
      params.require(:sequencing_run).permit(:name, :sequencing_request_id, :run_name, :lane, :comment)
    end
end
