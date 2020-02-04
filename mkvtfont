#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Std;
use Image::Magick;


sub sixel {
    return chr(0x3F + (($_[0]     ) |
                       ($_[1] *  2) |
                       ($_[2] *  4) |
                       ($_[3] *  8) |
                       ($_[4] * 16) |
                       ($_[5] * 32)));
}

sub read_image {
    my $image = shift;
    my ($width, $height) = ($image->Get('width'), $image->Get('height'));
    
    my @chars;
    my ($char_width, $char_height) = (15, 12);
    for (my $char_y = 0; $char_y < $height; $char_y += $char_height) {
        for (my $char_x = 0; $char_x < $width; $char_x += $char_width) {
            my $char = '';
            for (my $y = $char_y; $y < $char_y + $char_height; $y += 6) {
                for (my $x = $char_x; $x < $char_x + $char_width; $x++) {
                    my @pixels = $image->GetPixels(map => 'I',
                                                   x => $x,
                                                   y => $y,
                                                   width => 1,
                                                   height => 6,
                                                   normalize => 'true');
                    $char .= sixel(@pixels);
                }
                $char .= '/' if $y == $char_y;
            }

            push @chars, $char;
        }
    }

    return @chars;
}

sub make_font {
    my ($args) = @_;
    my $name = $args->{name} || 'A';
    my $columns = $args->{columns} || 80;
    my $full_cell = $args->{full_cell} || 0;
    my $cols_96 = $args->{96} || 1;

    my $fn  = 0;
    my $cn  = $columns == 132 ? 1 : 0;
    my $e   = 0;
    my $cmw = 0;
    my $w   = $columns == 132 ? 2 : 0;
    my $t   = !!$full_cell ? 1 : 0;
    my $cmh = 0;
    my $css = $cols_96 ? 1 : 0;
    my $scs = $name;
    my @xbp = @{$args->{glyphs}};
    
    return ("\x{90}$fn;$cn;$e;$cmw;$w;$t;$cmh;$css\{$scs"
           . join(';', @xbp)
           . "\x{9C}");
}

$Getopt::Std::STANDARD_HELP_VERSION = 1;
sub main::HELP_MESSAGE {
    print "usage: $0 [-c 80|132] [-t | -g] [-4 | -6] [-n NAME] GLYPH_IMAGE\n";
}

sub main::VERSION_MESSAGE {
    print "$0 -- makes fonts for vtfont\n";
}

our ($opt_4, $opt_6, $opt_c, $opt_g, $opt_n, $opt_t);
getopts('c:gn:t46');

my $columns = 80;
$columns = 132 if defined $opt_c && $opt_c eq '132';

my $full_cell = 0;
$full_cell = 1 if $opt_g;

my $cols_96 = 1;
$cols_96 = 0 if $opt_4;

my $name = '<';
$name = $opt_n if defined $opt_n && $opt_n ne '';

if (scalar @ARGV != 1) {
    main::HELP_MESSAGE;
    exit 1;
}
my $filename = $ARGV[0];

my $image = new Image::Magick;
my $error = $image->Read($filename);
die "$error" if $error;

my @glyphs = read_image($image);
if (!$cols_96) {
    shift @glyphs;
    pop @glyphs;
}

print "#!vtfont\n";
print make_font({name => $name,
                 columns => $columns,
                 full_cell => $full_cell,
                 96 => $cols_96,
                 glyphs => \@glyphs});
