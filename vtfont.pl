#!/usr/bin/env perl

use strict;
use warnings;

use File::Basename;
use Getopt::Std;


$Getopt::Std::STANDARD_HELP_VERSION = 1;
sub main::HELP_MESSAGE {
    print "usage: $0 [-C0 | -C1 | -C2 | -C3] [-n NAME] [-b Y] \n";
}

sub main::VERSION_MESSAGE {
    print "$0 -- loads user fonts into VT300-compatible terminals\n";
}

our ($opt_b, $opt_C, $opt_n);
getopts('b:C:n:');

if (scalar @ARGV != 1) {
    main::HELP_MESSAGE;
    exit 1;
}
my $font_name = $ARGV[0];

$font_name = '../share/vtfonts/$font_name.vtfont'
    if (-e dirname(__FILE__) . '../share/vtfonts/$font_name.vtfont');

open my $fh, '<', $font_name or die "can't open file '$!'";
my $font = do { local $/; <$fh> };

$font =~ s/^#.*?\n//g;
$font =~ s/\n$//;
$font =~ s/^\x{90}/\eP/;
$font =~ s/\x{9C}$/\e\\/;

my ($fn, $w, $css, $scs) =
    $font =~ /^.P(\d+);\d+;\d+;\d+;(\d+);\d+;\d+;(\d+)\{([\x{20}-\x{2F}]{0,2}[\x{30}-\x{7D}])/;

if (defined $opt_b) {
    $fn = $opt_b | 0;
}

if ($css == 1) {
    if (defined $opt_C) {
        die "can't assign 96-character font to C0"
            if $opt_C == 0;
        $scs = '-' if $opt_C == 1;
        $scs = '.' if $opt_C == 2;
        $scs = '/' if $opt_C == 3;
    }
}
else {
    if (defined $opt_C) {
        $scs = '(' if $opt_C == 0;
        $scs = ')' if $opt_C == 1;
        $scs = '*' if $opt_C == 2;
        $scs = '+' if $opt_C == 3;
    }
}

if (defined $opt_n) {
    die "invalid name '$opt_n'"
        if $opt_n !~ /^[\x{20}-\x{2F}]{0,2}[\x{30}-\x{7D}]$/;
    $scs = $opt_n;
}

if ($w == 2) {
    # TODO 132-column mode
}
else {
}

# TODO check for vt320

$font =~ s/^(.P)\d+(;\d+;\d+;\d+;\d+;\d+;\d+;\d+\{)[\x{20}-\x{2F}]{0,2}[\x{30}-\x{7D}]/$1$fn$2$scs/g;

print $font;
