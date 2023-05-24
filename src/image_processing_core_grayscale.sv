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
module image_processing_core_grayscale  
import apb_design_pkg::*, core_design_pkg::*;
(input PCLK, input PRESETn, input [apb_ADDR_WIDTH-1:0] PADDR [apb_interface_amount-1:0], input [apb_PROT_WIDTH-1:0] PPROT[apb_interface_amount-1:0], 
 input PSEL [apb_interface_amount-1:0], input PENABLE [apb_interface_amount-1:0], input PWRITE [apb_interface_amount-1:0], 
 input [apb_DATA_WIDTH-1:0] PWDATA [apb_interface_amount-1:0], input [apb_STRB_WIDTH-1:0] PSTRB [apb_interface_amount-1:0],
 input start, input pause, input abort, 
 output logic PREADY [apb_interface_amount-1:0], output logic PSLVERR [apb_interface_amount-1:0], output logic [apb_DATA_WIDTH-1:0] PRDATA [apb_interface_amount-1:0],
 output logic busy, output logic done );

apb_states apb_current_state [apb_interface_amount-1:0], apb_next_state [apb_interface_amount-1:0];

bit [core_IMEM_WIDTH-1:0] IMEM [core_IMEM_TOTAL_SIZE - 1:0];

logic [core_ADDR_WIDTH-1:0] current_address;

core_states core_current_state, core_next_state;

logic clk, rst;

assign clk = PCLK;
assign rst = !PRESETn;

generate
for(genvar i=0; i < apb_interface_amount; i++ ) begin 

always @(*) begin
	if (  PRESETn == 0  ) begin 
		apb_next_state[i] = apb_rst;
	end  else if (  ( apb_current_state[i] == apb_rst ) &&  ( PSEL[i] == 0 ) ) begin 
		apb_next_state[i] = apb_idle;
	end  else if (  ( apb_current_state[i] == apb_rst ) &&  ( PSEL[i] == 1 ) ) begin 
		apb_next_state[i] = apb_setup;
	end  else if (  ( apb_current_state[i] == apb_idle ) &&  ( PSEL[i] == 1 ) ) begin 
		apb_next_state[i] = apb_setup;
	end  else if (  ( apb_current_state[i] == apb_setup ) &&  ( PSEL[i] == 0 ) ) begin 
		apb_next_state[i] = apb_idle;
	end  else if (  ( apb_current_state[i] == apb_setup ) &&  ( PENABLE[i] == 1 ) ) begin 
		apb_next_state[i] = apb_access;
	end  else if (  ( apb_current_state[i] == apb_access ) &&  ( PSEL[i] == 1 ) ) begin 
		apb_next_state[i] = apb_setup;
	end  else if (  ( apb_current_state[i] == apb_access ) &&  ( PSEL[i] == 0 ) ) begin 
		apb_next_state[i] = apb_idle;
	end 
end


always @(posedge PCLK) begin
	case(apb_next_state[i])
		 apb_rst : begin 
			PREADY[i] <= 0;
			PSLVERR[i] <= 0;
			PRDATA[i] <= 0;
		end
		 apb_idle : begin 
			if  ( apb_current_state[i] == apb_setup) begin 
				PREADY[i] <= 0;
				PSLVERR[i] <= 1;
				PRDATA[i] <= 0;
			end
			else if  ( apb_current_state[i] != apb_setup) begin 
				PREADY[i] <= 0;
				PSLVERR[i] <= 0;
				PRDATA[i] <= 0;
			end
		end
		 apb_setup : begin 
			PREADY[i] <= 0;
			PSLVERR[i] <= 0;
			PRDATA[i] <= 0;
		end
		 apb_access : begin 
			case(i)  
				0 : begin // write only port
						if ( PWRITE[i] == 1 ) begin 
							for ( int j = 0; j < apb_STRB_WIDTH ; j++ ) begin 
								if ( PADDR[i] + j  <= core_MAX_USER_WRITE_ADDR ) begin 
									if ( ( core_current_state == core_wait_for_start) || ( core_current_state == core_abort ) || ( core_current_state == core_done ) ) begin 
										if ( PSTRB[i][j] == 1 ) begin 
											IMEM[PADDR[i] + j ] <= ( PWDATA[i] >> ( 8 * j ) ) & 'hFF;
										end 
									end else if ( ( PADDR[i] + j  < current_address  ) && ( PSTRB[i][j] == 1 ) ) begin 
										IMEM[PADDR[i] + j ] <= ( PWDATA[i] >> ( 8 * j ) ) & 'hFF;
									end else begin 
										PSLVERR[i] <= 1;
									end 
								end 
							end
						end else begin 
							PSLVERR[i] <= 1;
						end 
						PRDATA[i] <= 0;						
					end
				default : begin //read only port
						if ( PWRITE[i] == 0 ) begin 
							for ( int j = 0; j < apb_STRB_WIDTH ; j++ ) begin 
								if ( PADDR[i] + j  <= core_MAX_USER_READ_ADDR ) begin 
									PRDATA[i][j*8 +: 8]  <= IMEM[PADDR[i] + j ];
								end else begin 
									PRDATA[i][j*8 +: 8]  <= 8'h00;
									PSLVERR[i] <= 1;
								end
							end
						end	else begin 
							PSLVERR[i] <= 1;
						end 			
					end
			endcase
			PREADY[i] <= 1;
		end
	endcase
	apb_current_state[i] <= apb_next_state[i];

