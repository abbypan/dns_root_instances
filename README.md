# dns_root_instances

dns root instances for rescue

# Background

The stability of root instances is decided by BGP anycast routing. 

Some area can not visit local root instances for a better latency. [Iran Leaks Censorship via BGP Hijacks](http://dyn.com/blog/iran-leaks-censorship-via-bgp-hijacks/) shows that BGP route leak can cause huge amount of queries be redirected to remote root instance. The more AS neighbors the guilt-AS has, the wider area the BGP route leak will influence.

To address this problem, RFC7706 is the most recommend, Root Servers by Running One on Loopback.

But if the resolvers don't want to "run Root on Loopback" when they encounter any root anycast BGP route unstable issue like "Iran leaks", as an alternative rescue solution, we can give a official suggest Root Instances List, with unicast IP addresses.

Resolvers can temporarily switch to send root queries to the unicast IP addresses in rescue time. After the unstable issue is over, return to the default anycast root hint file.

Root Instances List 
* To satisify different geolocation, it can be configured to target different countries.
* Not need to give all instances in one country, just a relatively stable recommend root instances unicast sublist.
* Must be updated periodly, for example, updated every year. Most of time, root instance's unicast IP address does not change as frequent as CDN business such as YTB.

This is not to add any "auto detect logic at resolover", totally on operator's choice. 

# How to spread the Root Instances List

## text file

like [db.cache](http://www.internic.net/domain/db.cache), we can give an online http text file.

For example, [root_instances.csv](root_instances.csv).

## dns rr

configure country.root-instances.net, take china for example : 

    ;; QUESTION SECTION:
    ;cn.root-instances.net.                    IN      NS

    ;; AUTHORITY SECTION:
    cn.root-instances.net.       86400     IN      NS       pek2a.f.root-servers.org.
    cn.root-instances.net.       86400     IN      NS       pek2b.f.root-servers.org.


    ;; ADDITIONAL SECTION:
    pek2a.f.root-servers.org. 3600    IN    A    203.119.85.5
    pek2b.f.root-servers.org. 3600    IN    A    203.119.85.6

# Install

    cpan File::Copy
    cpan File::Slurp

# Usage

Take bind for example. 

Generate rescue db.root file, copy to /etc/bind directory, restart bind.

db.cache is from http://www.internic.net/domain/db.cache

## text file

    perl root_instances_file.pl [type] [accident_root_label] [country]

Generate default anycast db.root

    $ perl root_instances_file.pl anycast

Generate rescue unicast db.root for L-root in China

    $ perl root_instances_file.pl unicast L cn

    $ diff db.cache db.root 

    79,81d78
    < .                        3600000      NS    L.ROOT-SERVERS.NET.
    < L.ROOT-SERVERS.NET.      3600000      A     199.7.83.42
    < L.ROOT-SERVERS.NET.      3600000      AAAA  2001:500:3::42
    88a86,89
    > .                             86400      NS       pek2a.f.root-servers.org.
    > pek2a.f.root-servers.org.     3600       A        203.119.85.5      
    > .                             86400      NS       pek2b.f.root-servers.org.
    > pek2b.f.root-servers.org.     3600       A        203.119.85.6      

## dns rr

to be continue.
