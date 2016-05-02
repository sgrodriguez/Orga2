#Este modulo recibe como parametro los argumentos que recibiria "tp2", y lo, realizando el output del tiempo tardado por stderr
from sys import argv
import subprocess
import time
#import statistics
import os

import numpy
def median(lst):
    return numpy.median(numpy.array(lst))

#process = subprocess.Popen(["make clean; make;"], shell=True, stdout=subprocess.PIPE, cwd="../")

#process.wait()


args = argv
args[0] = "../build/tp2"
f = open("outputFile","wb")

caca = []
iterar = int(args[-1])
args.pop()
for i in range(iterar):
	start = time.time()
	subprocess.call(args, stdout=f)
	end = time.time()
	#print( end-start )
	caca.append(end-start)

print ( median(caca) )
#caca.sort()
#iterar = iterar/2
#print(caca[iterar])#mediana


os.remove("outputFile")

#-v sepia -i asm ../tests/data/img/lena.1920x1080.bmp 100
#-v ldr -i asm ../tests/data/img/lena.1920x1080.bmp 100 100
#../build/tp2 -v ldr -i asm ../tests/data/img/lena.1920x1080.bmp 100
