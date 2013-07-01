use strict;
use Test::More;

use App::RedisLag::Redis;

my $class = App::RedisLag::Redis->new(host => "localhost");
is $class,$class->connect(), "connect ok";
ok $class->set_value("key","hoge"), "set_value ok";
is "hoge", $class->get_value("key"), "get_value ok";
ok $class->set_value("key2","hoge"), "set_value ok";
is "hoge", $class->get_value("key2"), "get_value ok";
is 1, $class->close(), "close ok";

is 0.12124, $class->set_time(0.12124);
is 0.12124, $class->set_time();
is 0.12124, $class->lag(0.12124);
is 0.12124, $class->lag();

$class->connect();

my $time = $class->set_check_value();
isnt 0,$time;
isnt 0, $class->get_check_value($time);


#タイムアウトテスト
$class->timeout(0.06);
isnt 0, $class->get_check_value($time-0.00001);

is "", $class->error_msg();
is "a", $class->error_msg("a");
is "a", $class->error_msg();
#diag explain $class->error_msg();

#diag explain @hoge;


done_testing;
