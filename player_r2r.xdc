# Z-turn 7010 - XC7Z010-1CLG400C - https://www.xilinx.com/support/packagefiles/z7packages/xc7z010clg400pkg.txt
# Z-turn 7020 - XC7Z020-1CLG400C - https://www.xilinx.com/support/packagefiles/z7packages/xc7z020clg400pkg.txt

# Cape 2x6 PMOD J5 connector - Digilent Pmod R2R 8-bit DAC 
set_property -dict { PACKAGE_PIN T11    IOSTANDARD LVCMOS33 } 	[get_ports { DAC[0] }]; 		# IO_L1P_T0_34				J5.1
set_property -dict { PACKAGE_PIN T10    IOSTANDARD LVCMOS33 } 	[get_ports { DAC[1] }]; 		# IO_L1N_T0_34				J5.3
set_property -dict { PACKAGE_PIN T12    IOSTANDARD LVCMOS33 } 	[get_ports { DAC[2] }]; 		# IO_L2P_T0_34				J5.5
set_property -dict { PACKAGE_PIN U12    IOSTANDARD LVCMOS33 } 	[get_ports { DAC[3] }]; 		# IO_L2N_T0_34				J5.7
set_property -dict { PACKAGE_PIN U13    IOSTANDARD LVCMOS33 } 	[get_ports { DAC[4] }]; 		# IO_L3P_T0_DQS_PUDC_B_34	J5.2
set_property -dict { PACKAGE_PIN V13    IOSTANDARD LVCMOS33 } 	[get_ports { DAC[5] }]; 		# IO_L3N_T0_DQS_34			J5.4
set_property -dict { PACKAGE_PIN V12    IOSTANDARD LVCMOS33 } 	[get_ports { DAC[6] }]; 		# IO_L4P_T0_34				J5.6
set_property -dict { PACKAGE_PIN W13 	IOSTANDARD LVCMOS33 } 	[get_ports { DAC[7] }]; 		# IO_L4N_T0_34 				J5.8
