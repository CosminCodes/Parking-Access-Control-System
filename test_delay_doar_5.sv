//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------

//testele contin unul sau mai multe scenarii de verificarel testele instantiaza mediul de verificare (a se vedea linia 28); testele sunt pornite din testbench

`include "environment.sv"



program test(apb_intf apb_interface_instance, out_intf out_interface_instance);
  
  
  class my_trans extends apb_transaction;
    
    bit [1:0] count;
    
    //in cadrul acestui test, se doreste ca sa nu primeasca valori aleatorii campurile wr_en, rd_en, si addr (astfel, putem zice ca avem de-a face cu un text directionat spre a testa DUT-ul doar in modul de citire)
    function void pre_randomize();
      delay.rand_mode(0);
        delay = 5;
    endfunction
    
  endclass
    
  //declaring environment instance
  environment env;
  my_trans my_tr;
  
  initial begin
  
    //creating environment
    env = new(apb_interface_instance, out_interface_instance);
    
    //setting the repeat count of generator as 4, means to generate 4 packets
    env.apb_gen.repeat_count = 10;
    env.apb_gen.random_generation = 1;
    
    my_tr = new();
    
    env.apb_gen.trans = my_tr;
    
    //calling run of env, it interns calls generator and driver main tasks.
    env.run();
  end
endprogram