use strict; use warnings;
use feature 'say';

sub iterate {
    my ($f, $value, $count) = @_;
    my @ret = ($value);
    for (1..$count) {
        $value = $f->($value);
        push @ret, $value;
    }
    return @ret;
}

sub get_scale {
    my @octave = @_; # first octave only
    # so double it to get full pattern
    my @pattern = (
        @octave, 
        (map { $_ + 12 } @octave), 
        $octave[0] + 24);
    my @semitones = map int, iterate(sub { $_[0] / 1.06 }, 1915, 24);

    return @semitones[@pattern];
}

sub get_mapper {
    my ($scale, $max) = @_;
    my @scale = @$scale;
    my $num_notes = scalar @scale;
    my $fret_width = $max / $num_notes;
    my $half_fret  = $fret_width / 2;

    return sub {
        my $x = shift;
        my $note = int( $x / $fret_width );
        my ($tone, $next) = @scale[$note, $note+1];
        if ($next) {
            # easing
            my $over = $x % $fret_width;
            my $halftone = ($next-$tone) / 2;
            if ($over < $half_fret) {
                $tone += $halftone * ($over/$half_fret)**2 ;
            }
            else {
                my $under = $fret_width - $over;
                $tone = $next - $halftone * ($under/$half_fret)**2 ;
            }
        }
        return int $tone;
    };
}

sub main {
    my @scale = get_scale(0,1,4,5,7,8,10);
    say join ',' => @scale;
    return;

    my $max = 750;
    my $mapper = get_mapper(\@scale, $max);
    for (0..$max) {
        print $mapper->($_) . "\n";
    }
}
main();
