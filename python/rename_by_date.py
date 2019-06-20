import operator
import os
from os.path import isfile, join

def scan(dirpath):
	d = {};
	# Get all files in directory
	files = [f for f in os.listdir(dirpath) if isfile(join(dirpath, f))]

	# Get modification date for each file
	for file in files:
		statbuf = os.stat(dirpath + file)
		d[dirpath + file] = statbuf.st_mtime

	# Sort by modification date
	sorted_d = sorted(d.items(), key=operator.itemgetter(1))

	# Rename files (prepend iterator)
	for i in range(0, len(sorted_d)):
		os.rename(sorted_d[i][0], dirpath + str(i) + "_" + os.path.basename(sorted_d[i][0]))

scan("/home/paranerd/Downloads/")