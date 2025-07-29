
class apb_coverage;
  
  apb_transaction trans_covered;
  

  covergroup transaction_cg;

    option.per_instance = 1;
    wr_rd_cp: coverpoint trans_covered.wr_rd{
        bins read = {0};
        bins write = {1};
    }
    
   
    address_cp: coverpoint trans_covered.addr{
		bins addr_reg_locuri_parcare_totale = {0};
		bins addr_reg_locuri_ocupate = {1};
        bins addr_reg_acces = {2};
      bins other_addresses = {[3:$]};
    }
	delay_cp:coverpoint trans_covered.delay{
		bins delay_unu = {1};
		bins delay_mic = {[2:10]};
        bins delay_mare = {[11:$]};
        illegal_bins delay_zero = {0};
	}
	
    data_cp: coverpoint trans_covered.data {
        bins values[5] = {[1:254]};
        bins lowest_value = {0};
        bins highest_value = {255};
        bins other_possibilities = default;
    }

    
	wr_rd_address_cx: cross wr_rd_cp, address_cp;
	
  endgroup

  function new();
    transaction_cg = new();
  endfunction
  
      task sample(apb_transaction trans_covered); 
  	this.trans_covered = trans_covered; 
  	transaction_cg.sample(); 
  endtask:sample   
  
  function print_coverage();
    $display("Valori pentru APB:");
    $display ("Address coverage = %.2f%%", transaction_cg.address_cp.get_coverage());
    $display ("Write data coverage = %.2f%%", transaction_cg.data_cp.get_coverage());
    $display ("Write_read coverage = %.2f%%", transaction_cg.wr_rd_cp.get_coverage());
    $display ("Delay coverage = %.2f%%", transaction_cg.delay_cp.get_coverage());
    $display ("Write_Read_Address coverage = %.2f%%", transaction_cg.wr_rd_address_cx.get_coverage());
    $display ("Overall coverage = %.2f%%", transaction_cg.get_coverage());
  endfunction
  
endclass: apb_coverage

