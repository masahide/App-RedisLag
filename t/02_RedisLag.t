use strict;
use Test::More;

use App::RedisLag;

my $class = App::RedisLag->new(slave_host => "localhost",master_host => "localhost");


is $class, $class;
is 0.12124, $class->lag(0.12124);
is 0.12124, $class->lag();




$class->timeout(120);
$class->add_ring_buf({date=>time(),time=>0.402});
$class->add_ring_buf({date=>time(),time=>0.202});
$class->add_ring_buf({date=>time(),time=>0.002});
my $sum = $class->sum();
is 0.202,$sum->{avg};
is 0.402,$sum->{max};
is 0.002,$sum->{min};


for(my $i=0;$i<700;$i++){
	$class->add_ring_buf({date=>time(),time=>2});
}
$sum = $class->sum();
is 2,$sum->{avg};
is 2,$sum->{max};
is 2,$sum->{min};
is 600,$sum->{count};

#diag explain $class->error_msg();

#diag explain @hoge;


done_testing;
