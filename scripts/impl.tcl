open_project C:/Users/us/Desktop/Vision_Edge_Accelerator/Vision_Project.xpr
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
launch_runs impl_1 -jobs 4
wait_on_run impl_1
puts "Synthesis and Implementation Complete!"
exit
