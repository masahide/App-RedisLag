use strict;
use Test::More;

use App::RedisLag;

my $class = App::RedisLag->new(slave_host => "localhost",master_host => "localhost");


is $class, $class;
is 0.12124, $class->set_time(0.12124);
is 0.12124, $class->set_time();

my $time = $class->set_check_value();
isnt 0,$time;
isnt 0, $class->get_check_value($time);

#タイムアウトテスト
$class->timeout(0.06);
isnt 0, $class->get_check_value($time-0.00001);


$class->run();
isnt " ",$class->get_result();

#diag explain $class->error_msg();

#diag explain @hoge;


done_testing;
