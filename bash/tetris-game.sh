#!/bin/bash
# Tetris Game  // The Art Of Shell Programming

#########################################################################
#                                                                       #
#   License: Boost Ver 1.0+                                             #
#   Project: https://github.com/yongye/c                                #
#   Project: https://github.com/yongye/go                               #
#   Project: https://github.com/yongye/cpp                              #
#   Project: https://github.com/yongye/shell                            #
#   Author : YongYe <complex.invoke@gmail.com>                          #
#   Version: 7.1.4 11/01/2011 BeiJing China [Updated 12/01/2013]        #
#                                                                       # 
#   Algorithm:                                                          #
#                                                                       #
#   [][] [][]   [][]            [][]   [][]          [][]   [][] [][]   #
#   [] row []   [] cos(a) -sin(a) []   [] (x-m)*zoomx  []   []  m  []   #
#   []     [] = []                []   []              [] + []     []   #
#   [] col []   [] sin(a)  cos(a) []   [] (y-n)*zoomy  []   []  n  []   #
#   [][] [][]   [][]            [][]   [][           [][]   [][] [][]   #
#                                                                       #
#########################################################################

box0=(4 30)
box1=(4 30 4 32)
box2=(4 30 5 32)
box3=(4 28 4 30 4 32)
box4=(4 28 4 30 5 30)
box5=(4 28 5 30 6 32)
box6=(4 30 5 28 5 32)
box7=(4 28 5 30 6 32 7 34)
box8=(4 30 5 28 5 30 5 32)
box9=(4 30 5 28 5 32 6 30)
box10=(4 28 4 30 4 32 4 34)
box11=(4 28 5 28 5 30 5 32)
box12=(4 28 4 30 5 30 5 32)
box13=(4 28 4 30 5 28 5 30)
box14=(4 28 4 34 5 30 5 32)
box15=(4 26 4 28 4 30 4 32 4 34)
box16=(4 30 5 28 5 30 5 32 6 30)
box17=(4 28 4 32 5 30 6 28 6 32)
box18=(4 28 4 32 5 28 5 30 5 32)
box19=(4 28 4 30 5 30 6 30 6 32)
box20=(4 28 5 28 6 28 6 30 6 32)
box21=(4 28 4 30 5 30 5 32 6 32)
box22=(4 26 4 34 5 28 5 30 5 32)
box23=(4 26 4 34 5 28 5 32 6 30)
box24=(4 26 5 28 6 30 7 32 8 34)
box25=(4 28 4 32 5 26 5 30 5 34)
box26=(4 28 4 34 5 30 5 32 6 30 6 32 7 28 7 34)
box27=(4 30 5 28 5 32 6 26 6 30 6 34 7 28 7 32 8 30)
box28=(4 30 5 28 5 30 5 32 6 26 6 28 6 30 6 32 6 34 7 28 7 30 7 32 8 30)
box29=(4 30 5 30 6 28 6 30 6 32 7 26 7 30 7 34 8 30 9 30 10 30 11 30 12 30)
box30=(4 26 4 28 4 30 4 34 5 30 5 34 6 26 6 28 6 30 6 32 6 34 7 26 7 30 8 26 8 30 8 32 8 34)
box31=(4 30 5 28 6 26 6 34 7 28 7 32 7 36 8 22 8 30 8 38 9 24 9 28 9 32 10 26 10 34 11 32 12 30)

unit=[]
toph=3
modw=4
scorelevel=0
width=${5:-25}
height=${6:-30}
prelevel=${3:-6}
speedlevel=${4:-0}
BOX=(box{0..31}[@])
((width=width<17?25:width))
((height=height<10?30:height))
((lower=height+toph))
((wthm=2*width+modw))
((dist=modw+wthm+3))
((prelevel=prelevel<1?6:prelevel))
((speedlevel=speedlevel>30?0:speedlevel))
gmover="\e[?25h\e[36;26HGame Over!\e[0m\n"
color=(1\;{30..38}\;{40..48}m {38,48}\;5\;{0..255}\;1m)

