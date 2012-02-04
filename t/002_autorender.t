use strict;
use warnings;
use Test::More;

use Plack::Request;
use Plack::Test;
use Test::Requires 'Amon2::Lite';


my $app = do {
    package MyApp::Web;
    use Amon2::Lite;

    sub load_config { +{} }

    __PACKAGE__->load_plugins(
        'Web::ContextStash' => {
            autorender => 1,
        },
    );

    get '/' => sub {
        my $c = shift;
        $c->stash->{data} = "index";
    };

    get '/foo' => sub {
        my $c = shift;
        $c->stash->{data} = "foo";
    };

    get '/bar' => sub {
        my $c = shift;
        $c->stash->{data} = "bar";
        $c->render("bar.tt");
    };

    get '/foo/bar/' => sub {
        my $c = shift;
        $c->stash->{data} = "foobar";
    };

    __PACKAGE__->to_app;
};


subtest 'autorender /' => sub {
    test_psgi
        app => $app,
        client => sub {
            my $cb = shift;
            my $res = $cb->(HTTP::Request->new(GET => 'http://localhost/'));
            note $res->content;
            like $res->content, qr/index/;
        };
};

subtest 'autorender /foo' => sub {
    test_psgi
        app => $app,
        client => sub {
            my $cb = shift;
            my $res = $cb->(HTTP::Request->new(GET => 'http://localhost/foo'));
            note $res->content;
            like $res->content, qr/foo/;
        };
};

subtest 'manual render /bar' => sub {
    test_psgi
        app => $app,
        client => sub {
            my $cb = shift;
            my $res = $cb->(HTTP::Request->new(GET => 'http://localhost/bar'));
            note $res->content;
            like $res->content, qr/bar/;
        };
};

subtest 'autorender /foo/bar/' => sub {
    test_psgi
        app => $app,
        client => sub {
            my $cb = shift;
            my $res = $cb->(HTTP::Request->new(GET => 'http://localhost/foo/bar/'));
            note $res->content;
            like $res->content, qr/foobar/;
        };
};


done_testing;

package MyApp::Web;
__DATA__

@@ index.tt
[% data %]

@@ foo.tt
[% data %]

@@ bar.tt
[% data %]

@@ foo/bar/index.tt
[% data %]
