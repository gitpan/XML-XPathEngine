#!/usr/bin/perl 

use strict;
use warnings;

use Test::More qw( no_plan);
use XML::XPathEngine;

BEGIN { push @INC, './t'; }

my $tree = init_tree();
my $xp   = XML::XPathEngine->new;

{
my @root_nodes= $xp->findnodes( '/root', $tree);
is( join( ':', map { $_->value } @root_nodes), 'root_value', q{findnodes( '/root', $tree)});
}
{
my @kid_nodes= $xp->findnodes( '/root/kid0', $tree);
is( scalar @kid_nodes, 2, q{findnodes( '/root/kid0', $tree)});
}
{
my $kid_nodes= $xp->findvalue( '/root/kid0', $tree);
is( $kid_nodes, 'vkid2vkid4', q{findvalue( '/root/kid0', $tree)});
}
{
is( $xp->findvalue( '//*[@att2="vv"]', $tree), 'gvkid1gvkid2gvkid3gvkid4gvkid5', 
    q{findvalue( '//*[@att2="vv"]', $tree)}
  );
is( $xp->findvalue( '//*[@att2]', $tree), 'gvkid1gkid2 1gvkid2gkid2 2gvkid3gkid2 3gvkid4gkid2 4gvkid5gkid2 5', 
    q{findvalue( '//*[@att2]', $tree)}
  );
}

is( $xp->findvalue( '//kid1[@att1=~/v[345]/]', $tree), 'vkid3vkid5', "match on attributes");

is( $xp->findvalue( '//@*', $tree), 'v1v1vvvxv2vvvxv3vvvxv4vvvxv5vvvx', 'match all attributes');
is( $xp->findvalue( '//@*[parent::*/@att1=~/v[345]/]', $tree), 'v3v4v5', 'match all attributes with a test');

sub init_tree
  { my $tree  = tree->new( 'att', name => 'tree', value => 'tree');
    my $root  = tree->new( 'att', name => 'root', value => 'root_value', att1 => 'v1');
    $root->add_as_last_child_of( $tree);

    foreach (1..5)
      { my $kid= tree->new( 'att', name => 'kid' . $_ % 2, value => "vkid$_", att1 => "v$_");
        $kid->add_as_last_child_of( $root);
        my $gkid1= tree->new( 'att', name => 'gkid' . $_ % 2, value => "gvkid$_", att2 => "vv");
        $gkid1->add_as_last_child_of( $kid);
        my $gkid2= tree->new( 'att', name => 'gkid2', value => "gkid2 $_", att2 => "vx");
        $gkid2->add_as_last_child_of( $kid);
      }

    $tree->set_pos;

    return $tree;
  }


package tree;
use base 'minitree';

sub getName            { return shift->name;  }
sub getValue           { return shift->value; }
sub string_value       { return shift->value; }
sub getRootNode        { return shift->root;                }
sub getParentNode      { return shift->parent;              }
sub getChildNodes      { return return wantarray ? shift->children : [shift->children]; }
sub getNextSibling     { return shift->next_sibling;        }
sub getPreviousSibling { return shift->previous_sibling;    }
sub isElementNode      { return 1;                          }
sub get_pos            { return shift->pos;          }
sub getAttributes      { return wantarray ? @{shift->attributes} : shift->attributes; }

sub cmp { my( $a, $b)= @_; return $a->pos <=> $b->pos; }

1;

package att;
use base 'attribute';

sub getName            { return shift->name;                }
sub getValue           { return shift->value;               }
sub string_value       { return shift->value; }
sub getRootNode        { return shift->parent->root;        }
sub getParentNode      { return shift->parent;              }
sub isAttributeNode    { return 1;                          }
sub getChildNodes      { return; }

sub cmp { my( $a, $b)= @_; return $a->pos <=> $b->pos; }

1;

