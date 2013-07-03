use strict;
use Test::More;

use App::RedisLag::Redis;

my $class = App::RedisLag::Redis->new(host => "localhost");


is "", $class->error_msg();
is "a", $class->error_msg("a");
is "a", $class->error_msg();
#diag explain $class->error_msg();

#diag explain @hoge;


done_testing;
