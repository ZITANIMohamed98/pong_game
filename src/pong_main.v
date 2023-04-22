module pong_main
#(
  parameter SCR_W = 30,
  parameter SCR_H = 20
)
(
	input wire        CLK, // CLK 75MHz
	input wire        RST, // Active high reset
  
	input wire [10:0] H_CNT, // horizontal pixel pointer
	input wire [10:0] V_CNT, // vertical   pixel pointer
	
	input wire        EncA_QA, 
	input wire        EncA_QB,
	input wire        Button_A,
	input wire        EncB_QA,
	input wire        EncB_QB, 
	input wire        Button_B,
	
	output wire [7:0] RED,
	output wire [7:0] GREEN,
	output wire [7:0] BLUE,
	
	output wire [3:0] LED
  );
   localparam BALL_W = 2;
   localparam BALL_H = 2;
   localparam PADDLE_H = SCR_H>>2;
   localparam MAX_SCORE  = 10;
   
   wire 	    A_up;
   wire 	    A_down;
   wire 	    B_up;
   wire 	    B_down;
   wire [10:0] h_ball_pos;
   wire [10:0] v_ball_pos;	
   wire [10:0] r_paddle_pos; 
   wire [10:0] l_paddle_pos;	
   wire        game_over;
   wire        l_score;
   wire        r_score;
   
 decoder_up_down
#(
)
decoder_up_down_inst
(
 .CLK(CLK5), // CLK 75MHz
 .RST(RST), // Active high reset

 .EncA_QA(EncA_QA), 
 .EncA_QB(EncA_QB),
 .EncB_QA(EncB_QA),
 .EncB_QB(EncB_QB),
	
  .A_up(A_up),
  .A_down(A_down),
  .B_up(B_up),
  .B_down(B_down)
);
 paddle_fsm
#(
  .SCR_W(SCR_W),	
  .SCR_H(SCR_H),
  .PADDLE_H(PADDLE_H) 
) 	
paddle_fsm_inst
( 
  .CLK(CLK), // CLK 75MHz
  .RST(RST), // Active high reset
  
  .A_up(A_up),
  .A_down(A_down),
  .B_up(B_up),
  .B_down(B_down),

  .L_PADDLE_POSITION(l_paddle_pos),
  .R_PADDLE_POSITION(r_paddle_pos)
); 
ball_fsm
#(
  .SCR_W(SCR_W),	
  .SCR_H(SCR_H),
  .PADDLE_H(PADDLE_H),
  .BALL_W(BALL_W),
  .BALL_H(BALL_H),
  .MAX_SCORE(MAX_SCORE)
  
) 
ball_fsm_inst
(
  .CLK, // CLK 75MHz
  .RST, // Active high reset
  
  .H_CNT, // horizontal pixel pointer
  .V_CNT, // vertical   pixel pointer
  
   .A_up(A_up),
  .A_down(A_down),
  .Button_A(Button_A),
  .B_up(B_up),
  .B_down(B_down),
  .Button_B(Button_B),
  
  .L_PADDLE_POSITION(l_paddle_pos),
  .R_PADDLE_POSITION(r_paddle_pos),
  
  .H_BALL_POSITION(h_ball_pos),
  .V_BALL_POSITION(v_ball_pos),
  
  .GAME_OVER(game_over),
  .L_SCORE(l_score),
  .R_SCORE(r_score)
);

    drawer 
  #(
    	.SCR_W  (SCR_W),
    	.SCR_H  (SCR_H),	 
	.BALL_W(BALL_W),
	.BALL_H(BALL_H),
	.PADDLE_H(PADDLE_H)
  )
  drawer_inst
  (			 
    .CLK    (CLK),   // 75 MHz clock signal
    .RST    (RST),       // active high reset
	
	.GAME_OVER(game_over),
    .L_SCORE(l_score),
    .R_SCORE(r_score),
	
	.H_BALL_POSITION(h_ball_pos),
	.V_BALL_POSITION(v_ball_pos),
	
	.L_PADDLE_POSITION(l_paddle_pos),
	.R_PADDLE_POSITION(r_paddle_pos),		 
	
    .H_CNT  (H_CNT),    // input horizontal pixel pointer 
    .V_CNT  (V_CNT),    // input vertical   pixel pointer

    .RED    (RED),   // generated value for pixel (x_hcnt, x_vcnt)
    .GREEN  (GREEN), // generated value for pixel (x_hcnt, x_vcnt)
    .BLUE   (BLUE)  // generated value for pixel (x_hcnt, x_vcnt) 
													
    );
  //-----------------------------------------
  // assign LED to counter bits to indicate FPGA is working
  reg [31:0] heartbeat;
  wire CLK5;
  always@(posedge CLK or posedge RST)
  if(RST) heartbeat <=             32'd0;
  else    heartbeat <= heartbeat + 32'd1;
  assign CLK5 = heartbeat[24];
  assign LED[3:0] = heartbeat[26:23];
  //----------------------------------------- 
  
endmodule