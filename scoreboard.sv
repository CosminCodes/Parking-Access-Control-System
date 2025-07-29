//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
//scoreboardul preia datele de la monitor si verifica acuratetea acestora; pentru a se face aceasta verificare, in scoreboard este implementata functionalitatea DUT-ului; intrarile pe care le primeste DUT-ul sunt preluate de catre monitor si transmise scoreboardului; comparandu-se iesirile monitorului si ale scoreboardului se poate determina daca acestea functioneaza corect

//the scoreboard gets the packet from monitor, generates the expected result and compares with the //actual result recived from Monitor

class scoreboard;
   
  //se declara portul prin care scoreboardul primeste date de la monitor; daca sunt mai multe monitoare, se pot declara mai multe porturi de acest tip
  //creating mailbox handle
  mailbox mon2scb;
  mailbox out_mon2scb;
  
  //creating virtual interface handle
  virtual apb_intf apb_if;
  virtual out_intf out_if;
  
  
  logic [7:0] locuri_parcare_totale = 8'b11111111; 		//Adresa 0 //255locuri disponibile
  logic [7:0] locuri_ocupate 		= 8'b00000000; 		//Adresa 1 READ ONLY
  logic [7:0] acces					= 8'b00000000; 		//ADRESA 2
  bit intrare;
  bit iesire;
  
  //used to count the number of transactions
  int no_transactions;
  
  //constructor
  function new(virtual apb_intf apb_if,
               virtual out_intf out_if,
               mailbox mon2scb, 
               mailbox out_mon2scb);
    this.apb_if = apb_if;
    this.out_if = out_if;
    this.mon2scb = mon2scb;
    this.out_mon2scb = out_mon2scb;
  endfunction
  
  //MAIN
  task main;
    apb_transaction apb_trans;
    transaction_out out_trans;
    
    forever begin
      mon2scb.get(apb_trans);
      out_mon2scb.get(out_trans);
      
      
      //WRITE
      if(apb_trans.wr_rd) begin
        case (apb_trans.addr) 
          //0
          0: begin
            locuri_parcare_totale <= apb_trans.data;
            calc_locuri();
          end
          //1
          1: begin
            $error("[%0t] --------  [SCB]  --------\nSe incearca scrierea la registrul de la adresa 1, care este registru de tip 														READ-ONLY!", $time);
            if (!apb_if.pslverr)
              $error("[%0t] --------  [SCB]  --------\nS-a efectuat o operatie de scriere la un registru de tip READ-ONLY, dar 															semnalul PSLVERR nu e asertat!", $time);
          end
          //2
          2: begin
            $display ("[%0t]DEBUG apb_trans.data=%0h",$time, apb_trans.data);

            acces = apb_trans.data;
            intrare = acces[0];
            iesire = acces[1];
            $display ("[%0t]DEBUG intrare=%0h",$time,intrare);
            $display ("[%0t]DEBUG  iesire=%0h",$time, iesire);
      //      if (intrare) begin
      //        locuri_ocupate++;
      //      end
      //      if (iesire) begin
      //        locuri_ocupate--;
      //      end
            
            calc_locuri();
     
            @(posedge apb_if.clk);
            
            $display ("[%0t]DEBUG  just for time",$time);
            intrare =0;
    		iesire =0;
   			acces[0] = 0;
    		acces[1] = 0;
          end
          default: begin
            $error("[%0t] --------  [SCB]  --------\nSe incearca scrierea la registrul de la adresa 1, care este registru de tip READ-ONLY!", $time);
            if (!apb_if.pslverr)
              $error("[%0t] --------  [SCB]  --------\nS-a efectuat o operatie de scriere la un registru de tip READ-ONLY, dar semnalul PSLVERR nu e asertat!", $time);
          end
        endcase
      end
      
      //READ
      else  begin
        case (apb_trans.addr) 
          0: begin
            if (apb_trans.data != locuri_parcare_totale) 
              $error("[%0t] --------  [SCB]  --------\nIn registrul 	locuri_parcare_totale 	se gaseste valoarea %0d, dar trebuia sa fie valoarea %0d", $time, apb_trans.data, locuri_parcare_totale);
          end
          
          1: begin
              $error("[%0t] --------  [SCB]  --------\nIn registrul 	locuri_ocupate 	se gaseste valoarea %0d, dar trebuia sa fie valoarea %0d", $time, apb_trans.data, locuri_ocupate);            
          end
          2: begin
            $error("[%0t] --------  [SCB]  --------\nIn registrul 	acces 	se gaseste valoarea %0d, dar trebuia sa fie valoarea %0d", $time, apb_trans.data, acces);  
          end
        endcase
      end

      no_transactions++;
    end
  endtask
  
  
  task calc_locuri();
    
    $display("\n\n\nlalala\n\n");
    $display ("[%0t]locuri par tot=%0d",$time, locuri_parcare_totale);
    $display ("locuri_ocupate=%0d", locuri_ocupate);
    $display ("intrare=%0d", intrare);
    $display ("iesire=%0d", iesire);
    $display ("out_if.bariera=%0d", out_if.bariera); 
    $display ("\n");

    
    
    if (locuri_parcare_totale == locuri_ocupate) begin
      if (intrare && out_if.bariera)
        $error("[%0t] --------  [SCB]  --------\nBariera s-a deschis pentru a intra o masina chiar daca parcarea era full", $time);  
      if (iesire) begin
       	locuri_ocupate --;
        if (!out_if.bariera)
          $error("[%0t] --------  [SCB]  --------\nO masina a dorit sa iasa din parcare dar bariera nu s-a deschis!", $time);  
      end
    end
    else begin
      if (locuri_parcare_totale > locuri_ocupate) begin
        if (intrare) begin
          locuri_ocupate++;
          if (!out_if.bariera)
            $error("[%0t] --------  [SCB]  --------\nO masina a dorit sa intre din parcare cand inca mai erau locuri disponibile dar bariera nu s-a deschis!", $time);    
        end
        if(iesire) begin
          locuri_ocupate--;
           if (!out_if.bariera) 
          	 $error("[%0t] --------  [SCB]  --------\nO masina a dorit sa iasa din parcare dar bariera nu s-a deschis!", $time); 
        end
      end
      
      //locuri_parcare_totale < locuri_ocupate
      else
        $error("[%0t] --------  [SCB]  --------\nSunt mai multe locuri de parcare ocupate decat sunt locuri de parcare disponibile in total!", $time);  
    end

  endtask
  
endclass