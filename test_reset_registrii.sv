`include "environment.sv"
program test(apb_intf apb_interface_instance, out_intf out_interface_instance);

  environment env;
  event ended;

  initial begin
    $display("[%0t] TEST: Pornit testul pentru verificarea registrelor după reset.", $time());

    env = new(apb_interface_instance, out_interface_instance);
    env.apb_gen.random_generation = 0;
    env.apb_gen.repeat_count = 0;

    fork
      env.run();
    join_none

    // Așteptăm o perioadă scurtă până când vine semnalul de reset
    wait(apb_interface_instance.reset == 0);
    @(posedge apb_interface_instance.clk); // un ciclu
    wait(apb_interface_instance.reset == 1);
    $display("[%0t] TEST: Reset finalizat, încep citirile din registri.", $time());

    // Se citesc valorile celor 4 registri
    env.apb_gen.read_reg(2'b00); // adresa 0x0
    env.apb_gen.read_reg(2'b01); // adresa 0x1
    env.apb_gen.read_reg(2'b10); // adresa 0x2
    env.apb_gen.read_reg(2'b11); // adresa 0x3

    // Așteptăm să se finalizeze toate operațiile
    #100;

    $display("[%0t] TEST: Finalizat testul de reset și citire registri.", $time());
    $finish;
  end

endprogram
