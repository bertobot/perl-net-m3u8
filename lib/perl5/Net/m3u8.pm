package Net::m3u8;

use strict;
use Request;
use Class::MethodMaker [
    scalar  => [qw(baseurl keys segments playlists valid) ],
    new     => [qw(-init new)],
];

sub init {
    my ($self, $args) = @_;

    $self->keys($args->{'keys'} || {});
    $self->segments($args->{segments} || []);
    $self->playlists($args->{playlists} || []);
    $self->valid(0);

    if ($args->{url}) {
        my @tokens = split /\//, $args->{url};
        splice @tokens, -1, 1;
        $self->baseurl(join("/", @tokens));

        my $req = new Request;
        my $r = $req->get($args->{url});
        if ($r->ok) {
            $self->parse($r->body);
        }
    }
}

sub parse {
    my ($self, $str) = @_;

    my $flag_playlist = $self->keys->{'STREAM-INF'} ? 1 : 0;
    my $lastkey;

    foreach my $line (split /\n/, $str) {
        chomp $line;
        if ($line eq "#EXTM3U") {
            $self->valid(1);
        }
        
        if ($line =~ /^#EXT-X-(.+?):(.+?)$/) {
            $self->keys->{$1} = $2;
            $lastkey = $1;
            $flag_playlist = 1 if ($lastkey eq 'STREAM-INF');
        }

        elsif ($line =~ /^#EXTINF:(.+?)$/) {
            #$flag_playlist = 1;
            next;
        }

        elsif ($line =~ /^#/) {
            next;
        }

        else {
            my $segment = ($line =~ /^https?/) ? $line : sprintf("%s/%s", $self->baseurl, $line);
            my $sop = $flag_playlist ? $self->playlists : $self->segments;
            push @{$sop}, {
                meta    => { $lastkey => $self->keys->{$lastkey} },
                url     => $segment,
            };
        }
    }
}

1;

