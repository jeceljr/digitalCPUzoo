use warnings;
use strict;

my @buf = (0) x 4096;

my $bmess = "01234567890123456789012345678901234567890123456789012345678901234567890123456789".
			"01                                      X                                       ".
			"02                                                                              ".
			"03                                                                              ".
			"04                                                                              ".
			"05                                                                              ".
			"06                                                                              ".
			"07                                                                              ".
			"08                                                   F e l i z                  ".
			"09                                                                              ".
			"10                                                                              ".
			"11                                                     9 3  a n o s             ".
			"12                                                                              ".
			"13                                                                              ".
			"14                                                        J e c e l             ".
			"15                                                                              ".
			"16                                                      M a t t o s             ".
			"17                                                                              ".
			"18                                                    d e                       ".
			"19                                                                              ".
			"20                                                  A s s u m p c a o ! !       ".
			"21                                                                              ".
			"22                                                                              ".
			"23                                                                              ".
			"24                                            abcdefghijklmnopqrstuvwxyz        ".
			"25                                            ABCDEFGHIJKLMNOPQRSTUVWXYZ        ".
			"26                                            0123456789-_=+!@#\$%^&*()[]        ".
			"27                                                                              ".
			"28                                                                              ".
			"29                                                                              ";

for my $cCol (0..39){
	for my $cRow (0..29){
		my $off = 2*$cCol+80*$cRow;
	    my $low = substr($bmess,$off,1);
		my $off = 2*$cCol+1+80*$cRow;
	    my $high = substr($bmess,$off,1);
		my $word = 256*ord($high)+ord($low);
		$buf[32*$cCol+$cRow] = $word;
	}
}

open(FH,"<","jecelsr.pnm") or die $!;

my $header = <FH>;
my $title = <FH>;
my $size = <FH>;

my $x = 0;
my $y = 0;

while(<FH>){
	if ($_ eq "0\n"){
		print "." if ($x % 3) == 0;
	} else {
		print "@" if ($x % 3) == 0;
	};
	if (++$x == 3*92){
		$x = 0;
		print "$y\n";
		++$y;
	};
}

close(FH);

open(FH,"<","Arial_round_16x24.c") or die $!;

for (1..18) { my $skip = <FH>; };

for my $ch (0x20..0x7E){
	my $c = chr($ch);
	print "$ch: $c - \n";
	my $pt = <FH>;
	if (length($pt) < 20){
		$pt = <FH>;
	};
	my @nums = split(",",$pt);
	for my $row (0..23){
		my $bits = 256*hex($nums[2*$row])+hex($nums[1+2*$row]);
		my $tbits = sprintf("%016b", $bits);
		print "$tbits\n";
		# address is c c !r !r   c c c c    c r r r
		my $off = (($ch*32)&0xC00) | ((($row*32)&0x300)^0x300) | (($ch*8)&0x0F8) | ($row&0x007);
		$buf[$off] = $bits;
	};
};

close(FH);

open(FH,">","buf.S") or die $!;

for my $line (0..511){
	print FH "    .hword ";
	for my $word (0..6){
		my $w = sprintf("0x%04X,",$buf[8*$line+$word]);
		print FH $w;
	};
	my $w = sprintf("0x%04X\n",$buf[8*$line+7]);
	print FH $w;
};

close(FH);
