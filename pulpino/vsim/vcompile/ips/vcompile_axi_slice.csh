#!/bin/tcsh
source ${PULP_PATH}/./vsim/vcompile/setup.csh

##############################################################################
# Settings
##############################################################################

set IP=axi_slice

##############################################################################
# Check settings
##############################################################################

# check if environment variables are defined
if (! $?MSIM_LIBS_PATH ) then
  echo "${Red} MSIM_LIBS_PATH is not defined ${NC}"
  exit 1
endif

if (! $?IPS_PATH ) then
  echo "${Red} IPS_PATH is not defined ${NC}"
  exit 1
endif

set LIB_NAME="${IP}_lib"
set LIB_PATH="${MSIM_LIBS_PATH}/${LIB_NAME}"
set IP_PATH="${IPS_PATH}/axi/axi_slice"
set RTL_PATH="${RTL_PATH}"

##############################################################################
# Preparing library
##############################################################################

echo "${Green}--> Compiling ${IP}... ${NC}"

rm -rf $LIB_PATH

vlib $LIB_PATH
vmap $LIB_NAME $LIB_PATH

##############################################################################
# Compiling RTL
##############################################################################

echo "${Green}Compiling component: ${Brown} axi_slice ${NC}"
echo "${Red}"
vlog -quiet -sv -work ${LIB_PATH}    ${IP_PATH}/axi_ar_buffer.sv || goto error
vlog -quiet -sv -work ${LIB_PATH}    ${IP_PATH}/axi_aw_buffer.sv || goto error
vlog -quiet -sv -work ${LIB_PATH}    ${IP_PATH}/axi_b_buffer.sv || goto error
vlog -quiet -sv -work ${LIB_PATH}    ${IP_PATH}/axi_buffer.sv || goto error
vlog -quiet -sv -work ${LIB_PATH}    ${IP_PATH}/axi_r_buffer.sv || goto error
vlog -quiet -sv -work ${LIB_PATH}    ${IP_PATH}/axi_slice.sv || goto error
vlog -quiet -sv -work ${LIB_PATH}    ${IP_PATH}/axi_w_buffer.sv || goto error

echo "${Cyan}--> ${IP} compilation complete! ${NC}"
exit 0

##############################################################################
# Error handler
##############################################################################

error:
echo "${NC}"
exit 1
