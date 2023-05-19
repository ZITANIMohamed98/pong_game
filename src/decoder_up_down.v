module decoder_up_down
(
  input wire CLK, // CLK 75MHz
  input wire RST, // Active high reset

  input wire        Enc_QA, 
  input wire        Enc_QB,
	
  output reg up,
  output reg down
);
reg [3:0] state;
localparam IDLE    = 4'b0000;
localparam T1    = 4'b0001;
localparam T2    = 4'b0010;
localparam T3    = 4'b0011;


localparam CT1  = 4'b0111;
localparam CT2  = 4'b1000;
localparam CT3  = 4'b1001;



wire condi_IDLE_T1= (Enc_QB && !Enc_QA);
wire condi_T1_T2 = (!Enc_QB && !Enc_QA);
wire condi_T2_T3 = (!Enc_QB && Enc_QA);
wire condi_T3_T4 = (Enc_QB && Enc_QA);

wire condi_IDLE_CT1 = (!Enc_QB && Enc_QA);
wire condi_CT1_CT2 = (!Enc_QB && !Enc_QA);
wire condi_CT2_CT3 = (Enc_QB && !Enc_QA);
wire condi_CT3_CT4 = (Enc_QB && Enc_QA);

always @ (posedge(CLK) or posedge(RST)) begin
      if(RST) begin 
		up <= 0;
       		down <= 0;
        	state <= IDLE;

	end else begin
      case (state)
        IDLE: begin
	   if(condi_IDLE_T1) begin        //clockwise direction
		state <= T1;
		up <= 0; 
	   end
	   else if(condi_IDLE_CT1) begin   //counter clockwise direction
		state <= CT1;
		down <= 0; 
	   end
	   else begin
		up <= 0; 
      	   	down <= 0;
          	state <= IDLE;
	   end
        end
	T1: begin
		 if(condi_IDLE_T1) begin        //clockwise direction
			state <= T1;
			up <= 0; 
	   	end
		 else if(condi_T1_T2) begin        //clockwise direction
			state <= T2;
			up <= 0; 
	   	end
		else begin 
			state<=IDLE;
			up <= 0; 
		end
	end
	T2: begin
		 if(condi_T1_T2) begin        //clockwise direction
			state <= T2;
			up <= 0; 
	   	end
		else if(condi_T2_T3) begin        //clockwise direction
			state <= T3;
			up <= 0; 
	   	end
		else begin 
			state<=IDLE;
			up <= 0; 
		end
	end
	
	T3: begin
		if(condi_T2_T3) begin        //clockwise direction
			state <= T3;
			up <= 0; 
	   	end
		else if(condi_T3_T4) begin        //clockwise direction
			up<=1;
			state<=IDLE;
	   	end
		else begin 
			state<=T3;
			up <= 0; 
		end
	end
	
	CT1: begin
		if(condi_IDLE_CT1) begin   //counter clockwise direction
		state <= CT1; 
		down <= 0;
	   	end
		else if(condi_CT1_CT2) begin        //counter-clockwise direction
			state <= CT2;
			down <= 0;
	   	end
		else begin 
			state<=IDLE;
			down <= 0;
		end
	end
	CT2: begin
		if(condi_CT1_CT2) begin        //counter-clockwise direction
			state <= CT2;
			down <= 0;
	   	end
		else if(condi_CT2_CT3) begin        //counter-clockwise direction
			state <= CT3;
			down <= 0;
	   	end
		else begin 
			state<=IDLE;
			down <= 0;  
		end
	end
	
	CT3: begin
		if(condi_CT2_CT3) begin        //counter-clockwise direction
			state <= CT3;
			down <= 0;
	   	end
		else if(condi_CT3_CT4) begin        //counter-clockwise direction
			down<=1;
			state<=IDLE;
	   	end
		else begin 
			state<=IDLE;
			down <= 0;
		end
	end
	
endcase
end
end
endmodule

