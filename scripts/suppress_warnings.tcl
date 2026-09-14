open_project C:/Users/us/Desktop/Vision_Edge_Accelerator/Vision_Project.xpr
set_msg_config -id {SYNTH-5} -suppress
# Also suppress TIMING-16 and XDCH-2 just in case they ever come back
set_msg_config -id {TIMING-16} -suppress
set_msg_config -id {XDCH-2} -suppress
set_msg_config -id {Synth 8-7129} -suppress
set_msg_config -id {Synth 8-6849} -suppress

# Save project
puts "Message suppression rules applied."
exit
