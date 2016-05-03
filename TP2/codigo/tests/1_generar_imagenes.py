#!/usr/bin/env python

from libtest import *
import subprocess
import sys

# Este script crea las multiples imagenes de prueba a partir de unas
# pocas imagenes base.


IMAGENES=["lena.bmp"]

assure_dirs()

sizes_mult4=['200x200', '204x204', '208x208', '212x212', '216x216', '2220x220']
sizes_pot2=['16x16', '32x32', '64x64', '128x128', '256x256', '512x512', '1024x1024']
sizes_res=['800x600', '1024x768', '1440x900', '1920x1080']
sizes_aumenta_ancho=['128x128', '256x128', '512x128', '1024x128']
sizes_aumenta_alto=['128x128', '128x256', '128x512', '128x1024']
sizes=sizes_mult4 + sizes_pot2 + sizes_res + sizes_aumenta_ancho + sizes_aumenta_alto


for filename in IMAGENES:
	print(filename)

	for size in sizes:
		sys.stdout.write("  " + size)
		name = filename.split('.')
		file_in  = DATADIR + "/" + filename
		file_out = TESTINDIR + "/" + name[0] + "." + size + "." + name[1]
		resize = "convert -resize " + size + "! " + file_in + " " + file_out
		subprocess.call(resize, shell=True)

print("")
