# Set project directory to current directory
set proj_dir "."
set top_module "image_processor_top"
set tb_module "tb_image_processor"

# Create project
create_project -force Vision_Project $proj_dir -part xc7a35tcpg236-1

# Add sources using relative paths!
add_files "rtl/line_buffer.sv"
add_files "rtl/sobel_core.sv"
add_files "rtl/image_processor_top.sv"
set_property file_type SystemVerilog [get_files "rtl/*.sv"]

# Add constraints
add_files -fileset constrs_1 "constraints/vision.xdc"

# Add simulation sources
add_files -fileset sim_1 "tb/tb_image_processor.sv"
set_property file_type SystemVerilog [get_files "tb/tb_image_processor.sv"]
set_property top $tb_module [get_filesets sim_1]

# Set the simulator language
set_property simulator_language Mixed [current_project]

exit
