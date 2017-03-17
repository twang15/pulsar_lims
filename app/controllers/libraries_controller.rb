class LibrariesController < ApplicationController
	include DocumentsConcern #gives me add_documents()
	include BarcodesConcern  #gives me add_barcodes()
  before_action :set_library, only: [:show, :edit, :update, :destroy]

  def index
    @libraries = policy_scope(Library).order("lower(name)")
  end

  # GET /libraries/1
  # GET /libraries/1.json
  def show
		authorize @library
  end

  # GET /libraries/new
  def new
		authorize Library
    @library = Library.new
  end

  # GET /libraries/1/edit
  def edit
		authorize @library	
  end

  # POST /libraries
  # POST /libraries.json
  def create
		authorize Library
    @library = Library.new(library_params)

		@library.user = current_user

		@library = add_documents(@library,params[:library][:document_ids])
		@library = add_barcodes(@library,params[:library][:barcode_ids])

    respond_to do |format|
      if @library.save
        format.html { redirect_to @library, notice: 'Library was successfully created.' }
        format.json { render action: 'show', status: :created, location: @library }
      else
        format.html { render action: 'new' }
        format.json { render json: @library.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /libraries/1
  # PATCH/PUT /libraries/1.json
  def update
		authorize @library
		#@library = remove_documents(@library,params[:remove_documents])
		@library = add_documents(@library,params[:library][:documents])
		@library = add_barcodes(@library,params[:library][:barcode_ids])
    respond_to do |format|
      if @library.update(library_params)
        format.html { redirect_to @library, notice: 'Library was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @library.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /libraries/1
  # DELETE /libraries/1.json
  def destroy
		authorize @library
    @library.destroy
    respond_to do |format|
      format.html { redirect_to libraries_url, notice: "Library has been deleted." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_library
      @library = Library.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The library you were looking for could not be found."
      redirect_to libraries_path
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def library_params
      params.require(:library).permit(:sequencing_library_prep_kit_id, :barcodes, :library_fragmentation_method_id, :nucleic_acid_starting_quantity, :nucleic_acid_starting_quantity_units, :is_control, :nucleic_acid_term_id, :biosample_id, :antibody_id, :vendor_id, :lot_identifier, :vendor_product_identifier, :size_range, :strand_specific, :name, documents_attributes: [:id,:_destroy], sequencing_requests_attributes: [:id,:_destroy], barcodes_attributes: [:id,:_destroy])
    end

end
