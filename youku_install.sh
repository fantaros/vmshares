#!/bin/sh
export PATH='/opt/usr/sbin:/opt/usr/bin:/opt/sbin:/opt/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin'
export LD_LIBRARY_PATH=/opt/youku/lib:/lib

#wget -O /opt/youku_install.sh http://code.taobao.org/svn/test43/youku/youku_install.sh
#sh /opt/youku_install.sh &
#自定义缓存目录
hc_dir=/opt/data
hc_dir=`echo $hc_dir`
[ -z $hc_dir ] && hc_dir=$(df|grep '/media/'|awk '{print$6}'|head -n 1)
#自定义16位sn：2115663623336666
sn_youku=2115669623336989
[ -z $sn_youku ] && sn_youku="2115$(cat /sys/class/net/ra0/address |tr -d ':'|md5sum |tr -dc [0-9]|cut -c 0-12)"
#缓存大小，单位MB。
hc=32000
[ -z $hc ] && hc=32000
#速度模式
#"0" "激进模式：赚取收益优先"
#"2" "平衡模式：赚钱上网兼顾"
#"3" "保守模式：上网体验优先"
spd=0
youku_enable=1

A_restart=2f6feff6579caf5f7779b6e6cfcbab32
B_restart=$youku_enable$hc_dir$sn_youku$hc$spd
B_restart=`echo -n "$B_restart" | md5sum | sed s/[[:space:]]//g | sed s/-//g`
if [ "$A_restart" != "$B_restart" ];then
    needed_restart=1
else
    needed_restart=0
fi
needed_restart=1
if [ "$needed_restart" = "0" ]; then
    exit 1
fi
    [ ${youku_enable:=0} ] && [ "$youku_enable" -eq "0" ] && [ "$needed_restart" = "1" ] && { killall -9 ikuacc; killall -9 youku_install.sh youku_ssmon.sh; exit 0; }
if [ "$youku_enable" = "1" ] ; then
    localpath=`echo $hc_dir`
    if [ ! -d `echo $localpath` ]; then
                echo "[youku]error cache not found"
                echo "[youku] $localpath, set error."
    fi
    SVC_PATH=/opt/youku/bin/ikuacc
    if [ ! -f $SVC_PATH ] ; then
        echo "[youku]auto install ikuacc"
        # 找不到ikuacc，安装opt
    if [ ! -d "/opt/bin" ]; then
    upanPath=""
    ss_opt_x=1
    [ "$ss_opt_x" = "3" ] || [ "$ss_opt_x" = "1" ] && upanPath=`ls -l /media/ | awk '/^d/ {print $NF}'| grep AiCard | sed -n '1p'`
    [ -z $upanPath ] && [ "$ss_opt_x" = "1" ] && upanPath=`ls -l /media/ | awk '/^d/ {print $NF}' | grep -v AiCard | sed -n '1p'`
    [ "$ss_opt_x" = "4" ] && upanPath=`ls -l /media/ | awk '/^d/ {print $NF}' | grep -v AiCard | sed -n '1p'`
    if [ ! -z $upanPath ]; then
        mkdir -p /media/$upanPath/opt
        mount -o bind /media/$upanPath/opt /opt
        ln -sf /media/$upanPath /tmp/AiDisk_00
    else
        mkdir -p /tmp/AiDisk_00/opt
        mount -o bind /tmp/AiDisk_00/opt /opt
    fi
    mkdir -p /opt/bin
    fi
        mkdir -p /opt/youku
        chmod -R 777 /opt/youku
        if [ ! -f $SVC_PATH ] ;then
            echo "error can not found ikuacc"
            /tmp/sh_download.sh "/opt/youku.tgz" "http://code.taobao.org/svn/padavanrt-n56uopt/youku.tgz"
            /tmp/sh_untar.sh /opt/youku.tgz /opt/youku /opt/youku/bin/ikuacc
        else
            echo "[youku] found $SVC_PATH"
        fi
    fi

    [ ! -s "$SVC_PATH" ] && {  echo "[youku] not found $SVC_PATH ，need install manual on $SVC_PATH"; exit 0; }

path=$hc_dir/youku
mkdir -p $path/meta
mkdir -p $path/data
mkdir -p /opt/youku
chmod -R 777 /opt/youku
chmod -R 777 $path/meta
chmod -R 777 $path/data



export LD_LIBRARY_PATH=/opt/youku/lib:/lib
#youku_Total=`cat /proc/meminfo | grep  MemTotal | sed -e s/"MemTotal:"//g | sed -e s/" "//g | sed -e s/"kB"//g`
#youku_Total=`expr $youku_Total - 26472`
killall -9 ikuacc
#ulimit -v $youku_Total
#nvram set youku_Total=$youku_Total
/opt/youku/bin/ikuacc  --device-serial-number="0000$sn_youku"  --mobile-meta-path="$path/meta" --mobile-data-path="$path/data:$hc"  &
logger -t "【路由宝】" "开始运行"
sleep 5
#速度模式
wget -O - http://127.0.0.1:8908/peer/limit/network/set?upload_model=$spd > /dev/null 2>&1 &
wget -O - http://10.0.2.15:8908/peer/limit/network/set?upload_model=$spd > /dev/null 2>&1 &

#获取绑定地址
rm /tmp/youku_sn.log
/opt/youku/bin/getykbdlink 0000$sn_youku >/tmp/youku_sn.log
sleep 3
bdlink=$(grep http -r /tmp/youku_sn.log)
#nvram set youku_bdlink=$bdlink
logger -t "【路由宝】" "绑定地址："
logger -t "【路由宝】" "$bdlink"
echo "Youku $bdlink"
logger -t "【路由宝】" "SN:$sn_youku"
#logger -t "【路由宝】" "虚存最大值：$youku_Total"

#进程保护
/tmp/youku_ssmon.sh &

fi

