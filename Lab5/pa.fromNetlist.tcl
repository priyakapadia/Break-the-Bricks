
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name Lab5 -dir "X:/Desktop/EC 311/Lab5/planAhead_run_1" -part xc6slx16csg324-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "X:/Desktop/EC 311/Lab5/vga_display.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {X:/Desktop/EC 311/Lab5} }
set_property target_constrs_file "vga_display.ucf" [current_fileset -constrset]
add_files [list {vga_display.ucf}] -fileset [get_property constrset [current_run]]
link_design
