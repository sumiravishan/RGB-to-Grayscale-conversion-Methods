/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Author: Sumira Fernando                                    ////
////          k.w.s.v.fernando@gmail.com                         ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2023                                          ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation.////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details. http://www.gnu.org/licenses/lgpl.html              ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
package apb_design_pkg;
	parameter apb_ADDR_WIDTH=32;
	parameter apb_DATA_WIDTH=32;
	parameter apb_PROT_WIDTH=3;
	parameter apb_STRB_WIDTH= ( apb_DATA_WIDTH / 8 );
	typedef enum bit [1:0] { apb_rst,apb_idle,apb_setup,apb_access} apb_states;
	parameter apb_interface_amount=2;
	function automatic bit [7:0] get_MAX(bit [7:0] in1,in2,in3);
		if ( ( in1 > in2 ) && ( in2 > in3 ) ) begin 
			get_MAX = in1;
		end else if ( ( in2 > in1 ) && ( in1 > in3 ) ) begin 
			get_MAX = in2;
		end else begin 
			get_MAX = in3;
		end 
	endfunction
	function automatic bit [7:0] get_MIN(bit [7:0] in1,in2,in3);
		if ( ( in1 < in2 ) && ( in2 < in3 ) ) begin 
			get_MIN = in1;
		end else if ( ( in2 < in1 ) && ( in1 < in3 ) ) begin 
			get_MIN = in2;
		end else begin 
			get_MIN = in3;
		end 
	endfunction
endpackage
