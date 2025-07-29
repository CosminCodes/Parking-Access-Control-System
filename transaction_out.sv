class transaction_out;


  rand bit  	 bariera;
  rand bit [7:0] afisare_locuri;
  rand bit       parcare_full;
  
  

  function void post_randomize();
    $display("--------- [Trans] post_randomize ------");
    
    $display("\t bariera  = %0h\t afisare_locuri = %0h \t parcare_full = %0h",bariera,afisare_locuri, parcare_full);
    $display("-----------------------------------------");
  endfunction
  
  // Funcție pentru afișarea valorilor din tranzacție în mod explicit
    function void display();
    
    $display("\t bariera  = %0h\t afisare_locuri = %0h \t parcare_full = %0h",bariera,afisare_locuri, parcare_full);
    $display("-----------------------------------------");
  endfunction
  
 //operator de copiere a unui obiect intr-un alt obiect
  function transaction_out do_copy();
    transaction_out trans;
    trans = new();	// Creează o nouă instanță a tranzacției
    trans.bariera  = this.bariera; // Copiază semnalul barieră
    trans.afisare_locuri = this.afisare_locuri;
    trans.parcare_full = this.parcare_full;
    return trans;

  endfunction
endclass