module drawer
#(
  parameter SCR_W = 30,
  parameter SCR_H = 20,
  parameter BALL_W = 2,
  parameter BALL_H = 2,
  parameter PADDLE_H = 6
)
(
  input wire CLK, // CLK 75MHz
  input wire RST, // Active high reset
  
  input wire [3:0]  R_SCORE,
  input wire [3:0]  L_SCORE,
  input wire        GAME_OVER,
  input wire [10:0] H_CNT, // horizontal pixel pointer
  input wire [10:0] V_CNT, // vertical   pixel pointer

  input wire [10:0] H_BALL_POSITION,
  input wire [10:0] V_BALL_POSITION,

  input wire [10:0] L_PADDLE_POSITION,
  input wire [10:0] R_PADDLE_POSITION,

  output reg [7:0] RED,
  output reg [7:0] GREEN,
  output reg [7:0] BLUE
);

  reg [3:0] state;
  localparam IDLE      = 2'b00;
  localparam PLAYING   = 2'b01;
  localparam GAMEOVER = 2'b10;
  localparam INITIAL_BALL_H = (SCR_W>>1)-1;
  localparam INITIAL_BALL_V = (SCR_H>>1)-1;
  localparam INITIAL_PADDLE  = SCR_H*85/256-1; 
  
  always @ (posedge CLK) begin
    if (RST) begin
      state <= IDLE;
    end 
    else if (GAME_OVER) begin
	   state<=GAMEOVER;
	  end
    else begin
	 case (state)	
	//--------------------------------------------------------------------------------------------------------------------------
        IDLE: begin		    //Static state 	
		  
	if((H_CNT == INITIAL_BALL_H && V_CNT == INITIAL_BALL_V) || (H_CNT == INITIAL_BALL_H+1 && V_CNT == INITIAL_BALL_V) || (H_CNT == INITIAL_BALL_H && V_CNT == INITIAL_BALL_V+1) || (H_CNT == INITIAL_BALL_H+1 && V_CNT == INITIAL_BALL_V+1))	  // Ball size equal to 2 but I'll change this line after
	          begin
			 assign RED = 8'hFF;			 //Ball
		         assign GREEN = 8'hFF;
		         assign BLUE = 8'hFF; 
			  end
        else if((H_CNT== 2 && (V_CNT>=INITIAL_PADDLE && V_CNT<INITIAL_PADDLE+PADDLE_H)) || (H_CNT== SCR_W-3 && (V_CNT>=R_PADDLE_POSITION || V_CNT<R_PADDLE_POSITION+PADDLE_H))) begin
		     assign RED = 8'hFF;
		     assign GREEN = 8'hFF;
		     assign BLUE = 8'hFF; 			   //Paddle
		end
	//--------------------------------------------------------------------------------------------------------------------------
          else if (H_CNT == 0 || V_CNT == 0 || H_CNT == SCR_W - 1 || V_CNT == SCR_H - 1) begin 
	     assign RED = 8'hFF;
             assign GREEN = 8'hFF;		//Game Borders
             assign BLUE = 8'hFF;
          end	
          else
	    begin 
	     assign RED = 8'h00;
             assign GREEN = 8'h00;		//Game Borders
             assign BLUE = 8'h00;
          end	
				 
//		  else if((H_CNT == H_BALL_POSITION && V_CNT == V_BALL_POSITION) || (H_CNT == H_BALL_POSITION+1 && V_CNT == V_BALL_POSITION) || (H_CNT == H_BALL_POSITION && V_CNT == V_BALL_POSITION+1) || (H_CNT == H_BALL_POSITION+1 && V_CNT == V_BALL_POSITION+1))	  // Ball size equal to 2 but I'll change this line after
//          begin
//			 assign RED = 8'hFF;			 //Ball
//	         assign GREEN = 8'hFF;
//	         assign BLUE = 8'hFF; 
//		  end
//		  else if((H_CNT== 2 && V_CNT>=L_PADDLE_POSITION && V_CNT<L_PADDLE_POSITION+PADDLE_H) || (H_CNT== SCR_W-3 && V_CNT>=R_PADDLE_POSITION && V_CNT<R_PADDLE_POSITION+PADDLE_H)) begin
//		     assign RED = 8'hFF;
//		     assign GREEN = 8'hFF;
//		     assign BLUE = 8'hFF; 			   //Paddle
//		  end 
//		  else begin
//			 assign RED = 8'h00;
//          	 assign GREEN = 8'h00;
//             assign BLUE = 8'h00;
//		  end	 
		  // TODO: implement initial score display Left and right
       end	  
	//--------------------------------------------------------------------------------------------------------------------------
       PLAYING: begin		
		   if((H_CNT == H_BALL_POSITION && V_CNT == V_BALL_POSITION) || (H_CNT == H_BALL_POSITION+1 && V_CNT == V_BALL_POSITION) || (H_CNT == H_BALL_POSITION && V_CNT == V_BALL_POSITION+1) || (H_CNT == H_BALL_POSITION+1 && V_CNT == V_BALL_POSITION+1))	  // Ball size equal to 2 but I'll change this line after
	          begin
		      assign RED = 8'hFF;			 //Ball
		      assign GREEN = 8'hFF;
		      assign BLUE = 8'hFF; 
			  end
		    else if((H_CNT== 2 && V_CNT>=L_PADDLE_POSITION && V_CNT<L_PADDLE_POSITION+PADDLE_H) || (H_CNT== SCR_W-3 && V_CNT>=R_PADDLE_POSITION && V_CNT<R_PADDLE_POSITION+PADDLE_H)) begin
		     assign RED = 8'hFF;
		     assign GREEN = 8'hFF;
		     assign BLUE = 8'hFF; 			   //Paddle
			end	
			 // TODO: implement score display Left and right
			end
    //--------------------------------------------------------------------------------------------------------------------------
        GAMEOVER: begin
          // TODO: implement end of game behavior 
        end
      endcase
    end
  end
	  	  
endmodule