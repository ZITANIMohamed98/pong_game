module paddle_fsm
#(
  parameter SCR_W = 30,
  parameter SCR_H = 20,
  parameter PADDLE_H = 6
)
(
  input wire CLK, // CLK 75MHz
  input wire RST, // Active high reset

  input wire        up, 
  input wire        down,
	
  output reg [10:0] PADDLE_POSITION
);

  wire  paddle_condi_MoveD_Nothing = (PADDLE_POSITION+PADDLE_H-1 == SCR_H-2 );      // Bottom Border Condition
  wire  paddle_condi_MoveU_Nothing = (PADDLE_POSITION == 1);						 // Top Border Condition
  wire  paddle_condi__Nothing_MoveD  = (down && !paddle_condi_MoveD_Nothing);
  wire  paddle_condi__Nothing_MoveU = (up && !paddle_condi_MoveU_Nothing);
  always @ (posedge up or posedge down or posedge RST ) begin
    if (RST) begin
      PADDLE_POSITION <= SCR_H*85/256-1; 
    end else begin
     if(paddle_condi__Nothing_MoveU) begin
		PADDLE_POSITION <= PADDLE_POSITION-1;	
          end
      else if(paddle_condi__Nothing_MoveD ) begin	 
	    	PADDLE_POSITION <= PADDLE_POSITION+1;
            	
          	end
      else begin
		PADDLE_POSITION <= PADDLE_POSITION;
	end	
	
    end
  end
	  	  
endmodule