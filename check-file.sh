#!/bin/bash

for filepath in "$@"
do
    DIGEST=$((md5sum $filepath 2>/dev/null || echo "-- --") | awk '{ print $1 }')

    SIZE=$((du -sh --apparent-size $filepath 2>/dev/null || echo "-- --") | awk '{ print $1 }')

    LAST_MODIFIED=$(stat -L --printf="%Y" $filepath 2>/dev/null || echo "--")
    if [ "$LAST_MODIFIED" != "--" ]; then
        LAST_MODIFIED=$(date -u -d @$LAST_MODIFIED +"%Y-%m-%dT%H:%M:%S")
    fi

    case $filepath in
        *.nc|*.nc4)
            ncks -H $filepath >/dev/null 2>/dev/null
            if [ $? -eq 0 ]; then
                CHECK="ok"
            else
                CHECK="invalid"
            fi
            ;;
        *.h5|*.hdf)
            h5check $filepath >/dev/null 2>/dev/null
            if [ $? -eq 0 ]; then
                CHECK="ok"
            else
                CHECK="invalid"
            fi
            ;;
        *.mat)
            python -c "import scipy.io as sio; data = sio.loadmat('$filepath')" >/dev/null 2>/dev/null
            if [ $? -eq 0 ]; then
                CHECK="ok"
            else
                CHECK="invalid"
            fi
            ;;
        *.npy|*.npz)
            python -c "import numpy; data = numpy.load('$filepath')" >/dev/null 2>/dev/null
            if [ $? -eq 0 ]; then
                CHECK="ok"
            else
                CHECK="invalid"
            fi
            ;;
        *.txt|*.log|*.xml)
            grep -P -n "[^\x00-\x7F]" $filepath >/dev/null 2>/dev/null
            if [ $? -eq 0 ]; then
                CHECK="unknown"
            else
                CHECK="ok"
            fi
            ;;
        *)
            CHECK="-"
            ;;
    esac

    printf "%-32s  %4s  %19s  %-7s  %s\n" "$DIGEST" "$SIZE" "$LAST_MODIFIED" "$CHECK" "$filepath" 

done