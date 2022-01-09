# Stäng av eventuella varningar "Metavalue detected":
set NumericStdNoWarnings 1
# Fortsätt köra trots rapporterade fel:
set BreakOnAssertion 3

# Definiera design (både entity och filer):
set design enpulsare

# Kompilera koden:
vlib work
vcom -2002 ${design}.vhd
vcom -2002 ${design}_tb.vhd

# Ladda in koden i simulatorn utan optimering ("Simulate without optimization")
vsim -novopt ${design}_tb

# Lägg till alla signaler i wave-fönstret:
add wave -divider {Top} /*
add wave -divider {DUT} -r /dut/*

# Kör tills det inte finns något kvar att simulera:
run -a

# Zooma wave-fönstret så att allt syns:
wave zoom full
