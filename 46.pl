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
        pattern_list => [],
        trie         => undef,
        sorted_nodes => [], # nodes in bfs order
        dirty        => 1,
    };
    bless $self, $class;

    if ($triggers_ref) {
        $self->add_trigger($_) for @$triggers_ref;
    }
    
    return $self;
}

sub add_trigger {
    my ($self, $phrase) = @_;
    push @{$self->{pattern_list}}, $phrase;
    $self->{dirty} = 1;
}

sub _build_automaton {
    my ($self) = @_;
    
    my $root = {
        next => {},        # char -> node
        fail => undef,
        my_patterns => [], # pattern ends
        count => 0,
    };
    
    foreach my $idx (0 .. $#{$self->{pattern_list}}) {
        my $phrase = $self->{pattern_list}->[$idx];
        my $node = $root;
        
        foreach my $char (split //, $phrase) {
            $node->{next}->{$char} //= {
                next => {},
                fail => undef,
                my_patterns => [],
                count => 0,
            };
            $node = $node->{next}->{$char};
        }
        push @{$node->{my_patterns}}, $idx;
    }

    my @queue = ();
    my @all_nodes = ();
    
    foreach my $char (keys %{$root->{next}}) {
        my $child = $root->{next}->{$char};
        $child->{fail} = $root; 
        push @queue, $child;
        push @all_nodes, $child; 
    }
    
    while (@queue) {
        my $current = shift @queue;
        
        foreach my $char (keys %{$current->{next}}) {
            my $child = $current->{next}->{$char};
            push @all_nodes, $child;
            
            my $fail_candidate = $current->{fail};
            while (defined $fail_candidate && !exists $fail_candidate->{next}->{$char}) {
                $fail_candidate = $fail_candidate->{fail};
            }
            
            if (defined $fail_candidate) {
                $child->{fail} = $fail_candidate->{next}->{$char};
            } else {
                $child->{fail} = $root;
            }
            
            push @queue, $child;
        }
    }
    
    $self->{trie} = $root;
    $self->{sorted_nodes} = \@all_nodes;
    $self->{dirty} = 0;
}

sub check_text {
    my ($self, $text) = @_;
    
    if ($self->{dirty}) {
        $self->_build_automaton();
    }

    my $root = $self->{trie};
    my $nodes = $self->{sorted_nodes};

    $_->{count} = 0 for @$nodes;
    
    my $current = $root;
    foreach my $char (split //, $text) {
        while ($current != $root && !exists $current->{next}->{$char}) {
            $current = $current->{fail};
        }
        $current = $current->{next}->{$char} // $root;
        
        $current->{count}++ if $current != $root;
    }
    
    foreach my $node (reverse @$nodes) {
        if (defined $node->{fail} && $node->{fail} != $root) {
            $node->{fail}->{count} += $node->{count};
        }
    }

    my %stats = map { $_ => 0 } @{$self->{pattern_list}};
    my $total_hits = 0;

    foreach my $node (@$nodes) {
        next unless $node->{count} > 0;
        foreach my $pidx (@{$node->{my_patterns}}) {
            my $p_str = $self->{pattern_list}->[$pidx];
            $stats{$p_str} += $node->{count};
            $total_hits += $node->{count};
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
is($stats->{"he"}, 1, "overlap: Found 'he' via propagation");
is($stats->{"hers"}, 1, "overlap: Found 'hers'");
is($total, 3, "total overlapped matches");

done_testing();
