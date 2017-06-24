use Mojo::Base -strict;

use Test::More;

# version
require Minion::Command::minion::version;
my $version = Minion::Command::minion::version->new;

ok $version->description, 'has a description';
like $version->usage, qr/version/, 'has usage information';

$version->app->ua->once(
  start => sub {
    my ($ua, $tx) = @_;
    $tx->req->via_proxy(0)->url($ua->server->url->path('/'));
  }
);

$version->app->plugins->once(
  before_dispatch => sub { shift->render(json => {version => 1000}) });
my $buffer = '';
{
  open my $handle, '>', \$buffer;
  local *STDOUT = $handle;
  $version->run;
}
like $buffer, qr/Perl/, 'right output';
like $buffer, qr/You might want to update your Minion to 1000!/,
  'right output';

done_testing();
