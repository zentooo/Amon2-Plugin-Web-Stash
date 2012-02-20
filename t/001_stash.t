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
        'Web::Stash',
    );

    get '/noset' => sub {
        my $c = shift;
        $c->stash;
        $c->render('index.tt');
    };

    get '/set1' => sub {
        my $c = shift;
        $c->stash->{data_before} = $c->stash->{data} = "foo";
        $c->render('index.tt');
    };

    get '/set2' => sub {
        my $c = shift;
        $c->stash->{data} = +{ foo => 'bar' };
        $c->stash->{bar} = 'baz';
        $c->render('obj.tt', +{
            bar => 'bag',
        });
    };

    __PACKAGE__->to_app;
};


subtest 'set nothing to stash' => sub {
    test_psgi
        app => $app,
        client => sub {
            my $cb = shift;
            my $res = $cb->(HTTP::Request->new(GET => 'http://localhost/noset'));
            note $res->content;
            like $res->content, qr/^\s*\n$/;
        };
};

subtest 'set string to stash' => sub {
    test_psgi
        app => $app,
        client => sub {
            my $cb = shift;
            my $res = $cb->(HTTP::Request->new(GET => 'http://localhost/set1'));
            note $res->content;
            like $res->content, qr/foo/;
        };
};

subtest 'set obj to stash' => sub {
    test_psgi
        app => $app,
        client => sub {
            my $cb = shift;
            my $res = $cb->(HTTP::Request->new(GET => 'http://localhost/set2'));
            note $res->content;
            unlike $res->content, qr/foo/;
            like $res->content, qr/bar/;

            # stash override with paramter
            unlike $res->content, qr/baz/;
            like $res->content, qr/bag/;
        };
};

done_testing;

package MyApp::Web;
__DATA__

@@ index.tt
[% data %]

@@ obj.tt
[% data.foo %]
[% data_before %]
[% bar %]
