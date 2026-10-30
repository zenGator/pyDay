#!/usr/bin/perl
# https://github.com/zenGator/pyDay
# zG:20261024

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#use and constants here
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
use strict;
use warnings;
use Getopt::Std;
use POSIX;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#declare subroutines here
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sub usage;

# switches followed by a : expect an argument
# see usage() below for explanation of switches
my $commandname=$0=~ s/^.*\///r;				#let's know our own name
my %opt=();
getopts('ho:', \%opt) or usage();				#typical options: debug, help, infile, outfile, logfile

my $debugging=1 if $opt{d};
usage () if ( $opt{h}); # or (scalar keys %opt) == 0 ) ;		#show help if requesting or a bad flag is provided

#show positional parameters (anything after flagged options)
for my $i (0 .. $#ARGV) {
  printf "ignoring these:\n";
  printf "\t%d: \t%s\n", $i,$ARGV[$i];
}

#allow for piping /dev/stdout or redirect if specified at command-line
my $outFH=*STDOUT;
if ($opt{o}) {
    open($outFH, '>:encoding(UTF-8)', $opt{o}) 
        or die "Could not open file '$opt{o}': $!\n";
    }
*STDOUT=$outFH;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#declare variables here
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
my @pyDays;
my @sorted;
my @monDay;
#initializing days in std (non-leap year) months
	foreach my $m(1,3, 5, 7, 8, 10, 12) {
		$monDay[$m]=31;
		}
	foreach my $m(4, 6, 9, 11) {
		$monDay[$m]=30;
		}
	$monDay[2]=29; #setting to 29 (max) here, and will limit to 28 in non-leap years below
my @squareYears;
my $maxYear = int(sqrt(12**2 + 31**2));		# we can't generate a year greater than this
#initializing the years that are perfect squares
	for my $year (1 .. $maxYear) {
		$squareYears[$year**2] = $year;		#stores the perfect-square year into an array indexed with the squares
	}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#main
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
for (my $mon=1; $mon<=12; $mon++){						# step through the months
	for (my $day=1; $day<=$monDay[$mon]; $day++){		# step through the days
		my $sum = $day**2 + $mon**2;
		if (defined $squareYears[$sum]) {				# only add if the sum of the squares is in fact a square 
														# (i.e., is in the list of perfect-square years)
			last if ($mon==2 && $day==29 && ($squareYears[$sum]%4)>0); # skip any non-leapyear Feb 29
			push @pyDays, [$squareYears[$sum], $mon, $day];			# build array
#			printf $outFH "%d/%d/%d\n", $mon, $day, $year;
			}
		}
	}
@sorted = sort {$a->[0] <=> $b->[0]} @pyDays;			#sort the array
printf $outFH "Look forward to these dates:\n";
for my $x(@sorted){
	printf $outFH "\t%d/%d/%d\n", @$x[1],@$x[2], @$x[0] ;	#print the sorted array
	}

printf $outFH "done!\n";
    
exit 0;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#subroutines here
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    

sub usage() {
    print "like this: \n\t".$commandname." -o [outfile] [-l [logfile]]\n";
    print "\nThis shows the rational dates for Pythagorean Day, i.e., those dates where the month squared plus the day squared is equal to the year (last two digits only) squared.\n";
	print "\n";
    exit 1;
    }
