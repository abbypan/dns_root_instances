#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;
use File::Slurp qw/read_file write_file/;

my ($action, $root_label, $country) = @ARGV;

#db.cache is from http://www.internic.net/domain/db.cache

#system("wget http://www.internic.net/domain/db.cache -O db.cache");
my @lines = read_file('db.cache');

if($action eq 'anycast'){
    #default
}elsif($action eq 'unicast'){
    exit unless($root_label=~/^[a-m]$/i);
    @lines = grep { ! /$root_label\.ROOT-SERVERS\.NET\./i } @lines;
    push @lines, generate_country_lines($country);
}

write_file('db.root', @lines);

sub generate_country_lines {
    my ($country) = @_;

    my @c = read_file('root_instances.csv');
    shift @c;

    my @select_c = map { chomp; [ split /,/ ]  } grep { /^$country,/i } @c;
    return () unless(@select_c);
    
    my @add_lines = map { 
qq[.                             86400      NS       $_->[2]
$_->[2]     $_->[3]       $_->[4]        $_->[5]      
]    
} @select_c;
    return @add_lines;
}
