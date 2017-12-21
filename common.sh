
COLOR_RED=$(echo -e "\e[31;49m")
COLOR_GREEN=$(echo -e "\e[32;49m")
COLOR_YELLO=$(echo -e "\e[33;49m")
COLOR_BLUE=$(echo -e "\e[34;49m")
COLOR_MAGENTA=$(echo -e "\e[35;49m")
COLOR_CYAN=$(echo -e "\e[36;49m")
COLOR_WHILE=$(echo -e "\033[1m")
COLOR_RESET=$(echo -e "\e[0m")        
         
## *msg argv: "$str"
msg()  { echo "$@";                               }   
msg_red() { echo "${COLOR_RED}$*${COLOR_RESET}";     }        
msg_green() { echo "${COLOR_GREEN}$*${COLOR_RESET}";   }   
msg_yellow() { echo "${COLOR_YELLO}$*${COLOR_RESET}";   }   
msg_blue() { echo "${COLOR_BLUE}$*${COLOR_RESET}";    }        
msg_magenta() { echo "${COLOR_MAGENTA}$*${COLOR_RESET}"; }
msg_cyan() { echo "${COLOR_CYAN}$*${COLOR_RESET}";    }        
msg_white() { echo "${COLOR_WHILE}$*${COLOR_RESET}";   }   
         
# colourful print without "\n"
msg_()  {  msg "$@" | tr -d '\n'; }
msg_red_() { msg_red "$@" | tr -d '\n'; }
msg_green_() { msg_green "$@" | tr -d '\n'; }
msg_yellow_() { msg_yellow "$@" | tr -d '\n'; }
msg_blue_() { msg_blue "$@" | tr -d '\n'; }
msg_magenta_() { msg_magenta "$@" | tr -d '\n'; }
msg_cyan_() { msg_cyan "$@" | tr -d '\n'; }
msg_white_() { msg_white "$@" | tr -d '\n'; }

#
# 错误退出
#
error_exit()
{
    msg_yellow "退出本次操作！"
    exit 1
}

#
# Ctrl_C function
#
control_c()
{
    exit $?
}
trap control_c SIGINT