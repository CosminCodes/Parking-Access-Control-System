
`define OUT_MON_IF out_vif.MONITOR.monitor_cb
class monitor_out;
  
 
  virtual out_intf out_vif; 
  mailbox mon2scb;  
  coverage_out coverage_collector;
  
  // Constructorul clasei - primește interfața virtuală și mailbox-ul
  function new(virtual out_intf out_vif,mailbox mon2scb);
    this.out_vif = out_vif;		// Stochează interfața primită
    this.mon2scb = mon2scb;     // Stochează mailbox-ul primit
    coverage_collector = new(); // Creează un nou obiect pentru coverage
  endfunction
  
  
  task main;
    forever begin
      
      	transaction_out trans;
      	trans = new();
     
	 	@(posedge out_vif.MONITOR.clk);
      
        trans.bariera  = `OUT_MON_IF.bariera; // Stare bariera
        trans.afisare_locuri = `OUT_MON_IF.afisare_locuri; 			//Info locuri afisate 
        trans.parcare_full = `OUT_MON_IF.parcare_full;           	   // Parcare full
       
      mon2scb.put(trans); // Trimite tranzactia catre scoreboard prin mailbox.
      	coverage_collector.sample(trans);
		// Se inregistreaza valorile tranzactiei folosind colectorul de coverage.

    end
  endtask
  
endclass
