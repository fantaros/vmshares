#!/bin/sh
export PATH='/opt/usr/sbin:/opt/usr/bin:/opt/sbin:/opt/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin'
export LD_LIBRARY_PATH=/opt/youku/lib:/lib
logger -t "【路由宝】" "进程保护启动"
hc_dir=/opt/data
hc_dir=`echo $hc_dir`
sn_youku=2115669623336989
#youku_Total=`nvram get youku_Total`
#ulimit -v $youku_Total
spd=0
path=$hc_dir/youku
hc=32000
[ -z $hc ] && hc=32000
while true; do
    localpath=`echo $hc_dir`
    if [ ! -d `echo $localpath` ]; then
                logger -t "【路由宝】" "错误！！自定义缓存目录不存在！！"
                logger -t "【路由宝】" "$localpath 设置错误！！请检查 U盘 文件和设置"
    fi
    pids=$(ps | grep "ikuacc" | grep -v "grep" | wc -l)
    if [ "$pids" -ne 1 ]; then
        logger -t "【路由宝】" "找不到优酷进程 $pids"
        sleep 1
        if [ ! -n "`pidof ikuacc`" ]; then
            logger -t "【路由宝】" "找不到优酷进程(复查)，重启优酷"
        else
            continue
        fi
        killall -9 ikuacc
        sleep 1
        export LD_LIBRARY_PATH=/opt/youku/lib:/lib
        /opt/youku/bin/ikuacc  --device-serial-number="0000$sn_youku"  --mobile-meta-path="$path/meta" --mobile-data-path="$path/data:$hc"  &
        sleep 5
        logger -t "【路由宝】" "开始运行. PID:【$(pidof ikuacc)】"
        #速度模式
        wget -O - http://127.0.0.1:8908/peer/limit/network/set?upload_model=$spd > /dev/null 2>&1 &
        wget -O - http://10.0.2.15:8908/peer/limit/network/set?upload_model=$spd > /dev/null 2>&1 &
    fi

    pids=$(ps | grep "ikuacc" | grep -v "grep" | wc -l)
    if [ "$pids" -gt 4 ]; then 
        echo "优酷进程重复，重启优酷"
        logger -t "【路由宝】" "优酷进程重复，重启优酷"
        killall -9 ikuacc
        sleep 3
        export LD_LIBRARY_PATH=/opt/youku/lib:/lib
        /opt/youku/bin/ikuacc  --device-serial-number="0000$sn_youku"  --mobile-meta-path="$path/meta" --mobile-data-path="$path/data:$hc"  &
        logger -t "【路由宝】" "开始运行"
        sleep 5
        #速度模式
        wget -O - http://127.0.0.1:8908/peer/limit/network/set?upload_model=$spd > /dev/null 2>&1 &
        wget -O - http://10.0.2.15:8908/peer/limit/network/set?upload_model=$spd > /dev/null 2>&1 &
    fi
    sleep 23
done

