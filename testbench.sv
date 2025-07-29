`timescale 1ns/1ns
//-------------------------------------------------------------------------
//				www.verificationguide.com   testbench.sv
//-------------------------------------------------------------------------
//tbench_top or testbench top, this is the top most file, in which DUT(Design Under Test) and Verification environment are connected. 
//-------------------------------------------------------------------------

//including interfcae and testcase files
`include "out_intf.sv"
`include "apb_intf.sv"

//-------------------------[NOTE]---------------------------------
//Particular testcase can be run by uncommenting, and commenting the rest
`include "test_parcare_diminuata_incrementare.sv"
//`include "test_parcare_diminuata.sv"
//`include "random_test.sv"
//`include "test_doar_adrese_disponibile.sv"
//`include "test_delay_doar_5.sv"
//`include "default_rd_test.sv"
//  `include "test_reset_registrii.sv"
//`include "test_parcare_azure.sv"
//`include "test_intrare_iesire_same_time.sv"
//`include "test_parcare_full.sv"
//----------------------------------------------------------------


module testbench;
  
  //clock and reset signal declaration
  bit clk;
  bit reset;
  
  //clock generation
  always #5 clk = ~clk;
  
  //reset Generation
  initial begin
    reset = 0;
    #15 reset =1;
  end
  
  
  //creatinng instance of interface, inorder to connect DUT and testcase
  apb_intf apb_interface_instance(clk,reset);
  out_intf out_interface_instance(clk,reset);
  
  //Testcase instance, interface handle is passed to test as an argument
  test t1(apb_interface_instance, out_interface_instance);
  
  //DUT instance, interface signals are connected to the DUT ports
 
  
   parcare dut (
    .clk 		(clk),
    .rst_n 		(reset),
    .Paddr 		(apb_interface_instance.paddr),
    .Pwrite		(apb_interface_instance.pwrite),
    .Psel		(apb_interface_instance.psel),
    .Penable 	(apb_interface_instance.penable),
     .Pwdata		(apb_interface_instance.pwdata),
    .Prdata		(apb_interface_instance.prdata),
    .Pready		(apb_interface_instance.pready),
    .Pslverr    (apb_interface_instance.pslverr),
    .bariera(out_interface_instance.bariera),
    .afisare_locuri(out_interface_instance.afisare_locuri),
     .parcare_full(out_interface_instance.parcare_full));
  
  //enabling the wave dump
  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  //  #13000;
  //  $display("%0t before stop", $time);
   // $stop();
  end
endmodule