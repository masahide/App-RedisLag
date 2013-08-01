App-RedisLag
============
redis-lag -  measurement tool of redis replication lag.


何をするもの?
-------------

redis-lagは、Redisのレプリケーション遅延を計測するためにデーモンとしてメモリに常駐し、指定された間隔で計測を行います。
計測結果として、直近630秒間の平均値/最大値/最小値を集計しマスターサーバーに記録されます。
マスターサーバーに記録した集計結果をmunin pluginの出力形式でstdoutに出力するオプションも用意する予定です。

しかし、まだ開発中です...


参考にしたコード
----------------

このツールは、 @toritori0318 さんのRedis-topを参考にしております。
https://github.com/toritori0318/p5-App-RedisTop

1ファイル化
-----------

App::FatPacker を使って1ファイルのスクリプトにパックできます。

```
$ cpanm install App::FatPacker
$ PERL5LIB=./lib/ fatpack pack bin/redis-lag >redis-lag-packed.pl
```

FatPackerでパックされたコードは、cpan等を使わなくても、1ファイルを設置すれば、
ほとんどの環境で動くように作っています。

パック済みのファイルは [こちら](https://github.com/masahide/App-RedisLag/blob/master/redis-lag-packed.pl)


munin plugin
------------

redis-lagを常駐させた状態で、
以下のような単純なpluginを設置すればmuninに表示されます。

```sh
#!/bin/bash

if [ "$1" = "config" ] ; then
        echo graph_title Redis replication lag HOSTNAME
        echo graph_vlabel sec
        echo graph_category redis
        echo graph_args -l 0
        echo max.label max
        echo max.draw AREA
        echo avg.label avg
        echo avg.draw AREA
        echo min.label min
        echo min.draw AREA
        echo current.label current
        echo current.draw LINE2
else
        /usr/local/bin/redis-lag-packed.pl --munin_result --result_key HOSTNAME
fi
```
