#!/bin/bash

mpirun -np $LSB_DJOB_NUMPROC --allow-run-as-root batch_exec -i $1 /validate.pl
