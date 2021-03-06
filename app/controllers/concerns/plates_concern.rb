module PlatesConcern
  extend ActiveSupport::Concern
  
  private
  
  def add_barcodes_matrix_input(barcodes)
    #barcodes is a string of barcodes in a matrix format like that of the plate, i.e. 
    #
    # CATCGA\tGTCAGT\n
    # ACGTAC\tAGGCAG\n
    # GTTACG\tCATGTC
    #
    #Alternatively the barcodes could be entered as paired-end barcodes of the form:
    #
    # CATCGA-GCATGA\tGTCAGT-TCGTAC\n
    # ACGTAC-TCGAGT\tAGGCAG-ACTAGC\n
    # GTTACG-CTACGT\tCATGTC-TTCAGC
    #
    #Barcodes in each row are delimited by a space or tab character, and rows are delimited by a newline character.  
    #The position of each barcode in the input matrix (matrix is a string here) corresponds to a well in the same position on the plate. For example, the wells represented by the barcode matrix above are
    # A1 A2
     # B1 B2
    # C1 C2
    barcodes_rows = barcodes.split("\n")
    num_rows = barcodes_rows.length
    #check for more rows than the plate
    if num_rows > @plate.nrow
      raise Exceptions::TooManyRowsError, "You have entered #{num_rows} but the plate only has #{@plate.nrow} rows."
    end
    max_row_len = 0
    barcodes_rows.map! do |row|
      row = row.split()
      row_len = row.length
      if row_len > max_row_len
        max_row_len = row_len
      end
      row
    end
    #check for any rows having more columns than the plate
    if max_row_len > @plate.ncol
      raise Exceptions::TooManyColumnsError, "You have entered 1 or more rows with more columns than contained in the plate (#{@plate.ncol})."
    end
        
    row_num = 0
    barcodes_rows.each do |row|
      row_num += 1
      col_num = 0
      row.each do |bc|
        col_num += 1
        bc.strip!
        bc.upcase! #Barcode sequences  are stored uppercase
        well = @plate.wells.find_by({row: row_num, col: col_num})
        if well.blank?
          raise Exceptions::WellNotFoundError, "No well on plate #{@plate.name} could be found with row #{row_num} and column #{col_num}."
        end
        ActiveRecord::Base.transaction do
          #Transaction needed because the call below will delete any existing library(ies) for the given well.
          # If there is a problem when creating the new well, i.e. teh barcode is already present in another 
          # well, then an RuntimeError will occur (which is caught in the plates_controller.rb and a flash error is set. 
          create_library_for_well(well=well,barcode=bc)
        end
      end
    end
  end

  def create_library_for_well(well,barcode)
    ###
    #Args  
    #      well  - a well on the plate
    #      barcode - a single-end barcode or a paired-end barcode. Paired-end will be assumed if the barcode has a '-' inside, 
    #                i.e. ATCGAT-GCTGAC.
    if not @plate.wells.include?(well)
      raise Exceptions::WellAndPlateMismatchError, "Well #{well.name} does not belong on plate #{@plate.name}."
    end
    user = current_user
    if well.biosample.libraries.any?
      well.biosample.libraries.destroy_all
      #Could be that the user made a mistake when adding the libraries initially in matrix format (i.e. incorrect barcode layout)
      # to the plate and needs to redo this step.
    end
    library_prototype = @plate.single_cell_sorting.library_prototype
    well_lib = library_prototype.clone_library(associated_biosample_id: well.biosample.id, associated_user_id: current_user.id)
    #the name is set to the biosample name (see code in the library.rb model file).
    barcode.upcase!
    index1 = barcode
    index2 = nil
    if barcode.include?("-")
      index1,index2 = barcode.split("-")
      index1.strip!
      index2.strip!
    end

    prep_kit = library_prototype.sequencing_library_prep_kit
    
    index1_rec = Barcode.find_by({sequencing_library_prep_kit_id: prep_kit.id, index_number: 1, sequence: index1}) 
    if index1_rec.blank?
      raise Exceptions::BarcodeNotFoundError, "Index 1 barcode #{index1} is not present in sequencing library prep kit '#{prep_kit.name}' Make sure you provided the correct orientation and didn't reverse complement it."
    end
    if not index2 #then single-end only
      well_lib.barcode = index1_rec
    else #then paired-end
      index2_rec = Barcode.find_by({sequencing_library_prep_kit_id: prep_kit.id,index_number: 2, sequence: index2})
      if index2_rec.blank?
        raise Exceptions::BarcodeNotFoundError, "Index2 barcode #{index2} is not present in sequencing library prep kit '#{prep_kit.name}'. Make sure you provided the correct orientation and didn't reverse complement it"
      end 
      paired_rec = PairedBarcode.find_by({sequencing_library_prep_kit_id: prep_kit.id, index1_id: index1_rec.id, index2_id: index2_rec.id})
      if paired_rec.blank? #then create it
        name = PairedBarcode.make_name(index1_rec.name,index2_rec.name)
        paired_rec = PairedBarcode.create!({user: current_user, name: name,sequencing_library_prep_kit_id: prep_kit.id, index1_id: index1_rec.id, index2_id: index2_rec.id})
      end 
      well_lib.paired_barcode = paired_rec
    end

    status = well_lib.save
    if not status 
      raise Exceptions::WellNotSavedError, "Error saving library '#{well_lib.name}' for well #{well.name}. Errors are: #{well_lib.errors.full_messages.join('; ')}"
    end
  end

end
