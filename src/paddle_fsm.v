module paddle_fsm
#(
  parameter SCR_W = 30,
  parameter SCR_H = 20,
  parameter PADDLE_H = 6
)
(
  input wire CLK, // CLK 75MHz
  input wire RST, // Active high reset

  input wire        A_up, 
  input wire        A_down,
  input wire        B_up, 
  input wire        B_down,
	
  output reg [10:0] L_PADDLE_POSITION,
  output reg [10:0] R_PADDLE_POSITION
);

  reg [1:0] state;
  localparam IDLE      = 2'b00;
  localparam MOVE_UP   = 2'b01;
  localparam MOVE_DOWN = 2'b10;
  localparam NOTHING   = 2'b11;

  wire  L_paddle_condi_MoveD_Nothing = (L_PADDLE_POSITION+PADDLE_H-1 == SCR_H-2 );      // Bottom Border Condition
  wire  R_paddle_condi_MoveD_Nothing = (R_PADDLE_POSITION+PADDLE_H-1 == SCR_H-2 );      // Bottom Border Condition
  wire  L_paddle_condi_MoveU_Nothing = (L_PADDLE_POSITION == 1);						 // Top Border Condition
  wire  R_paddle_condi_MoveU_Nothing  = (R_PADDLE_POSITION == 1);				         // Top Border Condition
  wire  L_paddle_condi__Nothing_MoveD  = (A_down && !L_paddle_condi_MoveD_Nothing);
  wire  R_paddle_condi__Nothing_MoveD = (B_down && !R_paddle_condi_MoveD_Nothing);
  wire  L_paddle_condi__Nothing_MoveU = (A_up && !L_paddle_condi_MoveU_Nothing);
  wire  R_paddle_condi__Nothing_MoveU = (B_up && !R_paddle_condi_MoveU_Nothing);

  always @ (posedge CLK) begin
    if (RST) begin
      state <= IDLE;
    end else begin
      case (state)
        IDLE: begin
		L_PADDLE_POSITION <= SCR_H*85/256-1;
       		R_PADDLE_POSITION <= L_PADDLE_POSITION;
          	if(A_up) begin
	    		L_PADDLE_POSITION <= L_PADDLE_POSITION+1;
           		 state <= MOVE_UP;
          	end
         	 else if(A_down) begin	 
	    		L_PADDLE_POSITION <= L_PADDLE_POSITION-1;
            		state <= MOVE_DOWN;
          	end

	  	if(B_up) begin
	    		R_PADDLE_POSITION <= R_PADDLE_POSITION+1;
            		state <= MOVE_UP;
                 end
	         else if(B_down) begin	 
	    		R_PADDLE_POSITION <= R_PADDLE_POSITION-1;
            		state <= MOVE_DOWN;
         	 end
        end
        MOVE_DOWN: begin 
		   if(L_paddle_condi_MoveD_Nothing) begin
			   state <= NOTHING;
		   end
		   
		   else if(A_up) begin
			L_PADDLE_POSITION <= L_PADDLE_POSITION+1;
            		state <= MOVE_UP;
           	   end
		   else if(A_down) begin	 
			L_PADDLE_POSITION <= L_PADDLE_POSITION-1;
           		state <= MOVE_DOWN;
           	  end 
		  if(R_paddle_condi_MoveD_Nothing) begin
			  state <= NOTHING;  
		  end
		  else if(B_up) begin
			R_PADDLE_POSITION <= R_PADDLE_POSITION+1;
            		state <= MOVE_UP;
         	 end
		  else if(B_down) begin	 
			R_PADDLE_POSITION <= R_PADDLE_POSITION-1;
            		state <= MOVE_DOWN;
         	 end
        end
        MOVE_UP: begin
		  if(L_paddle_condi_MoveU_Nothing) begin
			  state <= NOTHING;  
		  end
		  else if(A_up) begin
			L_PADDLE_POSITION <= L_PADDLE_POSITION+1;
            		state <= MOVE_UP;
          	end
		  else if(A_down) begin	 
			L_PADDLE_POSITION <= L_PADDLE_POSITION-1;
            		state <= MOVE_DOWN;
         	 end 

		   if(R_paddle_condi_MoveU_Nothing) begin
			  state <= NOTHING;  
		  end
		  else if(B_up) begin
			R_PADDLE_POSITION <= R_PADDLE_POSITION+1;
            		state <= MOVE_UP;
         	 end
		  else if(B_down) begin	 
			R_PADDLE_POSITION <= R_PADDLE_POSITION-1;
            		state <= MOVE_DOWN;
         	 end
        end	
	NOTHING: begin
		  if(R_paddle_condi__Nothing_MoveD) begin	 
			R_PADDLE_POSITION <= R_PADDLE_POSITION-1;
            		state <= MOVE_DOWN;
         	 end	   
		  else if(R_paddle_condi__Nothing_MoveU) begin
			R_PADDLE_POSITION <= R_PADDLE_POSITION+1;
            		state <= MOVE_UP;
         	 end
		  if(L_paddle_condi__Nothing_MoveD) begin	 
			L_PADDLE_POSITION <= L_PADDLE_POSITION-1;
           		 state <= MOVE_DOWN;
         	 end	   
		  else if(L_paddle_condi__Nothing_MoveU) begin
			L_PADDLE_POSITION <= L_PADDLE_POSITION+1;
           		 state <= MOVE_UP;
          	end  
	end
      endcase
    end
  end
	  	  
endmodule