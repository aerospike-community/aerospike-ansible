#!/usr/bin/perl 

use strict;

# Defaults
my $TEMPLATE_FILE="act_storage.template.conf";
my $ACT_CONFIGURATION_FILE = "multiple-act.conf";
my $CONFIG_DIRECTORY="act-configuration";

# Config
my $duration_hours = 1;
my $multiplier = 1;

print "Usage : $0 <ACT_TEMPLATE_FILE_NAME> <CONFIGURATION_FILE> <MULTIPLIER> <DURATION_HOURS>\n";

if(not exists $ARGV[0]){
	print "Using $TEMPLATE_FILE as the act template (default)\n";
}
else{
	$TEMPLATE_FILE = $ARGV[0];
	print "Using $TEMPLATE_FILE as the act template\n";	
}

if(exists $ARGV[1]){
	$ACT_CONFIGURATION_FILE = $ARGV[1];
	print "Config will be output to $ACT_CONFIGURATION_FILE\n";
}
else{
	print "Config will be output to $ACT_CONFIGURATION_FILE (default)\n";	
}

if(exists $ARGV[2]){
	$multiplier = $ARGV[2];
	print "Multiplier set to $multiplier\n";
}
else{
	print "Multiplier set to $multiplier (default)\n";
}

if(exists $ARGV[3]){
	$duration_hours = $ARGV[3];
	print "Duration set to $duration_hours hours\n";
}
else{
	print "Duration set to $duration_hours hours (default)\n";
}

my $duration_sec = 3600 * $duration_hours;

my $act_config = {
	"test-duration-sec"=>$duration_sec
};

mkdir $CONFIG_DIRECTORY;
open(ACT_CONFIG_FILE,$ACT_CONFIGURATION_FILE);
# Read first line
<ACT_CONFIG_FILE>;
my @config;
while(<ACT_CONFIG_FILE>){
	chomp;
	my @parts = split(",",$_);
	my $config = {
		"object-type"=>$parts[0],
		"read-reqs-per-sec"=>$parts[1],
		"write-reqs-per-sec"=>$parts[2],
		"record-bytes"=>$parts[3]
	};
	push @config,$config;
}

sub println{
	print shift;
	print "\n";
}

sub create_config_file{
	my $config  = shift;
	my $output_file = $TEMPLATE_FILE;
	$output_file =~ s/template/$config->{"object-type"}/;
	open TEMPLATE_FILE, $TEMPLATE_FILE;
	open CONFIG_FILE, ">".$CONFIG_DIRECTORY."/".$output_file;
	while(<TEMPLATE_FILE>){
		my $line = $_;
		foreach(keys %$config){
			my $key = $_;
			if($line =~ /$key/){
				$line =~ s/^.*($key\s*\:).*$/$1$config->{$key}/;
			}
		}
		print CONFIG_FILE $line;
	}
	close TEMPLATE_FILE;
	close CONFIG_FILE;
}

foreach (@config){
	my %config = (%$_,%$act_config);
	$config{"read-reqs-per-sec"} = $multiplier * $_->{"read-reqs-per-sec"};
	$config{"write-reqs-per-sec"} = $multiplier * $_->{"write-reqs-per-sec"};
	create_config_file \%config;
}

println "Configuration files in $CONFIG_DIRECTORY";
