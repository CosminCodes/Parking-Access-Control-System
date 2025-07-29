`include "environment.sv"
program test(apb_intf apb_interface_instance, out_intf out_interface_instance);

  environment env;
  event ended;

  initial begin
    $display("[%0t] TEST: Pornit testul pentru verificarea registrelor după reset.", $time());

    env = new(apb_interface_instance, out_interface_instance);
    env.apb_gen.random_generation = 0;
  
     env.apb_gen.write_reg(2'b00, 10); 

    
   // Introducerea a 11 masini in parcare.
    for (int i=1;i<=11;i++)
      env.apb_gen.write_reg(2'b10, 1);  // adresa 0x02
    
    // modificarea “reg_locuri_parcare_totale” la 10.
    
    env.apb_gen.write_reg(2'b00, 10); 
    
    env.apb_gen.read_reg(2'b00);     // adresa 0x3
    
    //Diminuarea numarului de masini pana la 8
    for (int i=1;i<=3;i++)
      env.apb_gen.write_reg(2'b10, 8'b0000_0010);
    
     //incercarea introducerii a inca 3 masini.
    for (int i=1;i<=3;i++)
      env.apb_gen.write_reg(2'b10, 1);
    
   
      env.apb_gen.write_reg(2`b10, 8'b0000_0010);

    $display("[%0t] TEST: Finalizat testul de reset și citire registri.", $time());
    
      env.run();

    #4000
    $finish;
  end

endprogram
