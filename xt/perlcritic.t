#!/bin/local/env perl

if (!require Test::Perl::Critic) {
    Test::More::plan(
        skip_all => "Test::Perl::Critic required for testing PBP compliance"
    );
}

my $rcfile = File::Spec->catfile( 'xt', 'perlcriticrc' );
Test::Perl::Critic->import( -profile => $rcfile );
Test::Perl::Critic::all_critic_ok();

#==[ EOF: percritic.t ]==
