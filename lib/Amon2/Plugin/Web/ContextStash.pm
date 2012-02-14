package Amon2::Plugin::Web::ContextStash;
use strict;
use warnings;

our $VERSION = '0.01';

use Class::Method::Modifiers qw/install_modifier/;


my $store = +{};
sub _stash { $store }

sub init {
    my ($class, $c, $conf) = @_;
    _enable_stash($c, $conf);
}

sub _enable_stash {
    my ($c, $conf) = @_;
    my $webpkg = ref $c || $c;

    Amon2::Util::add_method($webpkg, 'stash', \&_stash);

    $c->add_trigger("AFTER_DISPATCH" => sub {
        $store = +{};
    });

    install_modifier($webpkg, "around", "render", sub {
        my ($orig, $c, $tmpl_path, $param) = @_;
        $param ||= +{};
        $orig->($c, $tmpl_path, +{%{ $c->stash }, %$param});
    });
}


1;
__END__

=head1 NAME

Amon2::Plugin::Web::ContextStash - Perl extention to do something

=head1 VERSION

This document describes Amon2::Plugin::Web::ContextStash version 0.01.

=head1 SYNOPSIS

    use Amon2::Plugin::Web::ContextStash;

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

zentooo E<lt>ankerasoy@gmail.comE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, zentooo. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
