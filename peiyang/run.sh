#!/usr/bin/env bash
# zhangxiaoyang.hit[at]gmail.com

##########################################################
# Please modify COOKIES below
##########################################################
#http://sep.ucas.ac.cn
#sepuser
SEPUSER="xxxx== "

#http://jwjz.ucas.ac.cn/Student
#ASP.NET_SessionId
XUANKE=xxxx

#http://py.ucas.ac.cn/zh-cn/training/zhidingkechengjihua
#ASP.NET_SessionId
PEIYANG=xxxx
##########################################################


##########################################################
# Main
##########################################################
SEPUSER=$(echo "$SEPUSER" | sed 's/["= ]//g')
if [ "$SEPUSER" == "" ] || [ "$XUANKE" == "" ] || [ "$PEIYANG" == "" ]
then
    echo "You should set cookies first"
    exit 1
fi

XUANKE_COOKIE='Cookie: ASP.NET_SessionId='"$XUANKE"'; sepuser='"$SEPUSER"'==  "'
PEIYANG_COOKIE='Cookie: ASP.NET_SessionId='"$PEIYANG"'; sepuser='"$SEPUSER"'==  "'
echo -e "STATUS\tNUM\tXUEWEI\tTIME\tID\tNAME"
curl 'http://jwjz.ucas.ac.cn/Student/DeskTopModules/Course/CourseSelectedMsg.aspx' -s\
    -H 'Accept-Encoding: gzip, deflate, sdch'\
    -H 'Accept-Language: zh-CN,zh;q=0.8,en;q=0.6,ja;q=0.4,zh-TW;q=0.2'\
    -H 'Upgrade-Insecure-Requests: 1'\
    -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/48.0.2564.82 Chrome/48.0.2564.82 Safari/537.36'\
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'\
    -H 'Referer: http://jwjz.ucas.ac.cn/Student/DeskTopModules/Left.aspx'\
    -H "$XUANKE_COOKIE"\
    -H 'Connection: keep-alive'\
    --compressed\
| python parse.py mycourses\
| while IFS=$'\t' read -r -a arr
do
    num=${arr[0]}
    name=${arr[1]}
    xuewei=${arr[2]}
    time=${arr[4]}
    courseId=${arr[5]}

    ckbId=$(curl 'http://py.ucas.ac.cn/zh-cn/training/addcourseplan' -s\
        -H "$PEIYANG_COOKIE"\
        -H 'Origin: http://py.ucas.ac.cn'\
        -H 'Accept-Encoding: gzip, deflate'\
        -H 'Accept-Language: zh-CN,zh;q=0.8,en;q=0.6,ja;q=0.4,zh-TW;q=0.2'\
        -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/48.0.2564.82 Chrome/48.0.2564.82 Safari/537.36'\
        -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8'\
        -H 'Accept: */*' -H 'Referer: http://py.ucas.ac.cn/zh-cn/training/zhidingkechengjihua/1578B5F9CEBF93627677509BF95F0CEC'\
        -H 'X-Requested-With: XMLHttpRequest'\
        -H 'Connection: keep-alive'\
        --data 'BtnAction=search&CourseYears='"$time"'&coursename='"$name"'&X-Requested-With=XMLHttpRequest'\
        --compressed\
        | python parse.py checkbox $courseId)

    if [ "$ckbId" != "None" ]
    then
        curl 'http://py.ucas.ac.cn/zh-cn/training/addcourseplan' -s\
            -H "$PEIYANG_COOKIE"\
            -H 'Origin: http://py.ucas.ac.cn'\
            -H 'Accept-Encoding: gzip, deflate'\
            -H 'Accept-Language: zh-CN,zh;q=0.8,en;q=0.6,ja;q=0.4,zh-TW;q=0.2'\
            -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/48.0.2564.82 Chrome/48.0.2564.82 Safari/537.36'\
            -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8'\
            -H 'Accept: */*' -H 'Referer: http://py.ucas.ac.cn/zh-cn/training/zhidingkechengjihua/1578B5F9CEBF93627677509BF95F0CEC'\
            -H 'X-Requested-With: XMLHttpRequest'\
            -H 'Connection: keep-alive'\
            --data 'BtnAction=add&CourseYears='"$time"'&coursename='"$name"'&ckb='"$ckbId"'&isxwk='"$xuewei"'&X-Requested-With=XMLHttpRequest'\
            --compressed >/dev/null
        echo -e "[OK]\t$num\t$xuewei\t$time\t$courseId\t$name"
    else
        echo -e "[ERROR]\t$num\t$xuewei\t$time\t$courseId\t$name"
    fi
done
