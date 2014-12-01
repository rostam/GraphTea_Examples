#!/usr/bin/perl

use strict;

# CONFIG

my $maxdepth = 4; # maximum depth of directory levels
my $maxdir = 150; # maximum number of directories on the graph (process time critical)

# MAIN

# dumb parameter handling
if (@ARGV[0] =~ /-h/) { print "For usage type> perldoc dot-tree.pl\n\n"; exit; }

my $cd = ''; # target path

if(defined $ARGV[0])
{
  #get path from command line argument
  $cd = $ARGV[0];
}

# container for tree (array of pathes)
my @tree;

# get tree from first level to increasing depth level
for (my $i = 0; $i<$maxdepth; $i++)
{
  # call find to get directory list at actual level
  my @subtree = `find $cd -mindepth $i -maxdepth $i -type d `;
  # add it to the 
  push @tree, @subtree;
}

my $cnt = 0; # counter for directory number limit check

# create a temp file for dot source
open DOT, '>/tmp/gtree.dot';

# write out header
print DOT <<DOT;
digraph CD {
  node [shape=box];
DOT

# for each path
for my $path (@tree)
{ 
  chomp($path);
  
  # split 'path' / 'directory'; if target dir, set node shape to ellipse
  $path =~ m|^(.*)/([^/]*)$|;
  my ($ppath, $dir, $attr) = ($cnt == 0) 
    ? ($path,$path, ',shape=ellipse') 
    : ($1, $2, '');
    
  # print node for actual directory and link it to parent path node
  print DOT <<DOT;
  "$path" [label = "$dir" $attr];
  "$ppath" -> "$path" [len=2];
DOT

  $cnt++; # increase dir counter

  # if directory limit reached,
  if ($cnt >= $maxdir)
  {
    # add a red node for warning
    print DOT "\"warning: more than $maxdir dir. process stopped.\" [style=filled,color=red]";
    last;
  }
}
# close dot file
print DOT "}";
close DOT;

# render the graph using neato
`neato  -Kneato -Tpng -o/tmp/gtree.png /tmp/gtree.dot`;
# show rendered graph with EOG
`eog /tmp/gtree.png`;

__DATA__

=pod

=head1 NAME

dot-tree.pl - Dot Directory tree graph generator

=head1 SYNOPSIS

  ./dot-tree.pl [path]

=head1 DESCRIPTION

Collects the directory tree and vizualize it using Graphviz/Neato and EOG.
The number of shown directories limited at 150 and 4 depth level. 
These parameter can be changed in the 'config' section of the script.
The script can be used as nautilus script by placing it in ~/.gnome2/nautilus-scripts

=head1 REQUIREMENT

Dot/Graphviz - Graph Visualization Software - http://www.graphviz.org
EOG - Eye of gnome

=head1 AUTHOR

Simon, Laszlo

laszlo.simon@gmailcom

=cut