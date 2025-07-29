//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
//driverul preia datele de la generator, la nivel abstract, si le trimite DUT-ului conform protocolului de comunicatie pe interfata respectiva
//gets the packet from generator and drive the transaction paket items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 


//se declara macro-ul DRIV_IF care va reprezenta interfata pe care driverul va trimite date DUT-ului
`define DRIV_IF apb_vif.DRIVER.driver_cb
class apb_driver;
  
  //used to count the number of transactions
  int no_transactions;
  
  //creating virtual interface handle
  virtual apb_intf apb_vif;
  
  //se creaza portul prin care driverul primeste datele la nivel abstract de la DUT
  //creating mailbox handle
  mailbox gen2driv;
  
  //constructor
  function new(virtual apb_intf apb_vif,mailbox gen2driv);
    //cand se creaza driverul, interfata pe care acesta trimite datele este conectata la interfata reala a DUT-ului
    //getting the interface
    this.apb_vif = apb_vif;
    //getting the mailbox handles from  environment 
    this.gen2driv = gen2driv;
  endfunction
  
  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    wait(!apb_vif.reset);
    $display("--------- [DRIVER] Reset Started ---------");
    `DRIV_IF.paddr <= 'bz;
    `DRIV_IF.pwdata  <= 'bz;
    `DRIV_IF.psel <= 0; 
    `DRIV_IF.penable <= 0;
    `DRIV_IF.pwrite <= 1'bz;
    wait(apb_vif.reset);
    $display("--------- [DRIVER] Reset Ended ---------");
  endtask
  
  //drives the transaction items to interface signals
  task drive;
      apb_transaction trans;
    //daca nu are date de la generator, driverul ramane cu executia la linia de mai jos, pana cand primeste respectivele date
      gen2driv.get(trans);
      $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
    repeat(trans.delay)@(posedge apb_vif.DRIVER.clk);
        `DRIV_IF.paddr <= trans.addr;
        `DRIV_IF.pwrite <= trans.wr_rd;
      if(trans.wr_rd) begin
        `DRIV_IF.pwdata <= trans.data;
      end
      `DRIV_IF.psel <= 1'b1;
      `DRIV_IF.penable <= 1'b0;
    @(posedge apb_vif.DRIVER.clk);
      `DRIV_IF.penable <= 1'b1;
    $display("%0t inainte", $time());
    @(posedge apb_vif.DRIVER.clk iff `DRIV_IF.pready == 1);// se asteapta ca DUT-ul sa accepte tranzactia
    $display("%0t dupa", $time());
        `DRIV_IF.paddr <= 'bz;
    `DRIV_IF.pwdata  <= 'bz;
    `DRIV_IF.psel <= 0; 
    `DRIV_IF.penable <= 0;
    `DRIV_IF.pwrite <= 1'bz;
    
      if(trans.wr_rd) begin
        $display("%0t: Driver: \tADDR = %0h \t written data = %0h  \t write transaction",$time(), trans.addr,trans.data);
      end
    else
      $display("%0t: Driver: \tADDR = %0h  \t read transaction",$time(), trans.addr);
      $display("-----------------------------------------");
      no_transactions++;
  endtask
  
    
  //Cele doua fire de executie de mai jos ruleaza in paralel. Dupa ce primul dintre ele se termina al doilea este intrerupt automat. Daca se activeaza reset-ul, nu se mai transmit date. 
  task main;
    $display(" %0t ---------am intrat in functia main a driverului", $time);
    forever begin
      fork
        //Thread-1: Waiting for reset
        begin
          
          $display(" %0t ---------astept resetul", $time);
          wait(!apb_vif.reset);
          
          $display(" %0t ---------a venit resetul", $time);
        end
        //Thread-2: Calling drive task
        begin
          //transmiterea datelor se face permanent, dar este conditionta de primirea datelor de la monitor.
          forever
            drive();
        end
      join_any
      disable fork;
    end
  endtask
        
endclass