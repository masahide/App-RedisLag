App-RedisLag
============
redis-lag -  measurement tool of redis replication lag.

redis-lagは、Redisのレプリケーション遅延を計測するためにデーモンとしてメモリに常駐し、指定された間隔で計測を行います。
計測結果として、直近630秒間の平均値/最大値/最小値を集計しマスターサーバーに記録されます。
マスターサーバーに記録した集計結果をmunin pluginの出力形式でstdoutに出力するオプションも用意する予定です。

しかし、まだ開発中です...


参考にしたコード
===============

このツールは、 @toritori0318 さんのRedis-topを参考にしております。
https://github.com/toritori0318/p5-App-RedisTop

1ファイル化
===========

App::FatPacker を使って1ファイルのスクリプトにパックできます。

$ cpanm install App::FatPacker
$ PERL5LIB=./lib/ fatpack pack bin/redis-lag >redis-lag-packed.pl
