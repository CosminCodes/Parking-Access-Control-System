
//monitorul urmareste traficul de pe interfetele DUT-ului, preia datele verificate si recompune tranzactiile (folosind obiecte ale clasei transaction); in implementarea de fata, datele preluate de pe interfete sunt trimise scoreboardului pentru verificare
//Samples the interface signals, captures into transaction packet and send the packet to scoreboard.

//in macro-ul APB_MON_IF se retine blocul de semnale de unde monitorul extrage datele
`define APB_MON_IF apb_vif.MONITOR.monitor_cb
class apb_monitor;
  
  //creating virtual interface handle
  virtual apb_intf apb_vif;
  
  //se creaza portul prin care monitorul trimite scoreboardului datele colectate de pe interfata DUT-ului sub forma de tranzactii 
  //creating mailbox handle
  mailbox mon2scb;
 
  apb_coverage coverage_collector;
  
  //cand se creaza obiectul de tip monitor (in fisierul environment.sv), interfata de pe care acesta colecteaza date este conectata la interfata reala a DUT-ului
  //constructor
  function new(virtual apb_intf apb_vif,mailbox mon2scb);
    //getting the interface
    this.apb_vif = apb_vif;
    //getting the mailbox handles from  environment 
    this.mon2scb = mon2scb;
    
    coverage_collector =new();
  endfunction
  
  //Samples the interface signal and send the sample packet to scoreboard
  task main;

    forever begin
      //se declara si se creaza obiectul de tip tranzactie care va contine datele preluate de pe interfata
      apb_transaction trans;
      trans = new();
      while(`APB_MON_IF.pready == 0) begin
		trans.delay ++;
	    @(posedge apb_vif.MONITOR.clk);
      end
      trans.delay--;
      //datele sunt citite pe frontul de ceas, informatiile preluate de pe semnale fiind retinute in oboiectul de tip tranzactie
      
        trans.addr  = `APB_MON_IF.paddr;
        trans.wr_rd = `APB_MON_IF.pwrite;
      if (trans.wr_rd == 1) // pentru tranzactie de scriere
			trans.data = `APB_MON_IF.pwdata;
			else // pentru tranzactie de citire
			trans.data = `APB_MON_IF.prdata; 
      // dupa ce s-au retinut informatiile referitoare la o tranzactie, continutul obiectului trans se trimite catre scoreboard
      $display("%0t MONITOR APB: dupa colectarea datelor de pe interfata", $time());
      trans.display();
        mon2scb.put(trans);
      coverage_collector.sample(trans);
      @(posedge apb_vif.MONITOR.clk);
    end
  endtask
  
endclass