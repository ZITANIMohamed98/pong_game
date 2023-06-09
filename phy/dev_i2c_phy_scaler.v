//=============================================================================================
//    Main contributors
//      - Adam Luczak         <mailto:aluczak@multimedia.edu.pl>
//=============================================================================================
`default_nettype none
//---------------------------------------------------------------------------------------------
`timescale 1ns / 1ns                            
//=============================================================================================
module dev_i2c_phy_scaler
(
input  wire	        i_clk,
input  wire         i_rst,   

output wire         o_tick,

input  wire  [15:0] cfg_clk_div 
);
//==============================================================================================
// local param
//==============================================================================================
//==============================================================================================
// variables
//==============================================================================================   
reg  [15:0] scaler;
//==============================================================================================
// scaller
//==============================================================================================
wire          tick                     =                                             scaler[15];
//---------------------------------------------------------------------------------------------- 
always@(posedge i_clk or posedge i_rst)
  if(i_rst)               scaler       <=                                                   'b0;
  else if(tick)           scaler       <=                                     cfg_clk_div - 'd2;
  else                    scaler       <=                                          scaler - 'd1;
//==============================================================================================
// data output 
//==============================================================================================
assign                    o_tick        =                                                  tick;
//==============================================================================================
endmodule









