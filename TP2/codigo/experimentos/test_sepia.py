#El primer parametro es 'c' o 'asm', el segundo es la cantidad de iteraciones, y el tercero la precision

from sys import argv
import subprocess
import time
import os

import numpy
def median(lst):
    return numpy.median(numpy.array(lst))


args = ["../build/tp2", "sepia", "-i"]
args.append(argv[1])

iterar = int(argv[2])
precision = int(argv[3])

imgs = ["../tests/data/imagenes_resultado/lena.1024x768.bmp", "../tests/data/imagenes_resultado/lena.1920x1080.bmp"]
i, finaltime = 0, 0


f = open("outputFile","wb")

for img in imgs:
	args.append(img)
	print (img)

	for j in range(iterar):
		timeTemp = []
		for h in range(precision):
			start = time.time()
			subprocess.call(args, stdout=f)
			end = time.time()
			timeTemp.append(end-start)
		finalTime = median(timeTemp)
		print(finalTime)

	args.pop()

#caca.sort()
#iterar = iterar/2
#print(caca[iterar])#mediana


os.remove("outputFile")

#-v sepia -i asm ../tests/data/img/lena.1920x1080.bmp 100
#-v ldr -i asm ../tests/data/img/lena.1920x1080.bmp 100 100
#../build/tp2 -v ldr -i asm ../tests/data/img/lena.1920x1080.bmp 100
