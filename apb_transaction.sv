
//aici se declara tipul de data folosit pentru a stoca datele vehiculate intre generator si driver; monitorul, de asemenea, preia datele de pe interfata, le recompune folosind un obiect al acestui tip de data, si numai apoi le proceseaza
class apb_transaction;
  //se declara atributele clasei
  //campurile declarate cu cuvantul cheie rand vor primi valori aleatoare la aplicarea functiei randomize()
  rand bit [1:0] addr;
  rand bit       wr_rd;
  rand bit [7:0] data;
  rand int       delay;
  
  //constrangerile reprezinta un tip de membru al claselor din SystemVerilog, pe langa atribute si metode
  //aceasta constrangere specifica faptul ca se executa fie o scriere, fie o citire
  //constrangerile sunt aplicate de catre compilator atunci cand atributele clasei primesc valori aleatoare in urma folosirii functiei randomize
  constraint delay_c{   delay inside {[1:15]};  }
  
  constraint address_c;
  
  //aceasta functie este apelata dupa aplicarea functiei randomize() asupra obiectelor apartinand acestei clase
  //aceasta functie afiseaza valorile aleatorizate ale atributelor clasei
  function void post_randomize();
    $display("--------- [Trans] post_randomize ------");
    //$display("\t addr  = %0h",addr);
    if(wr_rd) $display("\t addr  = %0h\t wr_rd = %0h\t data = %0h\t delay= %0d 						",addr,wr_rd,data, delay);
    else
      $display("\t addr  = %0h\t wr_rd = %0h\t delay= %0d",addr,wr_rd, delay);
    $display("-----------------------------------------");
  endfunction
  
    function void display();
    //$display("\t addr  = %0h",addr);
      if(wr_rd) $display("\t addr  = %0h\t wr_rd = %0h\t data = %0h \t delay = %0d",addr,wr_rd,data, delay);
    else
      $display("\t addr  = %0h\t wr_rd = %0h  \t delay = %0d",addr,wr_rd, delay);
    $display("-----------------------------------------");
  endfunction
  
  //operator de copiere a unui obiect intr-un alt obiect (deep copy)
  function apb_transaction do_copy();
    apb_transaction trans;
    trans = new();
    trans.addr  = this.addr;
    trans.wr_rd = this.wr_rd;
    trans.data = this.data;
	trans.delay = this.delay;
    return trans;
  endfunction
endclass