//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------

//tranzactiile din acest text se genereaza complet aleatoriu (singura constrangere fiind in fisierul transaction.sv, aceasta asigurand functionalitatea corecta a DUT-ului)
`include "environment.sv"
program test(apb_intf apb_interface_instance, out_intf out_interface_instance);
  
  
  //declaring environment instance
  environment env;
  
  initial begin
    //creating environment
    env = new(apb_interface_instance, out_interface_instance);
    
    //setting the repeat count of generator as 4, means to generate 4 packets
    env.apb_gen.repeat_count = 4;
    env.apb_gen.random_generation = 1;
    
    //calling run of env, it interns calls generator and driver main tasks.
    env.run();
    
   // $display("%0t la sfarsitul testului", $time);
  end
endprogram