#Se le pasa como parametro el alpha, la cantidad de iteraciones y el modelo de imagen.
#experimento.py ALPHA ITERACIONES MODELO
#0 = multiplos de 4
#1 = potencias de 2
#2 = resoluciones
#3 = aumenta el ancho
#4 = aumenta el alto

from sys import argv
import subprocess
import time
import os, re

def purge(dir, pattern):
    for f in os.listdir(dir):
    	if re.search(pattern, f):
    		os.remove(os.path.join(dir, f))

args = ["../build/tp2", "ldr", "-i", "implementacion", "-t", "iteraciones", "img", "alpha"]

arg_img = 6
arg_iter = 5
arg_implementacion = 3

args[-1] = argv[1]

args[arg_iter] = argv[2]

implementaciones = ["c", "asm"]

img_dir = "../tests/data/imagenes_a_testear/"

sizes_mult4=['200x200', '204x204', '208x208', '212x212', '216x216', '2220x220']
sizes_pot2=['16x16', '32x32', '64x64', '128x128', '256x256', '512x512', '1024x1024']
sizes_res=['800x600', '1024x768', '1440x900', '1920x1080']
sizes_aumenta_ancho=['128x128', '256x128', '512x128', '1024x128']
sizes_aumenta_alto=['128x128', '128x256', '128x512', '128x1024']
imgs = []

if (len(argv) == 3):
	imgs = sizes_pot2
elif (int(argv[3]) == 0):
	imgs = sizes_mult4
elif (int(argv[3]) == 1):
	imgs = sizes_pot2
elif (int(argv[3]) == 2):
	imgs = sizes_res
elif (int(argv[3]) == 3):
	imgs = sizes_aumenta_ancho
elif (int(argv[3]) == 4):
	imgs = sizes_aumenta_alto

res_file = "./resultado/experimento_ldr_variable_imagen.out"

f = open(res_file,"w+")

print >> f, 'Filtro LDR.\nExperimento variando el size de la imagen por potencias de 2.\n\n'

for imp in implementaciones:
	args[arg_implementacion] = imp;
	print >> f, "Implementacion de LDR en", imp
	for img in imgs:
		print >> f, "Imagen:", img
		f.flush()
		args[arg_img] = img_dir + "lena." + img + ".bmp"
		subprocess.check_call(args, stdout=f)
		print >> f, "\n"
		f.flush()

purge("./", ".bmp")

print "Terminado"