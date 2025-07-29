//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------

//in mediul de verificare se instantiaza toate componentele de verificare
`include "transaction_out.sv"
`include "coverage_out.sv"
`include "monitor_out.sv"
`include "apb_transaction.sv"
`include "apb_generator.sv"
`include "apb_coverage.sv"
`include "apb_driver.sv"
`include "apb_monitor.sv"
`include "scoreboard.sv"
class environment;
  
  //componentele de verificare sunt declarate
  //generator and driver instance
  apb_generator  apb_gen;
  apb_driver     apb_driv;
  apb_monitor    apb_mon;
  monitor_out 	 mon_out;
  scoreboard     scb;
  
  //mailbox handle's
  mailbox gen2driv;
  mailbox apb_mon2scb;
  mailbox out_mon2scb;
  
  //event for synchronization between generator and test
  event gen_ended;
  
  //virtual interface
  virtual apb_intf apb_vif;
  virtual out_intf out_vif;
  
  //constructor
  function new(virtual apb_intf apb_vif, virtual out_intf out_vif);
    //get the interface from test
    this.out_vif = out_vif;
    this.apb_vif = apb_vif;
    
    //creating the mailbox (Same handle will be shared across generator and driver)
    gen2driv = new();
    apb_mon2scb  = new();
    out_mon2scb = new();
    
    //componentele de verificare sunt create
    //creating generator and driver
    apb_gen  = new(gen2driv,gen_ended);
    apb_driv = new(apb_vif,gen2driv);
    apb_mon  = new(apb_vif,apb_mon2scb);
    mon_out  = new(out_vif,out_mon2scb);
    scb  = new(apb_vif, out_vif, apb_mon2scb, out_mon2scb);
  endfunction
  
  //
  task pre_test();
    apb_driv.reset();
  endtask
  
  task test();
    fork 
      apb_gen.main();
      apb_driv.main();
      apb_mon.main();
      mon_out.main();
      scb.main();      
    join_any
  endtask
  
  task post_test();
 //   $display("%0t inainte de eveniment", $time);
    wait(gen_ended.triggered);
    //$display("%0t dupa eveniment", $time);
    //se urmareste ca toate datele generate sa fie transmise la DUT si sa ajunga si la scoreboard
  //  wait(apb_gen.repeat_count == apb_driv.no_transactions);
   // wait(apb_gen.repeat_count == scb.no_transactions);
  endtask  
  
  function report();
//    scb.colector_coverage.print_coverage();
    $display("%0t suntem in functia report", $time);
    apb_mon.coverage_collector.print_coverage();
    mon_out.coverage_collector.print_coverage();
  endfunction
  
  //run task
  task run;
    pre_test();
    test();
    post_test();
    #5000;
    report();
    //linia de mai jos este necesara pentru ca simularea sa sa termine
    
   // $display("%0t inainte de intarziere", $time);
   
    
   // $display("%0t dupa intarziere", $time);
   
    $stop();
  endtask
  
endclass

