//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------

//testele contin unul sau mai multe scenarii de verificarel testele instantiaza mediul de verificare (a se vedea linia 28); testele sunt pornite din testbench

`include "environment.sv"


constraint apb_transaction::address_c {soft addr < 3;}

program test(apb_intf apb_interface_instance, out_intf out_interface_instance);
  
 
    
  //declaring environment instance
  environment env;
  
  initial begin
    //creating environment
    env = new(apb_interface_instance, out_interface_instance);
    
    //setting the repeat count of generator as 4, means to generate 4 packets
    env.apb_gen.repeat_count = 10;
    env.apb_gen.random_generation = 1;
   
    
    //calling run of env, it interns calls generator and driver main tasks.
    env.run();
  end
endprogram