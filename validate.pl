#!/usr/bin/perl
use strict;
use warnings;
use Digest::MD5;
use File::stat;
use Number::Bytes::Human qw(format_bytes);

sub fmt_info {
    my (%file_info) = @_;

    my $digest = exists($file_info{"digest"}) ? $file_info{"digest"} : '--';
    my $size = exists($file_info{"size"}) ? format_bytes($file_info{"size"}) : '--';
    my $is_valid = exists($file_info{"is_valid"}) ? $file_info{"is_valid"} : '--';
    my $path = exists($file_info{"path"}) ? $file_info{"path"} : '--';

    my $result = sprintf("%-32s  %7s  %-7s  %s\n",$digest,$size,$is_valid,$path);
}

my $has_ncks = not system("which ncks >/dev/null 2>/dev/null");
my $has_h5check = not system("which h5check >/dev/null 2>/dev/null");


foreach my $file_path (@ARGV) {
    my %file_info = (path => $file_path);

    my $fh;
    unless(open($fh, "<", $file_info{"path"})) {
        print(fmt_info(%file_info));
        next;
    }
    binmode($fh);
    $file_info{"digest"} = Digest::MD5->new->addfile($fh)->hexdigest;
    close($fh);

    $file_info{"size"} = stat($file_info{"path"})->size;

    my $temp;
    if ($has_ncks && $file_info{"path"} =~ m/\.(nc|nc4)$/) {
        my $temp = system("ncks -H $file_info{'path'} > /dev/null 2> /dev/null");
        if ($temp == 0) {
            $file_info{"is_valid"} = "valid";
        } else {
            $file_info{"is_valid"} = "invalid";
        }
    } elsif ($file_info{"path"} =~ m/\.(hdf|h5|nc|nc4)$/) {
        my $temp = system("h5check $file_info{'path'} > /dev/null 2> /dev/null");
        if ($temp == 0) {
            $file_info{"is_valid"} = "valid";
        } else {
            $file_info{"is_valid"} = "invalid";
        }
    }

    print(fmt_info(%file_info))
}
