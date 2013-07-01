use strict;
use Test::More;

use App::RedisLag::Redis;

my $class = App::RedisLag::Redis->new(host => "localhost");
is $class,$class->connect(), "connect ok";
is $class,$class->set_value("key","hoge"), "set_value ok";
is "hoge", $class->get_value("key"), "get_value ok";
ok $class->set_value("key2","hoge"), "set_value ok";
is "hoge", $class->get_value("key2"), "get_value ok";
#is 1, $class->close(), "close ok";


$class->connect();


is "", $class->error_msg();
is "a", $class->error_msg("a");
is "a", $class->error_msg();
#diag explain $class->error_msg();

#diag explain @hoge;


done_testing;
