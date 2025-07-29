//prin coverage, putem vedea ce situatii  au fost generate in simulare; astfel putem masura stadiul la care am ajuns cu verificarea
class coverage_out;
  
  transaction_out trans_covered;
  

  covergroup transaction_cg;
    //linia de mai jos este adaugata deoarece, daca sunt mai multe instante pentru care se calculeaza coverage-ul, noi vrem sa stim pentru fiecare dintre ele, separat, ce valoare avem.
    option.per_instance = 1;
bariera_cp: coverpoint trans_covered.bariera {
  bins open = {1};
  bins closed = {0};
}  //Verifica daca bariera a fost inchisa sau deschisa
    
   parcare_full_cp: coverpoint trans_covered.parcare_full {
      bins full = {1};
      bins not_full = {0};
    }
    
    afisare_locuri_cp: coverpoint trans_covered.afisare_locuri {
      bins big_values = {[191:254]};
      bins medium_values = {[127:190]};
      bins low_values = {[1:10]};
      bins lowest_value = {0};
      bins highest_value = {255};
      bins other_possibilities = default;
    }
    // bin-ul other_possibilities este important deoarece vrem sa vedem ca au fost trimise tranzactii si la adrese care nu apartin unor registrii
    
    parcare_full_afisare_locuri_cx: cross parcare_full_cp, afisare_locuri_cp{
      illegal_bins c6 = parcare_full_afisare_locuri_cx with (parcare_full_cp == 0 && afisare_locuri_cp == 255);
      bins ok = parcare_full_afisare_locuri_cx with (afisare_locuri_cp >0 && afisare_locuri_cp <5 && parcare_full_cp == 0);
    }
    
    bariera_parcare_full_cx: cross bariera_cp, parcare_full_cp;
    
  endgroup
  
//se creaza grupul de coverage; ATENTIE! Fara functia de mai jos, grupul de coverage nu va putea esantiona niciodata date deoarece pana acum el a fost doar declarat, nu si creat
  function new();
    transaction_cg = new();   // Instanțiază covergroup-ul
  endfunction
  
  task sample(transaction_out trans_covered); 
  	this.trans_covered = trans_covered; // Setează tranzacția curentă
  	transaction_cg.sample(); // Face sample pe valorile curente
  endtask:sample   
  
  function print_coverage();
    $display("Valori pentru interfata de iesire:");
   $display ("parcare_full coverage = %.2f%%", transaction_cg.parcare_full_cp.get_coverage());
   $display ("afisare_locuri coverage = %.2f%%", transaction_cg.afisare_locuri_cp.get_coverage());
    $display ("bariera coverage = %.2f%%", transaction_cg.bariera_cp.get_coverage());
  endfunction

endclass: coverage_out

