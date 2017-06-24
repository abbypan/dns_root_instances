#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;
use File::Slurp qw/read_file write_file/;

my ($country) = @ARGV;

#db.cache is from http://www.internic.net/domain/db.cache

#system("wget http://www.internic.net/domain/db.cache -O db.cache");

my @lines = $country ?  generate_country_lines($country) : read_file('db.cache');

write_file('db.root', join("\n", @lines));

sub generate_country_lines {
    my ($country) = @_;

    my @c = read_file('root_instances.csv');
    shift @c;

    my @select_c = map { chomp; [ split /,/ ]  } grep { /^$country,/i } @c;
    return () unless(@select_c);

    my @add_lines = map { 
    qq[.                                86400      NS       $_->[1]
$_->[1]     $_->[2]       $_->[3]        $_->[4]]    
    } @select_c;
    return @add_lines;
}
