clean:
	rm -rf xelab*
	rm -rf xsim*
	rm -rf work*
	rm -rf xvlog*
	rm -rf log.txt
	rm -rf rep1
	rm -rf xcrg.log
	rm -rf vivado*
	rm -rf tr_db*
	rm -rf dump.vcd
	rm -rf *.txt

	
run_module:
	xvlog -sv -f list.nouvm.f
	xelab tb -debug all -timescale 1ns/1ns
	xsim tb -R 
