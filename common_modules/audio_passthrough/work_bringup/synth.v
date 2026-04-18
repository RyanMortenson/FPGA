// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (lin64) Build 6299465 Fri Nov 14 12:34:56 MST 2025
// Date        : Fri Apr 17 13:01:33 2026
// Host        : ryanslinux running 64-bit CachyOS
// Command     : write_verilog -force synth.v
// Design      : bringup_top
// Purpose     : This is a Verilog netlist of the current design or from a specific cell of the design. The output is an
//               IEEE 1364-2001 compliant Verilog HDL file that contains netlist information obtained from the input
//               design files.
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* STRUCTURAL_NETLIST = "yes" *)
module bringup_top
   (clk,
    btnc,
    led);
  input clk;
  input btnc;
  output [2:0]led;

  wire \<const0> ;
  wire \<const1> ;
  wire \blink_counter[0]_i_2_n_0 ;
  wire \blink_counter_reg[0]_i_1_n_0 ;
  wire \blink_counter_reg[0]_i_1_n_1 ;
  wire \blink_counter_reg[0]_i_1_n_2 ;
  wire \blink_counter_reg[0]_i_1_n_3 ;
  wire \blink_counter_reg[0]_i_1_n_4 ;
  wire \blink_counter_reg[0]_i_1_n_5 ;
  wire \blink_counter_reg[0]_i_1_n_6 ;
  wire \blink_counter_reg[0]_i_1_n_7 ;
  wire \blink_counter_reg[12]_i_1_n_0 ;
  wire \blink_counter_reg[12]_i_1_n_1 ;
  wire \blink_counter_reg[12]_i_1_n_2 ;
  wire \blink_counter_reg[12]_i_1_n_3 ;
  wire \blink_counter_reg[12]_i_1_n_4 ;
  wire \blink_counter_reg[12]_i_1_n_5 ;
  wire \blink_counter_reg[12]_i_1_n_6 ;
  wire \blink_counter_reg[12]_i_1_n_7 ;
  wire \blink_counter_reg[16]_i_1_n_0 ;
  wire \blink_counter_reg[16]_i_1_n_1 ;
  wire \blink_counter_reg[16]_i_1_n_2 ;
  wire \blink_counter_reg[16]_i_1_n_3 ;
  wire \blink_counter_reg[16]_i_1_n_4 ;
  wire \blink_counter_reg[16]_i_1_n_5 ;
  wire \blink_counter_reg[16]_i_1_n_6 ;
  wire \blink_counter_reg[16]_i_1_n_7 ;
  wire \blink_counter_reg[20]_i_1_n_0 ;
  wire \blink_counter_reg[20]_i_1_n_1 ;
  wire \blink_counter_reg[20]_i_1_n_2 ;
  wire \blink_counter_reg[20]_i_1_n_3 ;
  wire \blink_counter_reg[20]_i_1_n_4 ;
  wire \blink_counter_reg[20]_i_1_n_5 ;
  wire \blink_counter_reg[20]_i_1_n_6 ;
  wire \blink_counter_reg[20]_i_1_n_7 ;
  wire \blink_counter_reg[24]_i_1_n_3 ;
  wire \blink_counter_reg[24]_i_1_n_6 ;
  wire \blink_counter_reg[24]_i_1_n_7 ;
  wire \blink_counter_reg[4]_i_1_n_0 ;
  wire \blink_counter_reg[4]_i_1_n_1 ;
  wire \blink_counter_reg[4]_i_1_n_2 ;
  wire \blink_counter_reg[4]_i_1_n_3 ;
  wire \blink_counter_reg[4]_i_1_n_4 ;
  wire \blink_counter_reg[4]_i_1_n_5 ;
  wire \blink_counter_reg[4]_i_1_n_6 ;
  wire \blink_counter_reg[4]_i_1_n_7 ;
  wire \blink_counter_reg[8]_i_1_n_0 ;
  wire \blink_counter_reg[8]_i_1_n_1 ;
  wire \blink_counter_reg[8]_i_1_n_2 ;
  wire \blink_counter_reg[8]_i_1_n_3 ;
  wire \blink_counter_reg[8]_i_1_n_4 ;
  wire \blink_counter_reg[8]_i_1_n_5 ;
  wire \blink_counter_reg[8]_i_1_n_6 ;
  wire \blink_counter_reg[8]_i_1_n_7 ;
  wire \blink_counter_reg_n_0_[0] ;
  wire \blink_counter_reg_n_0_[10] ;
  wire \blink_counter_reg_n_0_[11] ;
  wire \blink_counter_reg_n_0_[12] ;
  wire \blink_counter_reg_n_0_[13] ;
  wire \blink_counter_reg_n_0_[14] ;
  wire \blink_counter_reg_n_0_[15] ;
  wire \blink_counter_reg_n_0_[16] ;
  wire \blink_counter_reg_n_0_[17] ;
  wire \blink_counter_reg_n_0_[18] ;
  wire \blink_counter_reg_n_0_[19] ;
  wire \blink_counter_reg_n_0_[1] ;
  wire \blink_counter_reg_n_0_[20] ;
  wire \blink_counter_reg_n_0_[21] ;
  wire \blink_counter_reg_n_0_[22] ;
  wire \blink_counter_reg_n_0_[23] ;
  wire \blink_counter_reg_n_0_[24] ;
  wire \blink_counter_reg_n_0_[2] ;
  wire \blink_counter_reg_n_0_[3] ;
  wire \blink_counter_reg_n_0_[4] ;
  wire \blink_counter_reg_n_0_[5] ;
  wire \blink_counter_reg_n_0_[6] ;
  wire \blink_counter_reg_n_0_[7] ;
  wire \blink_counter_reg_n_0_[8] ;
  wire \blink_counter_reg_n_0_[9] ;
  wire btnc;
  wire clk;
  wire clk_IBUF;
  wire clk_IBUF_BUFG;
  wire [2:0]led;
  wire [2:1]led_OBUF;

  GND GND
       (.G(\<const0> ));
  VCC VCC
       (.P(\<const1> ));
  LUT1 #(
    .INIT(2'h1)) 
    \blink_counter[0]_i_2 
       (.I0(\blink_counter_reg_n_0_[0] ),
        .O(\blink_counter[0]_i_2_n_0 ));
  FDRE \blink_counter_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[0]_i_1_n_7 ),
        .Q(\blink_counter_reg_n_0_[0] ),
        .R(\<const0> ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \blink_counter_reg[0]_i_1 
       (.CI(\<const0> ),
        .CO({\blink_counter_reg[0]_i_1_n_0 ,\blink_counter_reg[0]_i_1_n_1 ,\blink_counter_reg[0]_i_1_n_2 ,\blink_counter_reg[0]_i_1_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const1> }),
        .O({\blink_counter_reg[0]_i_1_n_4 ,\blink_counter_reg[0]_i_1_n_5 ,\blink_counter_reg[0]_i_1_n_6 ,\blink_counter_reg[0]_i_1_n_7 }),
        .S({\blink_counter_reg_n_0_[3] ,\blink_counter_reg_n_0_[2] ,\blink_counter_reg_n_0_[1] ,\blink_counter[0]_i_2_n_0 }));
  FDRE \blink_counter_reg[10] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[8]_i_1_n_5 ),
        .Q(\blink_counter_reg_n_0_[10] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[11] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[8]_i_1_n_4 ),
        .Q(\blink_counter_reg_n_0_[11] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[12] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[12]_i_1_n_7 ),
        .Q(\blink_counter_reg_n_0_[12] ),
        .R(\<const0> ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \blink_counter_reg[12]_i_1 
       (.CI(\blink_counter_reg[8]_i_1_n_0 ),
        .CO({\blink_counter_reg[12]_i_1_n_0 ,\blink_counter_reg[12]_i_1_n_1 ,\blink_counter_reg[12]_i_1_n_2 ,\blink_counter_reg[12]_i_1_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O({\blink_counter_reg[12]_i_1_n_4 ,\blink_counter_reg[12]_i_1_n_5 ,\blink_counter_reg[12]_i_1_n_6 ,\blink_counter_reg[12]_i_1_n_7 }),
        .S({\blink_counter_reg_n_0_[15] ,\blink_counter_reg_n_0_[14] ,\blink_counter_reg_n_0_[13] ,\blink_counter_reg_n_0_[12] }));
  FDRE \blink_counter_reg[13] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[12]_i_1_n_6 ),
        .Q(\blink_counter_reg_n_0_[13] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[14] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[12]_i_1_n_5 ),
        .Q(\blink_counter_reg_n_0_[14] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[15] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[12]_i_1_n_4 ),
        .Q(\blink_counter_reg_n_0_[15] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[16] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[16]_i_1_n_7 ),
        .Q(\blink_counter_reg_n_0_[16] ),
        .R(\<const0> ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \blink_counter_reg[16]_i_1 
       (.CI(\blink_counter_reg[12]_i_1_n_0 ),
        .CO({\blink_counter_reg[16]_i_1_n_0 ,\blink_counter_reg[16]_i_1_n_1 ,\blink_counter_reg[16]_i_1_n_2 ,\blink_counter_reg[16]_i_1_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O({\blink_counter_reg[16]_i_1_n_4 ,\blink_counter_reg[16]_i_1_n_5 ,\blink_counter_reg[16]_i_1_n_6 ,\blink_counter_reg[16]_i_1_n_7 }),
        .S({\blink_counter_reg_n_0_[19] ,\blink_counter_reg_n_0_[18] ,\blink_counter_reg_n_0_[17] ,\blink_counter_reg_n_0_[16] }));
  FDRE \blink_counter_reg[17] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[16]_i_1_n_6 ),
        .Q(\blink_counter_reg_n_0_[17] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[18] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[16]_i_1_n_5 ),
        .Q(\blink_counter_reg_n_0_[18] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[19] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[16]_i_1_n_4 ),
        .Q(\blink_counter_reg_n_0_[19] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[0]_i_1_n_6 ),
        .Q(\blink_counter_reg_n_0_[1] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[20] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[20]_i_1_n_7 ),
        .Q(\blink_counter_reg_n_0_[20] ),
        .R(\<const0> ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \blink_counter_reg[20]_i_1 
       (.CI(\blink_counter_reg[16]_i_1_n_0 ),
        .CO({\blink_counter_reg[20]_i_1_n_0 ,\blink_counter_reg[20]_i_1_n_1 ,\blink_counter_reg[20]_i_1_n_2 ,\blink_counter_reg[20]_i_1_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O({\blink_counter_reg[20]_i_1_n_4 ,\blink_counter_reg[20]_i_1_n_5 ,\blink_counter_reg[20]_i_1_n_6 ,\blink_counter_reg[20]_i_1_n_7 }),
        .S({\blink_counter_reg_n_0_[23] ,\blink_counter_reg_n_0_[22] ,\blink_counter_reg_n_0_[21] ,\blink_counter_reg_n_0_[20] }));
  FDRE \blink_counter_reg[21] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[20]_i_1_n_6 ),
        .Q(\blink_counter_reg_n_0_[21] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[22] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[20]_i_1_n_5 ),
        .Q(\blink_counter_reg_n_0_[22] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[23] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[20]_i_1_n_4 ),
        .Q(\blink_counter_reg_n_0_[23] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[24] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[24]_i_1_n_7 ),
        .Q(\blink_counter_reg_n_0_[24] ),
        .R(\<const0> ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \blink_counter_reg[24]_i_1 
       (.CI(\blink_counter_reg[20]_i_1_n_0 ),
        .CO(\blink_counter_reg[24]_i_1_n_3 ),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O({\blink_counter_reg[24]_i_1_n_6 ,\blink_counter_reg[24]_i_1_n_7 }),
        .S({\<const0> ,\<const0> ,led_OBUF[1],\blink_counter_reg_n_0_[24] }));
  FDRE \blink_counter_reg[25] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[24]_i_1_n_6 ),
        .Q(led_OBUF[1]),
        .R(\<const0> ));
  FDRE \blink_counter_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[0]_i_1_n_5 ),
        .Q(\blink_counter_reg_n_0_[2] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[0]_i_1_n_4 ),
        .Q(\blink_counter_reg_n_0_[3] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[4]_i_1_n_7 ),
        .Q(\blink_counter_reg_n_0_[4] ),
        .R(\<const0> ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \blink_counter_reg[4]_i_1 
       (.CI(\blink_counter_reg[0]_i_1_n_0 ),
        .CO({\blink_counter_reg[4]_i_1_n_0 ,\blink_counter_reg[4]_i_1_n_1 ,\blink_counter_reg[4]_i_1_n_2 ,\blink_counter_reg[4]_i_1_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O({\blink_counter_reg[4]_i_1_n_4 ,\blink_counter_reg[4]_i_1_n_5 ,\blink_counter_reg[4]_i_1_n_6 ,\blink_counter_reg[4]_i_1_n_7 }),
        .S({\blink_counter_reg_n_0_[7] ,\blink_counter_reg_n_0_[6] ,\blink_counter_reg_n_0_[5] ,\blink_counter_reg_n_0_[4] }));
  FDRE \blink_counter_reg[5] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[4]_i_1_n_6 ),
        .Q(\blink_counter_reg_n_0_[5] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[6] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[4]_i_1_n_5 ),
        .Q(\blink_counter_reg_n_0_[6] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[7] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[4]_i_1_n_4 ),
        .Q(\blink_counter_reg_n_0_[7] ),
        .R(\<const0> ));
  FDRE \blink_counter_reg[8] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[8]_i_1_n_7 ),
        .Q(\blink_counter_reg_n_0_[8] ),
        .R(\<const0> ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \blink_counter_reg[8]_i_1 
       (.CI(\blink_counter_reg[4]_i_1_n_0 ),
        .CO({\blink_counter_reg[8]_i_1_n_0 ,\blink_counter_reg[8]_i_1_n_1 ,\blink_counter_reg[8]_i_1_n_2 ,\blink_counter_reg[8]_i_1_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O({\blink_counter_reg[8]_i_1_n_4 ,\blink_counter_reg[8]_i_1_n_5 ,\blink_counter_reg[8]_i_1_n_6 ,\blink_counter_reg[8]_i_1_n_7 }),
        .S({\blink_counter_reg_n_0_[11] ,\blink_counter_reg_n_0_[10] ,\blink_counter_reg_n_0_[9] ,\blink_counter_reg_n_0_[8] }));
  FDRE \blink_counter_reg[9] 
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .D(\blink_counter_reg[8]_i_1_n_6 ),
        .Q(\blink_counter_reg_n_0_[9] ),
        .R(\<const0> ));
  IBUF btnc_IBUF_inst
       (.I(btnc),
        .O(led_OBUF[2]));
  BUFG clk_IBUF_BUFG_inst
       (.I(clk_IBUF),
        .O(clk_IBUF_BUFG));
  IBUF clk_IBUF_inst
       (.I(clk),
        .O(clk_IBUF));
  OBUF \led_OBUF[0]_inst 
       (.I(\<const1> ),
        .O(led[0]));
  OBUF \led_OBUF[1]_inst 
       (.I(led_OBUF[1]),
        .O(led[1]));
  OBUF \led_OBUF[2]_inst 
       (.I(led_OBUF[2]),
        .O(led[2]));
endmodule
