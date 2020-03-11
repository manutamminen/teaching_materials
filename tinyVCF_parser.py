import sys
import csv

MYGFF=sys.argv[1]
MYVCF=sys.argv[2]
MYOUT=sys.argv[3]

with open(MYGFF, 'rb') as csvfile:
	GFFreader=csv.reader((row for row in csvfile if not row[0]('#')), delimiter='\t')
	GFFdata = [r for r in GFFreader]

with open(MYVCF, 'rb') as csvfile:
	VCFreader=csv.reader((row for row in csvfile if not row[0]('#')), delimiter='\t')
	VCFdata = [r for r in VCFreader]

with open(MYOUT, 'w') as f_out:
	for VCFrow in VCFdata:
		for GFFrow in GFFdata:
			if (GFFrow[2] == 'CDS') and (int(GFFrow[3]) <= int(VCFrow[1]) <= int(GFFrow[4])):
				f_out.write(VCFrow[1]+"\t"+VCFrow[3]+"\t"+VCFrow[4]+"\t"+VCFrow[7].split(";")[0]+"\t"+GFFrow[8]+"\n")
