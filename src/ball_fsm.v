module ball_fsm
#(
  parameter SCR_W = 30,
  parameter SCR_H = 20,
  parameter BALL_W = 2,
  parameter BALL_H = 2,
  parameter PADDLE_H = 6,
  parameter MAX_SCORE = 9
)
(
  input wire CLK, // CLK 75MHz
  input wire RST, // Active high reset

  input wire [10:0] H_CNT, // horizontal pixel pointer
  input wire [10:0] V_CNT, // vertical   pixel pointer
  
  input wire        A_up, 
  input wire        A_down, 
  input wire        Button_A,
  input wire        B_up,
  input wire        B_down,
  input wire        Button_B,

  input wire [10:0] L_PADDLE_POSITION,
  input wire [10:0] R_PADDLE_POSITION,
  
  output reg [10:0] H_BALL_POSITION,
  output reg [10:0] V_BALL_POSITION,  
  output reg        GAME_OVER,
  output wire [3:0]  R_SCORE,  
  output wire [3:0]  L_SCORE
);
 //-----------------------------------------------------------------------------------------------------------------
  reg [3:0] state;	
  reg [3:0] r_score; 
  reg [3:0] l_score;
  localparam COMPETITION  = 4'b0000;
  localparam SERVE_L      = 4'b0001;
  localparam SERVE_R      = 4'b0010;
  localparam BR_DIRECTION = 4'b0011;
  localparam BL_DIRECTION = 4'b0100;
  localparam TR_DIRECTION = 4'b0101;
  localparam TL_DIRECTION = 4'b0110;
  localparam L_SCORED     = 4'b1000;
  localparam R_SCORED     = 4'b1001;
  localparam INITIAL_BALL_H = (SCR_W>>1)-1;
  localparam INITIAL_BALL_V = (SCR_H>>1)-1;

  wire condi_BR_TR 		= (V_BALL_POSITION==SCR_H-2); 				//hit bottom border
  wire condi_BR_BL 		= (H_BALL_POSITION+BALL_W-1==SCR_W-4 && V_BALL_POSITION+BALL_W-1>=R_PADDLE_POSITION && V_BALL_POSITION<=R_PADDLE_POSITION+PADDLE_H);   //hit right paddle
  wire condi_TR_BR 		= (V_BALL_POSITION==1);					// hit top border
  wire condi_TR_TL	        = (condi_BR_BL);  		 //hit right paddle
  wire condi_BL_TL 		= (V_BALL_POSITION==SCR_H-2);                          //hit bottom border
  wire condi_BL_BR 		= (H_BALL_POSITION==3 && V_BALL_POSITION>=L_PADDLE_POSITION && V_BALL_POSITION<=L_PADDLE_POSITION+PADDLE_H);  		 //hit left paddle
  wire condi_TL_BL 		= (V_BALL_POSITION==1);                                      // hit top border
  wire condi_TL_TR            = (condi_BL_BR);		//hit left paddle
  wire condi_Left_Score     = (H_BALL_POSITION==SCR_W-1);
  wire condi_Right_Score   = (H_BALL_POSITION==0);
 //-----------------------------------------------------------------------------------------------------------------
 
  always @ (posedge CLK or posedge RST or posedge Button_A or posedge Button_B or posedge A_up or posedge A_down or posedge B_up or posedge B_down) begin
    if (RST) begin
      H_BALL_POSITION <= INITIAL_BALL_H;
      V_BALL_POSITION <= INITIAL_BALL_V;
      r_score <= 0;
      l_score <= 0;
      state <= COMPETITION;
    end else begin
	  case (state)	  
	//-----------------------------------------------------------------------------------------------------------------
        COMPETITION: begin			    // Competition state: decide which player will serve.
         	H_BALL_POSITION <= INITIAL_BALL_H;
      		V_BALL_POSITION <= INITIAL_BALL_V;
		r_score <= 0;
      		l_score <= 0;
	 	if(Button_A) begin
            		state <= SERVE_L;
         	 end
	  	else if(Button_B) begin
            		state <= SERVE_R;
          	end
        end					  
	//-----------------------------------------------------------------------------------------------------------------
        SERVE_L: begin 
          	if(A_up) begin		// Left Player to serve Based on paddle movement the ball goes top right or bottom right
            		H_BALL_POSITION <= INITIAL_BALL_H;
          	        V_BALL_POSITION <= INITIAL_BALL_V;
	   	 	state <= TR_DIRECTION;
         	 end
	  	else if(A_down) begin
	    		H_BALL_POSITION <= INITIAL_BALL_H;
          	        V_BALL_POSITION <= INITIAL_BALL_V;
            		state <= BR_DIRECTION;
         	 end
		 else begin
			H_BALL_POSITION <= INITIAL_BALL_H;
          	        V_BALL_POSITION <= INITIAL_BALL_V;
			state <=SERVE_L;
		 end
        end			
	//-----------------------------------------------------------------------------------------------------------------
        SERVE_R: begin				  // Right Player to serve Based on paddle movement the ball goes top left or bottom left	  
         	 if(B_up) begin	
			H_BALL_POSITION <= INITIAL_BALL_H;
          	        V_BALL_POSITION <= INITIAL_BALL_V;
            		state <= TL_DIRECTION;
         	 end
		  else if(B_down) begin
			H_BALL_POSITION <= INITIAL_BALL_H;
          	        V_BALL_POSITION <= INITIAL_BALL_V;
            		state <= BL_DIRECTION;
        	  end
		 else begin
			H_BALL_POSITION <= INITIAL_BALL_H;
          	        V_BALL_POSITION <= INITIAL_BALL_V;
			state <=SERVE_R;
		 end
        end			  
	//-----------------------------------------------------------------------------------------------------------------
        TR_DIRECTION: begin
          	if(condi_TR_TL)	
                 begin
		    	V_BALL_POSITION <= V_BALL_POSITION - 1;
		    	H_BALL_POSITION <= H_BALL_POSITION - 1;
	            	state <= TL_DIRECTION;
		  end 
		  else if(condi_TR_BR)
		    begin
		    	V_BALL_POSITION <= V_BALL_POSITION + 1;
		    	H_BALL_POSITION <= H_BALL_POSITION + 1;
           	   	 state <= BR_DIRECTION;	
		  end 
		  else if(condi_Left_Score) begin		//Left Player Score condition 
			  state <= L_SCORED;
		  end else begin 
		  	V_BALL_POSITION <= V_BALL_POSITION - 1;
			H_BALL_POSITION <= H_BALL_POSITION + 1;
			state <= TR_DIRECTION;	
			 end	   
        end			  
	//-----------------------------------------------------------------------------------------------------------------
		BR_DIRECTION: begin
          		if(condi_BR_BL)	
         		 begin
		   	    	V_BALL_POSITION = V_BALL_POSITION + 1;
				H_BALL_POSITION = H_BALL_POSITION - 1;
	            		state <= BL_DIRECTION;
		 	 end 
		  	else if(condi_BR_TR)
			  begin
		  		V_BALL_POSITION <= V_BALL_POSITION - 1'b1;
				H_BALL_POSITION <= H_BALL_POSITION + 1'b1;
				state <= TR_DIRECTION;
		  	end 
			else if(condi_Left_Score) begin          // Left Player Score condition
			  state <= L_SCORED;
			  end  else begin 
		  		V_BALL_POSITION <= V_BALL_POSITION + 1;
				H_BALL_POSITION <= H_BALL_POSITION + 1;
           	   		 state <= BR_DIRECTION;	
			  end		 
        end					  
	//-----------------------------------------------------------------------------------------------------------------
		TL_DIRECTION: begin
         		 if(condi_TL_TR)	
          		 begin
		   	   	 V_BALL_POSITION <= V_BALL_POSITION - 1'b1;
			    	 H_BALL_POSITION <= H_BALL_POSITION + 1'b1;
				state <= TR_DIRECTION;
		 	 end 
			  else if(condi_TL_BL)
			  begin
		  		V_BALL_POSITION <= V_BALL_POSITION + 1;
				H_BALL_POSITION <= H_BALL_POSITION - 1;
	            		state <= BL_DIRECTION;
				
		  	end 
			else if(condi_Right_Score) begin                                       // Right Player Score condition  
			  state <= R_SCORED;
		      	end else begin 
		  		V_BALL_POSITION <= V_BALL_POSITION - 1;
				H_BALL_POSITION <= H_BALL_POSITION - 1;
	            		state <= TL_DIRECTION;	   
			end
        end	  
	//-----------------------------------------------------------------------------------------------------------------
		BL_DIRECTION: begin
         	  if(condi_BL_BR)		
         	  begin
		   	    V_BALL_POSITION <= V_BALL_POSITION + 1;
			    H_BALL_POSITION <= H_BALL_POSITION + 1;
           	   	    state <= BR_DIRECTION;
		  end 
		  else if(condi_BL_TL)
		 begin
		  	    V_BALL_POSITION <= V_BALL_POSITION - 1;
			    H_BALL_POSITION <= H_BALL_POSITION - 1;
	                    state <= TL_DIRECTION;
		  end 
		 else if(condi_Right_Score) begin										// Right Player Score condition 
			    state <= R_SCORED;
		 end
		 else begin 
		           V_BALL_POSITION <= V_BALL_POSITION + 1;
			   H_BALL_POSITION <= H_BALL_POSITION - 1;
	           	   state <= BL_DIRECTION;	
		end		 
        end	  
	//-----------------------------------------------------------------------------------------------------------------
        L_SCORED: begin
          	if(l_score<MAX_SCORE)
		begin
			l_score<= l_score+1;
			state <= SERVE_R;
	        end 
		else begin
			state <= COMPETITION;
          		GAME_OVER <= 1;

		 end
        end	 
	//-----------------------------------------------------------------------------------------------------------------
	 R_SCORED: begin
         	 if(r_score<MAX_SCORE)
		 begin
			r_score<= r_score+1;
			state <= SERVE_L;
		 end 
		 else begin
			state <= COMPETITION;
          		GAME_OVER <= 1;
		  end
        end
      endcase
    end
  end	  
  
  //----------------------------------------------------------------------------------------------------------------------
  
  assign R_SCORE = r_score;
  assign L_SCORE = l_score;
	  	  
endmodule