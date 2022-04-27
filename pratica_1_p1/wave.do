onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /memory/clock
add wave -noupdate -color Red -height 25 /memory/wren
add wave -noupdate /memory/address
add wave -noupdate /memory/data_in
add wave -noupdate /memory/data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 127
configure wave -valuecolwidth 60
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {545 ps}
view wave 
wave clipboard store
wave create -driver freeze -pattern clock -initialvalue HiZ -period 100ps -dutycycle 50 -starttime 0ps -endtime 1000ps sim:/memory/clock 
{wave export -file C:/AOC_2/LAOCII/pratica_1/testbench -starttime 0 -endtime 1000 -format vlog -designunit memory} 
WaveCollapseAll -1
wave clipboard restore