sig.trans(){ kill -${1} ${pid}; }
get.check(){ (( ! box_map[index] )) && k=1; }
get.piece(){ box=(${!BOX[RANDOM%runlevel]}); }
run.initi(){ box_map[index]=0; box_color[index]=""; }
get.erase(){ printf "${old_shadow//${unit}/  }\e[0m\n"; }
get.resum(){ stty ${oldtty}; printf "\e[?25h\e[36;4H\n"; }
cmp.coord(){ (( ${1} <= ${2} )) && { ((${5})); (( ${3} < ${4} )) && ((${6})); }; }
run.prbox(){ old_shadow="${cur_shadow}"; printf "\e[${cur_color}${cur_shadow}\e[0m\n"; }
run.level(){ lhs=${#BOX[@]}; rhs=${1:-$((lhs-1))}; ((runlevel=(rhs < 0 || rhs > lhs-1)?lhs:rhs+1)); }
run.leave(){ (( ! ${#} )) && printf "${gmover}" || { (( ${#}%2 )) && sig.trans 22; get.resum; }; exit; }
get.stime(){ (( ${1} == ${2} )) && { ((++${3})); ((${1}=0)); }; Time[${4}]=$((${!1}/10))$((${!1}%10)); }

max.vertical.coordinate()
{
   local i col row val
   for ((i=0; i!=${#box[@]}; i+=2)); do
         ((val=box[i+1]))
         if (( col[val] < box[i] )); then
               ((col[val]=box[i]))
               row[val]="${col[val]} ${val}"
         fi
   done
   max=(${row[@]})
}

get.update()
{ 
   pos="\e[${i};${j}H"
   (( ! box_map[index] )) && printf "${pos}  " || printf "${pos}\e[${box_color[index]}${unit}\e[0m"
}

ini.loop()
{
   local i j k l index
   for ((i=modw,j=6,l=wthm; i<=lower; j+=2)); do
         k=0; ((index=(i-modw)*width+j/2-toph)); ${1}
         if (( k || j == l )); then
               (( ! k )) && ${2}
               j=modw; ((++i))
         fi
   done
}

map.piece()
{
   local j p q u
   ((++line))
   for ((j=i,u=6; j>toph+1; u+=2)); do
         ((p=(j-modw)*width+u/2-toph)); ((q=p-width))
         ((box_map[p]=box_map[q])); box_color[p]="${box_color[q]}"
         (( u == l )) && { u=modw; ((--j)); }
   done
   for ((u=6; u<=l; u+=2)); do
         box_map[u/2-toph]=0
         box_color[u/2-toph]=""
   done
}

get.preview()
{
   local i col cur_box
   cur_box=(${!1})
   for ((i=0; i!=${#cur_box[@]}; i+=2)); do
         ((col=cur_box[i+1]-(${3}-dist)))
         cur_preview_block+="\e[$((cur_box[i]-1));${col}H${unit}"
   done
   printf "${!2//${unit}/  }\e[${!4}${cur_preview_block}\e[0m\n"
}

pipe.piece()
{
   cur_preview_block=""
   (( ${5} )) && {
   get.piece
   eval ${1}="(${box[@]})"
   cur_color="${color[RANDOM%${#color[@]}]}"
   eval ${6}=\"${cur_color}\"
   get.preview box[@] ${3} ${4} cur_color
   } || {
   eval ${1}="(${!2})"
   eval ${6}=\"${!7}\"
   get.preview ${2} ${3} ${4} ${7}
   }
   eval ${3}=\"${cur_preview_block}\"
}

get.invoke()
{
   local i arya aryb
   for ((i=0; i!=prelevel-1; ++i)); do
         arya=(next_preview_piece${i} next_preview_piece$((i+1))[@] old_preview_block${i})
         aryb=($((12*(2-i))) ${1} next_preview_color${i} next_preview_color$((i+1))) 
         pipe.piece ${arya[@]} ${aryb[@]} 
   done
}

show.piece()
{
   local end cur_preview_block 
   ((end=prelevel-1))
   cur_color="${next_preview_color0}"
   preview_box=(${next_preview_piece0[@]})
   get.invoke ${#}
   cur_preview_block=""
   get.piece
   eval next_preview_piece${end}="(${box[@]})"
   eval next_preview_color${end}=\"${color[RANDOM%${#color[@]}]}\"
   get.preview box[@] old_preview_block${end} $((12*(2-end))) next_preview_color${end}
   eval old_preview_block${end}=\"${cur_preview_block}\"
   box=(${preview_box[@]})
}

draw.piece()
{
   (( ${#} )) && {
      get.piece
      cur_color="${color[RANDOM%${#color[@]}]}"
      coor.dinate box[@]
   } || {
   cur_color="${next_preview_color0}"
   coor.dinate next_preview_piece0[@]
   }
   run.prbox 
   if ! move.piece; then
        kill -22 ${PPID}
        sig.trans 22
        run.leave
   fi
}

top.point()
{
   local i u v x y
   ((u=cur_box[0]))
   ((v=cur_box[1]))
   for ((i=0; i!=${#cur_box[@]}; i+=2)); do
         cmp.coord x cur_box[i] y cur_box[i+1] x=cur_box[i] y=cur_box[i+1]   
         cmp.coord cur_box[i] u cur_box[i+1] v u=cur_box[i] v=cur_box[i+1]
   done
   if (( x-u == 3 && y-v == 6 )); then
         cur_box=($((x-3)) $((y-6)) $((x-3)) ${y} ${x} $((y-6)) ${x} ${y})
   fi
}

run.bomb()
{
   local j p q boolp boolq empty index radius
   radius=(x-1 y-2 x-1 y x-1 y+2 x y-2 x y x y+2 x+1 y-2 x+1 y x+1 y+2)
   for ((j=0; j!=${#radius[@]}; j+=2)); do
         ((p=radius[j]))
         ((q=radius[j+1]))
         ((index=(p-modw)*width+q/2-toph))
         ((boolp=(p > toph && p <= lower)))
         ((boolq=(q <= wthm && q > modw+1)))
         if (( boolp && boolq )); then
               (( ! box_map[index] && p+q != x+y && ${1} != 8 )) && continue
               empty+="\e[${p};${q}H\040\040"
               run.initi 
         fi
   done
   sleep 0.03; printf "${empty}\n"
} 

random.piece()
{
   local i j k l 
   ((++count))
   ((l=height-1))
   for ((i=0,j=6; i!=count; j+=2)); do
         ((k=(l-i)*width+j/2-toph))
         (( j == wthm )) && { j=modw; ((++i)); }
         (( RANDOM%2 )) && { box_map[k]=1; box_color[k]="${color[RANDOM%${#color[@]}]}"; }
   done
   (( count == l )) && count=0
}

del.row()
{
   local i x y len num index line cur_box
   cur_box=(${locus[@]})
   len=${#cur_box[@]}
   (( len == 16 )) && top.point
   for ((i=0; i!=${#cur_box[@]}; i+=2)); do
         ((x=cur_box[i]))
         ((y=cur_box[i+1]))
         (( len == 16 )) && run.bomb ${#cur_box[@]} || {
            ((index=(x-modw)*width+y/2-toph))
            ((box_map[index]=1))
            box_color[index]="${cur_color}"
         }
   done
   line=0
   ini.loop get.check map.piece
   (( ! line )) && return 1
   ((num=line*200-100))
   printf "\e[1;34m\e[$((toph+10));$((dist+49))H$((scorelevel+=num))\e[0m\n"
   if (( scorelevel%5000 < num && speedlevel < 30 )); then
         random.piece
         printf "\e[1;34m\e[$((toph+10));$((dist+30))H$((++speedlevel))\e[0m\n"
   fi
   ini.loop get.update
}        

get.ctime()
{
   local d h i j k m s line Time color
   trap "run.leave" 22 
   ((d=0, h=0, m=0, s=0))
   ((j=width-9))
   for ((k=0; k!=j; ++k)) { line+=-; }
   color="\e[1;33m"
   printf "\e[2;6H${color}${line}[Time \e[2;$((23+j))H${color}]${line}\e[0m\n"
   while :; do
         sleep 1 &
         get.stime s 60 m 0
         get.stime m 60 h 1
         get.stime h 24 d 2
         Time[3]=$((d/10))$((d%10))
         printf "\e[2;$((12+j))H${color}${Time[3]}:${Time[2]}:${Time[1]}:${Time[0]}\e[0m\n"
         wait; ((++s))
   done
}
 
per.sig()
{
   local i j pid sig sigswap
   pid=${1} 
   for i in {23..31}; do
         trap "sig=${i}" ${i}
   done
   trap "sig.trans 22; run.leave" 22
   while (( ++j )); do 
         (( j != 1 )) && sleep 0.02
         sigswap=${sig}
         sig=0
         case ${sigswap} in
         23)  per.transform   -1                  ;;
         24)  per.transform    1                  ;;
         25)  per.transform   -2                  ;;
         26)  per.transform    1/2                ;;
         27)  per.transform    0             -2   ;;
         28)  per.transform    0              2   ;;
         29)  per.transform    1              0   ;;
         30)  per.transform   -1              0   ;;
         31)  per.transform    $(drop.bottom) 0   ;;
         esac
         (( j == 31-speedlevel )) && { per.transform  1  0; j=0; }
   done
}

get.sig()
{
   local pid sig key arry escape oldtty
   printf "\e[?25l"
   pid=${1}; arry=(0 0 0)
   escape="$(printf "\e")"; oldtty="$(stty -g)"
   trap "run.leave 0" INT TERM; trap "run.leave 0 0" 22
   while read -s -n 1 key; do
         arry[0]=${arry[1]}; arry[1]=${arry[2]}
         arry[2]=${key}; sig=0
         if   [[ ! "${key}" ]]; then sig=31      
         elif [[ "${key}${arry[1]}" == "${escape}${escape}" ]]; then run.leave 0
         elif [[ "${arry[0]}" == "${escape}" && "${arry[1]}" == "[" ]]; then
                 case ${key} in
                 A)    sig=23         ;;
                 B)    sig=29         ;;
                 D)    sig=27         ;;
                 C)    sig=28         ;;
                 esac
         else
                 case ${key} in
                 W|w)  sig=23         ;;
                 T|t)  sig=24         ;;
                 M|m)  sig=25         ;;
                 N|n)  sig=26         ;;
                 S|s)  sig=29         ;;
                 A|a)  sig=27         ;;
                 D|d)  sig=28         ;; 
                 U|u)  sig=30         ;; 
                 P|p)  sig.trans  19  ;;
                 R|r)  sig.trans  18  ;;
                 Q|q)  run.leave   0  ;;
                 esac
         fi
                 (( sig != 0 )) && sig.trans ${sig}
   done
}

drop.bottom()
{  
   local i j col max row
   max.vertical.coordinate
   for ((i=0,j=0; i!=height; j+=2)); do
         ((row=(max[j]+i == lower)))
         ((col=box_map[(max[j]+i-toph)*width+max[j+1]/2-toph]))
         (( col || row )) && { echo ${i}; return 0; }
         (( j+2 == ${#max[@]} )) && { j=-2; ((++i)); }
   done
}

move.piece()
{
   local i j x y boolx booly index
   len=${#locus[@]}
   for ((i=0; i!=len; i+=2)); do    
         ((x=locus[i]+dx)) 
         ((y=locus[i+1]+dy))
         ((index=(x-modw)*width+y/2-toph))
         (( index < 0 || index > width*height-1 )) && return 1
         ((boolx=(x <= toph || x > lower)))
         ((booly=(y >= wthm+2 || y <= modw+1)))
         (( boolx || booly )) && return 1
         if (( box_map[index] )); then
               if (( len == 2 )); then
                     for ((j=lower; j>x; --j)); do
                           (( ! box_map[(j-modw)*width+y/2-toph] )) && return 0
                     done
               fi
               return 1
         fi
   done 
   return 0  
}

ghost.cross()
{
   local i j index
   ((i=locus[0]))
   ((j=locus[1]))
   ((index=(i-modw)*width+j/2-toph))
   (( box_map[index] )) && printf "\e[${i};${j}H\e[${box_color[index]}${unit}\e[0m\n"
}

coor.dinate()
{
   local i
   locus=(${!1})
   for ((i=0; i!=${#locus[@]}; i+=2)); do    
         cur_shadow+="\e[${locus[i]};${locus[i+1]}H${unit}"
   done
}

get.optimize()
{
   for j in dx dy; do
         (( j )) && { [[ ${j} == dx ]] && k=i || k=i+1; add.box; }
   done
}

add.box()
{
   for ((i=0; i!=${#new_box[@]}; i+=2)); do
         ((new_box[k]+=j))
   done
}

per.plus()
{
   local i j k
   (( len == 2 )) && ghost.cross
   new_box=(${box[@]})
   get.optimize
   coor.dinate new_box[@]
   box=(${new_box[@]})
}

get.move()
{
   if move.piece; then
        get.erase
        per.plus
        run.prbox
   else
        (( dx == 1 )) && {
        del.row  
        draw.piece 
        show.piece
        }
   fi
}

mid.point()
{
   local len mid
   mid=(${!1})
   ((len=${#mid[@]}/2-(${#mid[@]}%4)/2))
   ((${2}=mid[len]))
   ((${3}=mid[len+1]))
}

per.multiple()
{
   local i mid cur_box
   mid=(${!1})
   cur_box=(${!1})
   for ((i=0; i!=${#mid[@]}-2; i+=2)); do
         ((mid[i+3]=mid[i+1]+(cur_box[i+3]-cur_box[i+1])${2}2))
   done
   new_box=(${mid[@]})
}

run.unique()
{
   local i col mid row
   declare -A mid
   for ((i=0; i!=${#new_coordinate[@]}; i+=2))
   {
         ((row=new_coordinate[i]))
         ((col=new_coordinate[i+1]))
         mid[${row}::${col}]="${row} ${col}"
   }
   new_coordinate=(${mid[@]})
}

coordinate.transformation()
{
   local i                                              # row=(x-m)*zoomx*cos(a)-(y-n)*zoomy*sin(a)+m
   for ((i=0; i!=${#new_box[@]}; i+=2)); do             # col=(x-m)*zoomx*sin(a)+(y-n)*zoomy*cos(a)+n
         ((new_coordinate[i]=m+new_box[i+1]-n))         # a=-pi/2 zoomx=+1 zoomy=+1 dx=0 dy=0
         ((new_coordinate[i+1]=(new_box[i]-m)*${dx}+n)) # a=-pi/2 zoomx=-1 zoomy=+1 dx=0 dy=0 
   done                                                 # a=+pi/2 zoomx=+1 zoomy=-1 dx=0 dy=0
   [[ ${dx} == 1/2 ]] && run.unique 
}

mid.plus()
{
   local i j k dx dy
   ((dx=mp-p))
   ((dy=nq-q))
   get.optimize
}

per.abstract()
{
   per.multiple ${1} "${2}"
   mid.point new_box[@] ${3} ${4} 
}

per.rotate()
{     
   local m n p q mp nq new_coordinate
   mid.point box[@] mp nq 
   per.abstract box[@] "/" m n
   coordinate.transformation; dx=0
   per.abstract new_coordinate[@] "*" p q
   mid.plus; locus=(${new_box[@]})
   if move.piece; then
       get.erase; coor.dinate new_box[@]
       run.prbox; box=(${locus[@]})
   else
       locus=(${box[@]})
   fi
}

per.transform()
{ 
   local dx dy len new_box cur_shadow
   dx=${1}
   dy=${2}
   case ${#} in
   2) get.move   ;;
   1) per.rotate ;;
   esac
}

show.matrix()
{
   one=" "
   end="\e[0m"
   block="[][]"
   two="${one}${one}"
   cube="${one}${two}"
   five="${two}${cube}"
   ten="${five}${five}"         
   equ="\e[38;5;191;1m"
   colbon="\e[38;5;47;1m"
   mcol="\e[38;5;30;1m"
   str5="${ten}${ten}"
   str4="${mcol}[]${end}"
   str0="${colbon}[]${end}"
   str1="${colbon}${block}${end}"
   str6="${mcol}[]${block}${end}"
   str2="${colbon}[]${block}${end}"
   str3="${colbon}${block}${block}${end}"
   str="${cube}${str0}${two}${str3}${two}${str3}"
   str7="${str1}${one}${str1}${str}${str4}${two}${two}"
   str8="${str0}${one}${equ}row${one}${str0}${cube}${str0}${two}${str0}${one}${equ}(x-m)*zoomx${two}"
   str9="${one}${equ}=${one}${str0}${two}${str0}${ten}${cube}${one}${str0}${cube}${equ}*${two}"
   str10="${ten}${five}${two}${str0}${two}${str0}${one}${equ}+${one}${str0}${five}${str0}"
   str11="${cube}${one}${str0}${two}${equ}cos(a)${one}${equ}sin(a)${two}${str0}${two}${str0}${cube}${str0}${two}${equ}m${two}${str0}"
   str12="${one}${equ}col${one}${str0}${cube}${str0}${two}${str0}${one}${equ}(y-n)*zoomy${two}${str0}${five}${one}"
   str13="${one}${equ}-sin(a)${one}${equ}cos(a)${two}${str0}${two}${str0}${cube}${str0}${two}${equ}n${two}${str0}"
   str14="${str1}${one}${str1}${str}${five}${one}"
   str15="${str1}${two}${str0}${cube}${str1}${one}${str1}"
   printf "\e[$((toph+23));${dist}H${colbon}Algorithm:${two}${str2}${one}${str5}${str5}${str2}${str4}\n"
   printf "\e[$((toph+30));${dist}H${ten}${two}${str0}${two}${two}${five}${str5}${str5}${str0}\n"
   printf "\e[$((toph+25));${dist}H${str7}${str1}${ten}${cube}${str1}${two}${str0}${cube}${str1}${one}${str1}\n"
   printf "\e[$((toph+26));${dist}H${str8}${str0}${str4}${str11}\e[$((toph+28));${dist}H${str0}${str12}${str0}${str13}\n"
   printf "\e[$((toph+24));${dist}H${two}${ten}${str0}${ten}${cube}${two}${cube}${str6}${str5}${five}${str0}${str4}\n"
   printf "\e[$((toph+22));${dist}H${cube}${str5}${str5}${str5}${str6}\e[$((toph+29));${dist}H${str14}${str1}${ten}${cube}${str15}\n"
   printf "\e[$((toph+27));${dist}H${str0}${five}${str0}${str9}${str0}${str10}\e[$((toph+31));${dist}H${ten}${two}${str2}${str5}${str5} ${str2}\n"
}

show.board()
{
   clear
   boucol="\e[38;5"
   ((colour=RANDOM%145+6))
   for ((i=6; i<=wthm; i+=2)); do
         printf "${boucol};$((colour+i));1m\e[${toph};${i}H==${boucol};$((colour+i+25));1m\e[$((lower+1));${i}H==\e[0m\n"
   done
   for ((i=toph; i<=lower+1; ++i)); do
         printf "${boucol};$((colour+i));1m\e[${i};${modw}H||${boucol};$((colour+i+30));1m\e[${i};$((wthm+2))H||\e[0m\n"
   done
}

show.notify()
{
   printf "\e[1;31m\e[$((toph+9));${dist}HRunLevel\e[1;31m\e[$((toph+9));$((dist+15))HPreviewLevel\e[0m\n"
   printf "\e[1;31m\e[$((toph+9));$((dist+30))HSpeedLevel\e[1;31m\e[$((toph+9));$((dist+49))HScoreLevel\e[0m\n"
   printf "\e[1;34m\e[$((toph+10));$((dist+49))H${scorelevel}\e[1;34m\e[$((toph+10));$((dist+30))H${speedlevel}\e[0m\n"
   printf "\e[1;34m\e[$((toph+10));${dist}H$((runlevel-1))\e[1;34m\e[$((toph+10));$((dist+15))H${prelevel}\e[0m\n"
   printf "\e[38;5;34;1m\e[$((toph+12));${dist}HM|m      ===   double         N|n          ===   half\n"
   printf "\e[$((toph+13));${dist}HQ|q|ESC  ===   exit           U|u          ===   one step up\n"
   printf "\e[$((toph+14));${dist}HP|p      ===   pause          S|s|down     ===   one step down\n"
   printf "\e[$((toph+15));${dist}HR|r      ===   resume         A|a|left     ===   one step left\n"
   printf "\e[$((toph+16));${dist}HW|w|up   ===   rotate         D|d|right    ===   one step right\n"
   printf "\e[$((toph+17));${dist}HT|t      ===   transpose      Space|enter  ===   drop all down\n"
   printf "\e[38;5;106;1m\e[$((toph+19));${dist}HTetris Game  Version 7.1.4\n"
   printf "\e[$((toph+20));${dist}HYongYe <complex.invoke@gmail.com>\e[$((toph+21));${dist}H11/01/2011 BeiJing China [Updated 12/01/2013]\n"
}

   case ${1} in
   -h|--help)    echo "Usage: bash ${0} [runlevel] [previewlevel] [speedlevel]  [width] [height]"
                 echo "Range: [ 0 <= runlevel <= $((${#BOX[@]}-1)) ]   [ previewlevel >= 1 ]   [ speedlevel <= 30 ]   [ width >= 17 ]   [ height >= 10 ]" ;;
   -v|--version) echo "Tetris Game  Version 7.1.4 [Updated 12/01/2013]" ;;
   ${PPID})      run.level ${2}; ini.loop run.initi 
                 show.board; show.notify
                 show.piece 0; draw.piece 0
                 show.matrix; get.ctime &
                 per.sig ${!} ;;
   *)            bash ${0} ${$} ${@} &
                 get.sig ${!} ;;
   esac