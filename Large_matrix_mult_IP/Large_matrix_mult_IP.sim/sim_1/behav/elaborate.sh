#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/2016.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 99fae2eefeff4ce0a35983451fa6c8b9 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot Large_Matrix_mult_uip_tb_behav xil_defaultlib.Large_Matrix_mult_uip_tb xil_defaultlib.glbl -log elaborate.log
