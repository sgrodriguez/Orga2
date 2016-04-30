#Este modulo recibe como parametro los argumentos que recibiria "tp2", y lo, realizando el output del tiempo tardado por stderr
from sys import argv
import subprocess

process = subprocess.Popen(["make -C ../"], stdout=subprocess.PIPE, cwd="../")

process.wait()

#args = argv
#args[0] = "../build/tp2"

#subprocess.call(args)