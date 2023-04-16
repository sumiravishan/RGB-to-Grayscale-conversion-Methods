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