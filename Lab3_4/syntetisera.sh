#!/bin/bash
# Script för att syntetisera VHDL till Xilinx XC9572
# Oscar Gustafsson, oscar.gustafsson@liu.se

# Ange namnet för toppmodulen här, dvs den entity som är huvudkonstruktionen
toppmodul=timer

# Om kretsen använder mer än en fil, eller om filen inte heter samma som entity,
# ange alla filer som används nedan och ta bort det inledande #-tecknet. 
# Testbänken skall INTE syntetiseras
# filer=(minkrets.vhdl delblock.vhdl)

# Inget mer behöver ändras nedan

# CPLD/FPGA som används
device=xc9572

# Skapa projektfil med alla filnamn
projektfil="${toppmodul}.prj"

# Ta bort gammal version av filen om den finns
if test -f "$projektfil"; then
   rm -f "$projektfil"
fi

if [ -z ${filer+x} ]; then
    # Bara en fil
    echo vhdl work "$toppmodul".vhd* >> "$projektfil"
else
    # Flera filer
    for fil in $filer
    do
	echo vhdl work "$fil" >> "$projektfil"
    done
fi

# Skapa instruktioner till verktyget
xstfil="${toppmodul}.xst"
utfil="${toppmodul}.ngc"

# Ta bort gammal version av filen om den finns
if test -f "$xstfil"; then
   rm -f "$xstfil"
fi

echo run >> "$xstfil"
echo -ifn "$projektfil" >> "$xstfil"
echo -top "$toppmodul" >> "$xstfil"
echo -p "$device" >> "$xstfil"
echo -ofn "$utfil" >> "$xstfil"
echo -opt_mode speed >> "$xstfil"
echo -opt_level 1 >> "$xstfil"

# Kör syntesen
xst -ifn "$xstfil"
