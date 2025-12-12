#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use feature 'say';
use open qw(:std :utf8);

package SpamFilter;

sub new {
    my ($class, $triggers_ref) = @_;
    my $self = {
        patterns => {},
        pattern_list => [],
        trie     => undef,
        dirty    => 1,
    };
    bless $self, $class;

    if ($triggers_ref) {
        $self->add_trigger($_) for @$triggers_ref;
    }
    
    return $self;
}

sub add_trigger {
    my ($self, $phrase) = @_;
    return if exists $self->{patterns}->{$phrase};

    push @{$self->{pattern_list}}, $phrase;
    $self->{patterns}->{$phrase} = $#{$self->{pattern_list}};
    $self->{dirty} = 1;
}

sub _build_automaton {
    my ($self) = @_;
    
    my $root = {
        next => {}, # char -> node
        fail => undef,
        outputs => [],
    };
    
    foreach my $idx (0 .. $#{$self->{pattern_list}}) {
        my $phrase = $self->{pattern_list}->[$idx];
        my $node = $root;
        
        foreach my $char (split //, $phrase) {
            $node->{next}->{$char} //= {
                next => {},
                fail => undef,
                outputs => [],
            };
            $node = $node->{next}->{$char};
        }
        push @{$node->{outputs}}, $idx;
    }

    my @queue = ();
    
    foreach my $char (keys %{$root->{next}}) {
        my $child = $root->{next}->{$char};
        $child->{fail} = $root; 
        push @queue, $child;
    }
    
    while (@queue) {
        my $current = shift @queue;
        
        foreach my $char (keys %{$current->{next}}) {
            my $child = $current->{next}->{$char};
            
            my $fail_candidate = $current->{fail};
            while (defined $fail_candidate && !exists $fail_candidate->{next}->{$char}) {
                $fail_candidate = $fail_candidate->{fail};
            }
            
            if (defined $fail_candidate) {
                $child->{fail} = $fail_candidate->{next}->{$char};
            } else {
                $child->{fail} = $root;
            }
            
            push @{$child->{outputs}}, @{$child->{fail}->{outputs}};
            
            push @queue, $child;
        }
    }
    
    $self->{trie} = $root;
    $self->{dirty} = 0;
}

sub check_text {
    my ($self, $text) = @_;
    
    if ($self->{dirty}) {
        $self->_build_automaton();
    }

    my $root = $self->{trie};
    my $current = $root;
    
    my %stats = map { $_ => 0 } @{$self->{pattern_list}};
    my $total_hits = 0;

    foreach my $char (split //, $text) {
        while ($current != $root && !exists $current->{next}->{$char}) {
            $current = $current->{fail};
        }
        
        if (exists $current->{next}->{$char}) {
            $current = $current->{next}->{$char};
        }
        
        foreach my $pattern_idx (@{$current->{outputs}}) {
            my $pattern_str = $self->{pattern_list}->[$pattern_idx];
            $stats{$pattern_str}++;
            $total_hits++;
        }
    }
    
    return (\%stats, $total_hits);
}

package main;
use Test::More;


print "tests:\n";

my $filter = SpamFilter->new(["buy now", "free money", "click here"]);

my $line = "Hello, click here to buy now and get free money!";
my ($stats, $total) = $filter->check_text($line);

is($total, 3, "total matches should be 3");
is($stats->{"buy now"}, 1, "count 'buy now'");
is($stats->{"free money"}, 1, "count 'free money'");
is($stats->{"click here"}, 1, "count 'click here'");

$line = "buy now buy now";
($stats, $total) = $filter->check_text($line);
is($stats->{"buy now"}, 2, "count 'buy now' appearing twice");

$filter = SpamFilter->new([]);
$filter->add_trigger("she");
$filter->add_trigger("he");
$filter->add_trigger("hers");

$line = "ushers";
($stats, $total) = $filter->check_text($line);

is($stats->{"she"}, 1, "overlap: Found 'she'");
is($stats->{"he"}, 1, "overlap: Found 'he' inside 'she'");
is($stats->{"hers"}, 1, "overlap: Found 'hers'");
is($total, 3, "total overlapped matches");

$filter->add_trigger("cash");
$line = "I need cash now";
($stats, $total) = $filter->check_text($line);
is($stats->{"cash"}, 1, "dynamically added trigger found");

done_testing();
