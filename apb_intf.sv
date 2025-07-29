//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
interface apb_intf(input logic clk,reset);
  
  //declaring the signals
  logic [1:0] paddr;
logic pwrite;
logic psel;
logic penable;
logic [7:0] pwdata;
logic [7:0] prdata;
logic pready;
logic pslverr;
  
  //semnalele din clocking block sunt sincrone cu frontul crescator de ceas
  //driver clocking block
  clocking driver_cb @(posedge clk);
    //semnalele de intrare sunt citite o unitate de timp inainte frontului de ceas, iar semnalele de iesire sunt citite o unitate de timp dupa frontul de ceas; astfel se elimina situatiile in care se fac scrieri sau citiri in acelasi timp
    default input #1 output #1;
    output paddr;
    output pwrite;
    output psel;
    output penable;
    output  pwdata; 
	input prdata;	
	input  pready;  
	input pslverr;
  endclocking
  
  //monitor clocking block
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    input paddr;
    input pwrite;
    input psel;
    input penable;
    input  pwdata; 
	input prdata;
	input  pready;  
  endclocking
  
  //driver modport
  modport DRIVER  (clocking driver_cb,input clk,reset);
  
    
  //monitor modport  
  modport MONITOR (clocking monitor_cb,input clk,reset);
  
    // la un tact de la frontul crescator pentru psel, trebuie sa apara un front crescator pentru semnalul penable
    property rose_penable_after_rose_psel;
      @(posedge clk) disable iff (reset == 0)
      $rose(psel) |=> $rose(penable);
      endproperty

    assert property(rose_penable_after_rose_psel);

   //La un front descrescător al semnalului pready, trebuie să apară un front descrescător și pe penable.
      property fell_pready_with_psel;
      @(posedge clk) disable iff (reset == 0)
        $fell(pready) |-> $fell(penable);
      endproperty

    assert property(fell_pready_with_psel);

   //Dacă penable este activ (1), atunci psel trebuie să fie activ în același timp.
      property penable_one_with_psel;
      @(posedge clk) disable iff (reset == 0)
        penable |-> psel;
      endproperty

    assert property(penable_one_with_psel);

      //După ce semnalul pready devine activ (1), în ciclul următor trebuie să revină înactiv (0), indicând un puls de un tact
      property pready_pulse;
      @(posedge clk) disable iff (reset == 0)
        pready |=> !pready;
      endproperty

    assert property(pready_pulse);
endinterface