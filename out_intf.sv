interface out_intf(input logic clk,reset);
  
  //declaring the signals
logic bariera;
logic [7:0]  afisare_locuri;
logic parcare_full;
  

  
  //monitor clocking block
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
input bariera;
input afisare_locuri;
input parcare_full;
  endclocking
  

  
  //monitor modport  
  modport MONITOR (clocking monitor_cb,input clk,reset);
  
    
    ////Semnalul bariera este de tip puls.
property bariera_tip_puls;
  @(posedge clk)
  disable iff (reset)
bariera |=> !bariera;
endproperty

assert property (bariera_tip_puls);




//Decrementarea locurilor ocupate,daca numarul afisat este 255, atunci parcarea trebuie sa fie considerata plina
property p_iesire_decrement;
  @(posedge clk)
  disable iff (reset)
  afisare_locuri == 255 |-> parcare_full ;
endproperty

assert property (p_iesire_decrement);
endinterface