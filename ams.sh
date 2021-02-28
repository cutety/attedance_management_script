#!/bin/bash
function main(){
    echo "------------------------------------------------------------"
    echo "          欢迎使用考勤程序！                "
echo "------------------------------------------------------------"
createInfoFile;
#判断是普通用户还是管理员
    while [[ 1 == 1 ]];
    do
        SelectMenu;
        read -p "您是普通用户还是管理员:" op
        case $op in
        		1 )
        			ordinaryUser;
        			;;
        		2 )	
        			adminUser;
        			;;
                3 )
                    exit1;
                    ;;
        		* )
        			echo -e "请选择功能 1 or 2 ! \n"
        			;;
        esac
    done
}
			
#普通用户
function ordinaryUser(){
    read -p "请输入您的账号： " username
read -p "请输入您的密码： " password

isLogin $username $password;

    while [[ 1 == 1 ]];
    do
        menu;
        read -p "请输入您的选择：" choice
        case $choice in
            1 )
                signIn $username;
                ;;
            2 )
                logOff $username;
                ;;
            3 )
                absenceConsult $username;
                ;;
            4 )
                alterPassword $username $password;
                ;;
            5 )
                main;
                ;;
            * )
                echo -e "请选择功能 1 or 2 or 3 or 4！\n"
                ;;
        esac
    done

}
#管理员
function adminUser(){
    read -p "请输入管理员账号： " username
read -p "请输入管理员密码： " password

isAdmin $username $password;

    while [[ 1 == 1 ]];
    do
        Adminmenu;
        read -p "请输入您的选择：" choice
        case $choice in
            1 )
                fireEmployee $username;
                ;;
            2 )
                alterPasswordAdmin;
                ;;
            3 )
                showAllAttendence;
                ;;
            4 )
                soloShowAttendence;
                ;;
            5)
                addMassiveEmployee;
                ;;
            6)
                addSoloEmployee;
                ;;
            0 )
                main;
                ;;
            * )
                echo -e "请选择功能 1 or 2 or 3 or 4！\n"
                ;;
        esac
    done

}
#菜单
function Adminmenu(){
    echo "------------------------------------------------------------"
    echo "                   1.解雇员工              "
    echo "                   2.修改员工密码              "
    echo "                   3.所有员工考勤信息查阅          "
    echo "                   4.单个员工考勤信息查阅          "
    echo "                   5.批量添加员工          "
    echo "                   6.单个添加员工          "
    echo "                   0.退出                  "
    echo "------------------------------------------------------------"
}
#菜单
function menu(){
    echo "------------------------------------------------------------"
    echo "                   1.上班签到              "
    echo "                   2.下班签出              "
    echo "                   3.缺勤信息查阅          "
    echo "                   4.修改密码              "
    echo "                   5.退出                  "
    echo "------------------------------------------------------------"
}
#菜单
function SelectMenu(){
    echo "------------------------------------------------------------"
    echo "                   1.普通用户              "
    echo "                   2.管 理 员              "
    echo "                   3.退    出              "
    echo "------------------------------------------------------------"
}

#检查账号密码
function isLogin(){
    while read line
    do
        if [[ "$line" == "$1:$2" ]]; then
            return 0
        fi
    done < userinfo.dat     #从文件读入
    echo "用户名或密码错误，请重新输入哦"
    read -p "请输入您的账号： " username
    read -p "请输入您的密码： " password
isLogin $username $password;
}
#检查是否是管理员
function isAdmin(){
	while read line
	do
		if [[ "$line" == "$1:$2" ]]; then
			return 0
		fi
	done < adminInfo.dat #从文件读入
	echo "管理员账号密码错误，请重新输入哦"
    read -p "请输入管理员:" adminName
	read -p "请输入管理员密码:" password
	isAdmin $adminName $password;
}
#上班签到
function signIn(){
    hour=`date +%H`
    if [[ ( $hour -gt 8 && $hour -lt 12 ) || ( $hour -gt 15 && $hour -lt 18 ) ]]; then
        echo "你上班迟到了呀！已经将迟到信息记录在check.dat中。"
        echo "$1 上班迟到————日期：`date`" >> check.dat
    else
        echo "上班签到成功！"
    fi
}

#下班签出
function logOff(){
    echo "下班签出成功！"
    hour=`date +%H`
    if [[ ( $hour -lt 18 && $hour -gt 13 ) || ( $hour -gt 8 && $hour -lt 12 ) ]]; then
        echo "你现在属于早退哦！已经将早退信息记录在check.dat中。"
        echo "$1 下班早退————日期：`date`" >> check.dat
    fi
}

#缺勤查阅
function absenceConsult(){
    cat check.dat|grep -n "$1"
}
#修改密码
function alterPassword(){
    read -p "输入新密码" newpassword
    sed -i '/'$1'/c\'$1':'$newpassword'' userinfo.dat
    echo "已成功将密码修改为"$newpassword
}
#管理员操作
#解雇
function fireEmployee(){
    read -p "输入要开除的员工姓名" name
    sed -i ''/$name'/d' userinfo.dat
    sed -i ''/$name'/d' check.dat
    echo $name "已被成功解雇"

}
#修改密码admin
function alterPasswordAdmin(){
    read -p "输入要修改密码的员工姓名" userNm
    read -p "输入新密码" newpassword
    #sed -n '/'$1':'$2'/p' userinfo.dat
    sed -i '/'$userNm'/c\'$userNm':'$newpassword'' userinfo.dat
    echo "已成功将密码修改为"$newpassword
}
#查看全部人员考勤信息
function showAllAttendence(){
    cat check.dat
}
#单独查看考勤信息
function soloShowAttendence(){
    read -p "输入要查看的员工姓名" name
    echo -e $name "缺勤的次数:\c"
    cat check.dat|grep -wc "$name"
}
#批量添加员工
function addMassiveEmployee(){
    cat newEmployee.dat >> userinfo.dat
}
#单独添加员工
function addSoloEmployee(){
    read -p "输入要添加员工的姓名" names
    read -p "输入要添加员工的密码" psw
    echo "$names:$psw" >> userinfo.dat
    echo "$names:$psw添加成功"
}
#自动解雇
function autoFireEmployee(){
    cat check.dat
}
#退出程序
function exit1(){
    exit 0
}

#创建配置文件
function createInfoFile(){
    if [[ ! -e userinfo.dat ]]; then
        touch userinfo.dat   #保存用户名和密码
        chmod 777 userinfo.dat
    fi
    if [[ ! -e check.dat ]]; then
        touch check.dat   #保存迟到早退信息
        chmod 777 check.dat
    fi
    if [[ ! -e adminInfo.dat ]]; then
        touch adminInfo.dat
        chmod 777 adminInfo
    fi
}

#执行main函数
main
