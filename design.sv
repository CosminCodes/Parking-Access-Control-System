module parcare #(
)(
input clk,
input rst_n,

output logic	     bariera,
output logic [8-1:0] afisare_locuri,
output logic		 parcare_full,

input 		 [3-1:0] Paddr,  //2 biti?
input 				 Pwrite,
input 				 Psel,
input 				 Penable,
input  		 [8-1:0] Pwdata,
output logic [8-1:0] Prdata,
output logic 		 Pready,
output logic 		 Pslverr
);

reg[8-1:0] reg_locuri_parcare_totale;  //Adresa 0 //255locuri disponibile
reg[8-1:0] reg_locuri_ocupate;    	   //Adresa 1
reg[8-1:0] reg_acces;    			   //Adresa 2
wire intrare;
wire iesire;
  
//assign reg_locuri_parcare_totale = 255;
assign intrare = reg_acces[0];
assign iesire  = reg_acces[1];  
  
//scrierea registrilor prin APB
 always @(posedge clk or negedge rst_n)
    if (~rst_n) begin
    reg_locuri_parcare_totale <= 'd255;
    reg_locuri_ocupate <= 0;
    end
    else 
    if(Pwrite == 1 && Psel == 1 && Penable == 0)
    case(Paddr)
      0:reg_locuri_parcare_totale<=Pwdata;
      1:$warning("registru disponibil numai pentru citire");
      2:reg_acces<=Pwdata;
      default: $warning("adresa invalida");
    endcase  
	
//REGISTRUL DE reg_acces se scrie separat deoarece bitii 1 si 0 au o functionalitate speciala
always @(posedge clk or negedge rst_n)
    if (~rst_n) begin
    reg_acces <= 0;
    end
    else 
      if(Pwrite == 1 && Psel == 1 && Penable == 0 && Paddr ==2)
		reg_acces <=Pwdata;
      else begin
        if(reg_acces[0] == 1)
          reg_acces[0] <= 0;
        if(reg_acces[1] == 1)
          reg_acces[1] <= 0;
      end
 
// citirea registrilor prin APB
 always @(posedge clk or negedge rst_n)
    if (~rst_n) 
		Prdata <= 0;
	else begin
      if(Psel && !Penable && !Pwrite)begin
        case (Paddr)
			0: Prdata <= reg_locuri_parcare_totale;
			1: Prdata <= reg_locuri_ocupate;
          	2: Prdata <= reg_acces;
			default: $warning("adresa nealocata");
		endcase
      end
    end
	
//Modelarea semnalului de eroare	
//"1" cand se aceseaza o adresa care nu este asignata unui registru
always @(posedge clk or negedge rst_n)
	if (~rst_n)
		Pslverr <= 0;
	else 
	  if(Pslverr)
	  	Pslverr <= 0;
  	  else if(Psel == 1 && Penable == 0 && Paddr > 2)
		Pslverr <= 1;
	
//Modelarea semnalului Pready
//Arata ca DUT ul acepta tranzactia si se activeaza tt timpul in al 2lea tact al tranzactiei	
always @(posedge clk or negedge rst_n)
	if (~rst_n)
		Pready <= 0;
	else 
	  if(Pready)
	  	Pready <= 0;
	  else if(Psel == 1 && Penable == 0 )
		Pready <= 'b1;
	
	

//bariera
// 1 = bariera sus
// 0 = bariera jos

//Ridicare/coborare bariera
//Daca o masina vrea sa iasa sau sa intre bariera se ridica
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)
      bariera <= 'b0;
  if(intrare && !parcare_full)
    bariera <= 'b1;
  else
    if(iesire)
      bariera <= 'b1;
    else
     if(!intrare && !iesire)
      bariera <= 'b0;
end  

//Parcare full
//Ne indica daca parcarea nu mai are locuri libere
//Se compara cu (>=) in cazul in care valoarea "reg_locuri_parcare_totale" este modificat
  always @(posedge clk or negedge rst_n)begin
    if (~rst_n)
      parcare_full <= 0;
    else
      if (reg_locuri_ocupate >= reg_locuri_parcare_totale)
        parcare_full <= 'b1;
    else 
       parcare_full <= 'b0;
  end
  
  
 //Afisam la orice moment numarul de masini prezente in parcare
	assign afisare_locuri = reg_locuri_ocupate;


  //Partea de contorizare a locuriler ocupate din parcare
always @(posedge clk or negedge rst_n)begin
    if (~rst_n) 
		   reg_locuri_ocupate <= 'b0;      
		else //iesirea este prioritara fata de intrare
      if(iesire && reg_locuri_ocupate > 0)begin
			reg_locuri_ocupate <= reg_locuri_ocupate - 'b1;
        	
      end
		//cand bariera nu este deschisa se ignora 
		  else           
            if(intrare && reg_locuri_ocupate<reg_locuri_parcare_totale)begin 
				reg_locuri_ocupate <= reg_locuri_ocupate + 'b1;
            end
end
endmodule