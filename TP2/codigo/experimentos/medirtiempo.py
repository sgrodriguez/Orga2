#Este modulo recibe como parametro los argumentos que recibiria "tp2", y lo, realizando el output del tiempo tardado por stderr
from sys import argv
import subprocess
import time
import statistics
import os

#process = subprocess.Popen(["make clean; make;"], shell=True, stdout=subprocess.PIPE, cwd="../")

#process.wait()


args = argv
args[0] = "../build/tp2"

f = open("outputFile","wb")

caca = []

for i in range(1000):
	start = time.time()
	subprocess.call(args, stdout=f)
	end = time.time()
	#print( end-start )
	caca.append(end-start)

print ( statistics.median(caca) )

os.remove("outputFile")