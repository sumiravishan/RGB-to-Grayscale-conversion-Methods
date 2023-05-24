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
package core_design_pkg;
	parameter core_memory_and_image_ratio=40;
	parameter core_IMEM_WIDTH=8 /* 1 colour */;
	parameter core_IMEM_SIZE=core_memory_and_image_ratio*1024*3 /* R,G,B */;
	parameter core_IMEM_BASE_ADDR=0;
	parameter core_MAX_USER_WRITE_ADDR=core_IMEM_BASE_ADDR + core_IMEM_SIZE - 1;
	parameter core_PROCESSED_IMEM_BASE_ADDR=core_IMEM_BASE_ADDR +  core_IMEM_SIZE;
	parameter core_ADDR_WIDTH=32;
	parameter core_IMEM_TOTAL_SIZE=core_IMEM_SIZE*2;
	parameter core_MAX_USER_READ_ADDR=core_IMEM_BASE_ADDR + core_IMEM_TOTAL_SIZE - 1;
	typedef enum bit [2:0] { core_reset,core_wait_for_start,core_processing,core_pause,core_abort,core_done} core_states;
endpackage
