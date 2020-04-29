#!/usr/bin/perl
use strict;
use lib 'lib/perl5';
use Net::m3u8;
use Data::Dumper;

$Data::Dumper::Indent = 1;

sub crawl {
    my ($url) = @_;
    my $m = new Net::m3u8({ url => $url });

    print Dumper $m;

    foreach my $p (@{ $m->playlists }) {
        crawl($p->{url});
    }

    foreach my $s (@{ $m->segments }) {
        my $req = new Request;
        my $r = $req->get($s->{url}, { tofile => '/dev/null' });
        print Dumper $r;
    }
}

### main

my $manifest_url = shift || 'https://mnmedias.api.telequebec.tv/m3u8/29880.m3u8';
crawl($manifest_url);