end 

end
endgenerate 


always_comb begin
	if (  rst == 1 ) begin 
		core_next_state = core_reset;
	end  else if (  ( core_current_state == core_reset) ) begin 
		core_next_state = core_wait_for_start;
	end  else if (  ( core_current_state == core_wait_for_start ) &&  ( ( start == 1 ) && ( abort == 0 ) ) ) begin 
		core_next_state = core_processing;
	end  else if (  ( core_current_state == core_processing ) &&  ( ( abort == 1 ) && ( current_address != core_MAX_USER_WRITE_ADDR )) ) begin 
		core_next_state = core_abort;
	end  else if (  ( core_current_state == core_processing ) &&  ( ( pause == 1 ) && ( abort == 0 ) && ( current_address != core_MAX_USER_WRITE_ADDR )) ) begin 
		core_next_state = core_pause;
	end  else if (  ( core_current_state == core_processing ) &&  ( ( current_address >= core_MAX_USER_WRITE_ADDR )) ) begin 
		core_next_state = core_done;
	end  else if (  ( core_current_state == core_done) ) begin 
		core_next_state = core_wait_for_start;
	end  else if (  ( core_current_state == core_abort) ) begin 
		core_next_state = core_wait_for_start;
	end  else if (  ( core_current_state == core_pause ) &&  ( ( pause == 0 ) && ( abort == 0 )) ) begin 
		core_next_state = core_processing;
	end  else if (  ( core_current_state == core_pause ) &&  (  abort == 1 ) ) begin 
		core_next_state = core_abort;
	end
end

always @(posedge clk) begin
	case(core_next_state)
		 core_reset : begin 
			busy <= 0;
			done <= 0;
			current_address <= 0;
		end
		 core_wait_for_start : begin 
			busy <= 0;
			done <= 0;
			current_address <= 0;
		end
		 core_processing : begin 
			busy <= 1;
			done <= 0;
			//Conversion - 3 methods
			IMEM[core_PROCESSED_IMEM_BASE_ADDR+current_address] <= ( IMEM[current_address] + IMEM[current_address+1] + IMEM[current_address+2] ) /3  ;
			IMEM[core_PROCESSED_IMEM_BASE_ADDR+current_address+1] <= ( ( IMEM[current_address] * 299 ) + ( IMEM[current_address+1] * 587 ) + ( IMEM[current_address+2] * 114 ) ) / 1000  ;
			IMEM[core_PROCESSED_IMEM_BASE_ADDR+current_address+2] <= ( get_MAX( IMEM[current_address], IMEM[current_address+1], IMEM[current_address+2] ) + get_MIN( IMEM[current_address], IMEM[current_address+1], IMEM[current_address+2] ) )/ 2  ;
			current_address <= current_address + 3 ;
		end
		 core_pause : begin 
			busy <= 1;
			done <= 0;
		end
		 core_abort : begin 
			busy <= 0;
			done <= 0;
		end
		 core_done : begin 
			busy <= 0;
			done <= 1;
		end
	endcase
	core_current_state <= core_next_state;

end 



endmodule
