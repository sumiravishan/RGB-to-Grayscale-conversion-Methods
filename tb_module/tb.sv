module tb();
import apb_design_pkg::*;
import core_design_pkg::*;

bit PCLK;
bit PRESETn;
bit [apb_ADDR_WIDTH-1:0] PADDR [apb_interface_amount-1:0];
bit [apb_PROT_WIDTH-1:0] PPROT[apb_interface_amount-1:0];

bit PSEL [apb_interface_amount-1:0];
bit PENABLE [apb_interface_amount-1:0];
bit PWRITE [apb_interface_amount-1:0];

bit [apb_DATA_WIDTH-1:0] PWDATA [apb_interface_amount-1:0];
bit [apb_STRB_WIDTH-1:0] PSTRB [apb_interface_amount-1:0];

bit start;
bit pause;
bit abort;

logic PREADY [apb_interface_amount-1:0];
logic PSLVERR [apb_interface_amount-1:0];
logic [apb_DATA_WIDTH-1:0] PRDATA [apb_interface_amount-1:0];

logic busy;
logic done;

 
image_processing_core_grayscale dut(.*); // dut

//// Tb specific 
parameter IMAGE_SIZE = 200*200;
bit [7:0] ROM [( IMAGE_SIZE*3 ) -1 :0]; // input image RGB values to send to core // 3 -> RGB // 3 consecutive locations give RGB values 24 bits , 3 bytes 

bit [23:0] ROM_PROCESSED_RGB_AVERAGE_METHOD [IMAGE_SIZE-1:0];
bit [23:0] ROM_PROCESSED_RGB_WEIGHTED_AVERAGE_METHOD [IMAGE_SIZE-1:0];
bit [23:0] ROM_PROCESSED_RGB_DESATURATION_METHOD [IMAGE_SIZE-1:0];

bit [7:0] TMP0_VAL;
bit [apb_ADDR_WIDTH-1:0] store_addr;


// Driving TB

initial begin 
	$readmemh("../image/flower_only_rgb_values.txt",ROM);
end 

initial begin 
	forever #5 PCLK = !PCLK;
end 

initial begin 
	#33 PRESETn = 1;
end 

initial begin 
	@(posedge PCLK);
	@(posedge PRESETn);
	@(posedge PCLK);
	// Write 
	$display("Writing");
	PWRITE[0]=1;
	PSEL[0]=1;
	PENABLE[0]=1;
	PSTRB[0]=1;
	repeat(IMAGE_SIZE*3) begin  // sending all the bytes
		PWDATA[0]=ROM[PADDR[0]];
		@( PREADY[0] == 1 );
		@( PREADY[0] == 0 );
		PADDR[0] = PADDR[0]+1;
	end
	PWRITE[0]=0;
	PSEL[0]=0;
	PENABLE[0]=0;
	//Start and Wait 
	$display("Srart and Waiting");
	@(posedge PCLK);
	start = 1;
	wait(busy==1);
	start = 0;
	wait(busy==0);
	@(posedge PCLK);
	$display("Read");
	//Read
	PWRITE[1]=0;
	PSEL[1]=1;
	PENABLE[1]=1;
	PADDR[1]=core_PROCESSED_IMEM_BASE_ADDR;
	PSTRB[1]=1;
	repeat(IMAGE_SIZE) begin 
		@( PREADY[1] == 1 );
		TMP0_VAL = PRDATA[1] & 32'hFF;
		ROM_PROCESSED_RGB_AVERAGE_METHOD[store_addr] = {3{TMP0_VAL}};
		TMP0_VAL = ( PRDATA[1] >> 8 ) & 32'hFF;
		ROM_PROCESSED_RGB_WEIGHTED_AVERAGE_METHOD[store_addr] = {3{TMP0_VAL}};
		TMP0_VAL = ( PRDATA[1] >> 16 ) & 32'hFF;
		ROM_PROCESSED_RGB_DESATURATION_METHOD[store_addr] = {3{TMP0_VAL}};
		@( PREADY[1] == 0 );
		PADDR[1] = PADDR[1]+3;
		store_addr = store_addr+1;
	end
	$display("Done");
	PSEL[1]=0;
	PENABLE[1]=0;
	@(posedge PCLK);
	//Use below to get view image in grayscale
	$writememh("flower_only_grayscale_values_average_method.txt",ROM_PROCESSED_RGB_AVERAGE_METHOD,0,IMAGE_SIZE-1); 
	$writememh("flower_only_grayscale_values_weighted_average_method.txt",ROM_PROCESSED_RGB_WEIGHTED_AVERAGE_METHOD,0,IMAGE_SIZE-1); 
	$writememh("flower_only_grayscale_values_desaturation_method.txt",ROM_PROCESSED_RGB_DESATURATION_METHOD,0,IMAGE_SIZE-1); 
	@(posedge PCLK);
	$finish;
end 

initial begin
	$dumpvars(1,tb);
end

endmodule

