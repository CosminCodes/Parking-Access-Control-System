//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
class apb_generator;
  
  //clasa contine doua atribute de tipul "transaction"
  rand apb_transaction trans,tr;
  
  //repeat_count arata numarul de tranzactii care vor fi generate
  int  repeat_count;
  
  
  bit random_generation;
  
  //tipul de date mailbox, care poate fi vazut ca o structura de tip coada, reprezinta "portul" prin care generatorul trimite date driver-ului.
  //mailbox, to generate and send the packet to driver
  mailbox gen2driv;
  
  //declararea unui eveniment
  event ended;
  
  //constructor
  function new(mailbox gen2driv,event ended);
    //getting the mailbox handle from env, in order to share the transaction packet between the generator and driver, the same mailbox is shared between both.
    this.gen2driv = gen2driv;
    this.ended    = ended;
    trans = new();
  endfunction
  
  //generatorul aleatorizeaza si transmite spre exterior prin "portul" de tip mailbox continutul tranzactiilor (al caror numar este egal cu repeat_count)
  //main task, generates(create and randomizes) the repeat_count number of transaction packets and puts into mailbox
  task main();
    if(random_generation == 1) begin
      repeat(repeat_count) begin
    	if( !trans.randomize() ) 
          $fatal("Gen:: trans randomization failed");      
    	tr = trans.do_copy();
    	gen2driv.put(tr);
       end
    end
    //se semnaleaza sfarsitul transmiterii datelor de catre generator
    -> ended; 
  endtask
  
  task write_reg(bit [1:0] address, bit [7:0] data1);
    if( !trans.randomize() with {addr == address; data ==data1; wr_rd == 1; } ) 
          $fatal("Gen:: trans randomization failed");      
    	tr = trans.do_copy();
    	gen2driv.put(tr);
    
  endtask
  
 task read_reg(bit [1:0] address);
   if( !trans.randomize() with {addr == address; wr_rd == 0; } ) 
          $fatal("Gen:: trans randomization failed");      
    	tr = trans.do_copy();
    	gen2driv.put(tr);
    
  endtask
  
endclass