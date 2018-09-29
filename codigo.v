module ff ( input data, input c, input r, output q);
reg q;
always @(posedge c or negedge r) 
begin
 if(r==1'b0)
  q <= 1'b0; 
 else 
  q <= data; 
end 
endmodule //End 

// FSM alto nível com Case
module statem(clk, reset, a, saida);

input clk, reset, a;
output [2:0] saida;
reg [2:0] state;
parameter zero=3'd2, dois=3'd3, tres=3'd7, quatro=3'd4, cinco =3'd5;

assign saida = (state == zero)? 3'd0:
	(state == dois)? 3'd2:
	(state == tres)? 3'd3:
	(state == quatro)? 3'd4:3'd5;

always @(posedge clk or negedge reset)
     begin
          if (reset==0)
               state = zero;
          else
               case (state)
                    zero: state = tres;
                    tres: if ( a == 1 ) state = cinco;
			  else state = dois;
                    quatro: if ( a == 1 ) state = tres;
			  else state = zero;
                    dois: state = quatro;
                    cinco: state = dois;
               endcase
     end
endmodule // End

// FSM com portas logicas
module statePorta(input clk, input res, input a, output [2:0] s);

wire [2:0] e;
wire [2:0] p;

assign p[0]  =  e[1]&~e[0] | e[2]&e[0] | a&~e[1]; // 7 portas
assign p[1]  =  e[2]&~a | ~e[1] | ~e[0]; // 6 portas
assign p[2] =   ~e[0]&a | ~e[2]&e[1] | e[1]&a; // 7 portas
assign s[0] = e[2]&e[0]; // 1 portas
assign s[1] = e[1]&e[0]; // 1 portas
assign s[2] = e[2]&~e[1]; // 2 portas
// Total de portas lógicas = 24

ff  e0(p[0],clk,res,e[0]);
ff  e1(p[1],clk,res,e[1]);
ff  e2(p[2],clk,res,e[2]);

endmodule // End 

// FSM com memoria
module stateMem(input clk,input res, input a, output [2:0] saida);

reg [5:0] StateMachine [0:15]; // 16 linhas e 6 bits de largura

initial
begin
	StateMachine[0] = 6'h10;  StateMachine[1] = 6'h10; // inicializa no estado zero, PE = 010 e saída = 000
	StateMachine[4] = 6'h38;  StateMachine[5] = 6'h38;
	StateMachine[6] = 6'h22;  StateMachine[7] = 6'h22;
	StateMachine[8] = 6'h14;  StateMachine[9] = 6'h3c;
	StateMachine[10] = 6'h1d;  StateMachine[11] = 6'h1d;
	StateMachine[14] = 6'h1b;  StateMachine[15] = 6'h2b;
end

wire [3:0] address;  // 16 linhas = 4 bits de endereco
wire [5:0] dout; // 6 bits de largura 3+3 = proximo estado + saida

assign address[0] = a;
assign dout = StateMachine[address];
assign saida = dout[2:0];

ff st0(dout[3],clk,res,address[1]);
ff st1(dout[4],clk,res,address[2]);
ff st2(dout[5],clk,res,address[3]);

endmodule // End

// Principal
module main;

reg c,res,a;
wire [2:0] saida;
wire [2:0] saida1;
wire [2:0] saida2;

statem FSM(c,res,a,saida);
statePorta FSM1(c,res,a,saida1);
stateMem FSM2(c,res,a,saida2);


initial
    c = 1'b0;
  always
    c= #(1) ~c;

// visualizar formas de onda usar gtkwave out.vcd
initial  begin
     $dumpfile ("out.vcd"); 
     $dumpvars; 
   end 

  initial 
    begin
     $monitor($time," c %b res %b a %b s %d smem %d sporta %d ",c,res,a,saida,saida2,saida1);
      #1 res=0; a=0;
      #1 res=1;
      #8 a=1;
      #16 a=0;
      #12 a=1;
      #4;
      $finish ;
    end
endmodule

