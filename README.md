# dns_root_instances

dns root instances for rescue

# Background

The stability of root instances is decided by BGP anycast routing. 

Some area can not visit local root instances for a better latency. [Iran Leaks Censorship via BGP Hijacks](http://dyn.com/blog/iran-leaks-censorship-via-bgp-hijacks/) shows that BGP route leak can cause huge amount of queries be redirected to remote root instance. The more AS neighbors the guilt-AS has, the wider area the BGP route leak will influence.

Problem:  If one of the 13 root servers encountered the BGP leak/hijack accident on IP level (correct  db.root / NS from real server),  how to keep the dns traffic quick and stable (local visit, correct response)?

Solution:

1) avoid to visit all root server: RFC7706 is the most recommend, Root Servers by Running One on Loopback.

2) avoid to visit the accident root server, but visit local rescue root server:

If the resolvers don't want to "run Root on Loopback" when they encounter any root anycast BGP route unstable issue like "Iran leaks", as an alternative rescue solution, we can give a official suggest Root Instances List, with unicast IP addresses.

Resolvers can temporarily switch to send root queries to the unicast IP addresses in rescue time. After the unstable issue is over, return to the default anycast root hint file.

Root Instances List 
* To satisify different geolocation, it can be configured to target different countries.
* Not need to give all instances in one country, just a relatively stable recommend root instances unicast sublist.
* Must be updated periodly, for example, updated every year. Most of time, root instance's unicast IP address does not change as frequent as CDN business such as YTB.

This is not to add any "auto detect logic at resolover", totally on operator's manual rescue choice. 

More details at RSSAC-Caucus-Anycast-WP Group D, Security mail list.

# Install

    cpan File::Copy
    cpan File::Slurp
    
# How to spread the Root Instances List

Take bind for example. 

Generate rescue db.root file, copy to /etc/bind directory, restart bind.

db.cache is from http://www.internic.net/domain/db.cache

## root instances text file

like [db.cache](http://www.internic.net/domain/db.cache), we can give an online http text file.

For example, [root_instances.csv](root_instances.csv).

    perl root_instances_file.pl [country]

Generate default anycast db.root

    $ perl root_instances_file.pl

Generate rescue unicast db.root in China

    $ perl root_instances_file.pl cn

    $ cat db.root

    .                                86400      NS       rescue2a.cn.root-servers.cn.
    rescue2a.cn.root-servers.cn.     3600       A        111.111.111.111
    .                                86400      NS       rescue2b.cn.root-servers.cn.
    rescue2b.cn.root-servers.cn.     3600       A        222.222.222.222

**Note that**, rescue servers return the same NS list as the rescue db.root file on recursive initial lookup, but not the default anycast root server NS list.

## root instances dns rr

configure country.root-instances.net, take china for example : 

    ;; QUESTION SECTION:
    ;cn.root-instances.net.                    IN      NS

    ;; AUTHORITY SECTION:
    cn.root-instances.net.       86400     IN      NS       rescue2a.cn.root-servers.cn.
    cn.root-instances.net.       86400     IN      NS       rescue2b.cn.root-servers.cn.


    ;; ADDITIONAL SECTION:
    rescue2a.cn.root-servers.cn. 3600    IN    A    111.111.111.111 
    rescue2b.cn.root-servers.cn. 3600    IN    A    222.222.222.222

to be continue.

# Acknowledgements

Thanks for helpful comments and suggestions from John Bond, Wes Hardaker.
