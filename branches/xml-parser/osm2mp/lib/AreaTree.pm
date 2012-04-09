package AreaTree;

# ABSTRACT: search area containing object

# $Id$


use 5.010;
use strict;
use warnings;

use Carp;
use List::Util qw/ first reduce /;

use base qw/ Tree::R /;
use Math::Polygon::Tree;



=method add_area

    $area_tree->add_area( $object, @contours );

Add area to tree.

=cut

sub add_area {
    my ($self, $object, @contours ) = @_;

    my @bbox = Math::Polygon::Tree::polygon_bbox( map { @$_ } @contours );
    my $area = {
        data  => $object,
        bound => Math::Polygon::Tree->new( @contours ),
    };
    $self->insert( $area, @bbox );
    return;
}


=method find_area

    my $object = $area_tree->find_area( @points );

Returns object for area containing all points

=cut

sub find_area {
    my ($self, @points) = @_;

    my $possible_areas =
        reduce { [ grep { "$_" ~~ [ map {"$_"} @$b ] } @$a ] }
        map { my @objects; $self->query_point( @$_, \@objects ); \@objects }
        @points;

    return if !$possible_areas;
    return if !@$possible_areas;

    my $object = first { $_->{bound}->contains_points(@points) } @$possible_areas;
    return if !$object;
    return $object->{data};
}



1;

