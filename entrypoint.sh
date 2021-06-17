#!/bin/bash

mpirun -np $1 --allow-run-as-root batch_exec -i $2 /validate.pl
