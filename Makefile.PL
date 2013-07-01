use inc::Module::Install;
name 'App-RedisLag';
all_from 'lib/App/RedisLag.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
