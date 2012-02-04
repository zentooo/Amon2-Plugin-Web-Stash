#!perl -w
use strict;
use Test::More tests => 1;

BEGIN {
    use_ok 'Amon2::Plugin::Web::ContextStash';
}

diag "Testing Amon2::Plugin::Web::ContextStash/$Amon2::Plugin::Web::ContextStash::VERSION";
