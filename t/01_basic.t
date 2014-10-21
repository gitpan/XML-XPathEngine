#!/usr/bin/perl 

use strict;
use warnings;

use Test::More tests => 23;
use XML::XPathEngine;

BEGIN { push @INC, './t'; }

my $tree = init_tree();
my $xp   = XML::XPathEngine->new;

#warn $tree->as_xml, "\n\n";
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

is( $xp->findvalue( '//@*', $tree), 'v1v1vvvx1v2vvvx0v3vvvx1v4vvvx0v5vvvx1', 'match all attributes');
is( $xp->findvalue( '//@*[parent::*/@att1=~/v[345]/]', $tree), 'v3v4v5', 'match all attributes with a test');

is( $xp->findvalue( '//kid1[@att1="v3"]/following::gkid2[1]', $tree), 'gkid2 4', "following axis[1]");
is( $xp->findvalue( '//kid1[@att1="v3"]/following::gkid2[2]', $tree), 'gkid2 5', "following axis[2]");
is( $xp->findvalue( '//kid1[@att1="v3"]/following::kid1/*', $tree), 'gvkid5gkid2 5', "following axis");
is( $xp->findvalue( '//kid1[@att1="v3"]/preceding::gkid2[1]', $tree), 'gkid2 2', "preceding axis[1]");
is( $xp->findvalue( '//kid1[@att1="v3"]/preceding::gkid2[2]', $tree), 'gkid2 1', "preceding axis[1]");
is( $xp->findvalue( '//kid1[@att1="v3"]/preceding::gkid2', $tree), 'gkid2 1gkid2 2', "preceding axis");

is( $xp->findvalue( 'count(//kid1)', $tree), '3', 'count( //gkid1)');
is( $xp->findvalue( 'count(//gkid2)', $tree), '5', 'count( //gkid2)');

is( $xp->findvalue( 'count(/root[count(.//kid1)=count(.//gkid1)])', $tree), 1, 'count() in expression (count(//kid1)=count(//gkid1))');
is( $xp->findvalue( 'count(/root[count(.//kid1)>count(.//gkid1)])', $tree), 0, 'count() in expression (returns 0)');
is( $xp->findvalue( 'count(/root[count(.//kid1)=count(.//gkid2)])', $tree), 0, 'count() in expression (returns 1)');
is( $xp->findvalue( 'count( root/*[count( ./gkid0) = 1])', $tree), 2, 'count() in expression (root/*[count( ./gkid0) = 1])');

is( $xp->findvalue( 'count(//gkid2[@att2="vx" and @att3=1])', $tree), 3, 'count with and');
is( $xp->findvalue( 'count(//gkid2[@att2="vx" and @att3])', $tree), 5, 'count with and');
is( $xp->findvalue( 'count(//gkid2[@att2="vx" or @att3])', $tree), 5, 'count with or');


sub init_tree
  { my $tree  = tree->new( 'att', name => 'tree', value => 'tree');
    my $root  = tree->new( 'att', name => 'root', value => 'root_value', att1 => 'v1');
    $root->add_as_last_child_of( $tree);

    foreach (1..5)
      { my $kid= tree->new( 'att', name => 'kid' . $_ % 2, value => "vkid$_", att1 => "v$_");
        $kid->add_as_last_child_of( $root);
        my $gkid1= tree->new( 'att', name => 'gkid' . $_ % 2, value => "gvkid$_", att2 => "vv");
        $gkid1->add_as_last_child_of( $kid);
        my $gkid2= tree->new( 'att', name => 'gkid2', value => "gkid2 $_", att2 => "vx", att3 => $_ % 2);
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
sub getChildNodes      { return wantarray ? shift->children : [shift->children]; }
sub getFirstChild      { return shift->first_child;         }
sub getLastChild       { return shift->last_child;         }
sub getNextSibling     { return shift->next_sibling;        }
sub getPreviousSibling { return shift->previous_sibling;    }
sub isElementNode      { return 1;                          }
sub get_pos            { return shift->pos;          }
sub getAttributes      { return wantarray ? @{shift->attributes} : shift->attributes; }
sub as_xml 
  { my $elt= shift;
    return "<" . $elt->getName . join( "", map { " " . $_->getName . '="' . $_->getValue . '"' } $elt->getAttributes) . '>'
           . (join( "\n", map { $_->as_xml } $elt->getChildNodes) || $elt->getValue)
           . "</" . $elt->getName . ">"
           ;
  }

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

