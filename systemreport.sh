#!/usr/bin/env bash
#
# Jens Roesen <jens@roesen.org>
# 2017-09-01
#
# Kurze Bestandsaufnahme von Linux Systemen.
# Fuer genaue Ergebnisse bitte als root starten.
#
# TODO: Virtualisierung, Vereinfachen mit Funktionen

# Da wir Fehlerhafte Kommandos erwarten und auch mal Whitespace
# als Trenner wollen, lassen wir das vorerst weg:
# set -euo pipefail
# IFS=$'\n\t'

# Systemtools
readonly APACHECTL=$(command -v apachectl)
readonly APACHE2CTL=$(command -v apache2ctl)
readonly APTCACHE=$(command -v apt-cache)
readonly ARP=$(command -v arp)
readonly AWK=$(command -v awk)
readonly BASENAME=$(command -v basename)
readonly CAT=$(command -v cat)
readonly CHKCONFIG=$(command -v chkconfig)
readonly COLUMN=$(command -v column)
readonly CRONTAB=$(command -v crontab)
readonly CUT=$(command -v cut)
readonly DATE=$(command -v date)
readonly DF=$(command -v df)
readonly DIG=$(command -v dig)
readonly DMIDECODE=$(command -v dmidecode)
readonly DOCKER=$(command -v docker)
readonly DPKG=$(command -v dpkg)
readonly DRBDOVERVIEW=$(command -v drbd-overview)
readonly ECHO=$(command -v echo)
readonly ETHTOOL=$(command -v ethtool)
readonly FDISK=$(command -v fdisk)
readonly FIND=$(command -v find)
readonly FIREWALLCMD=$(command -v firewall-cmd)
readonly FREE=$(command -v free)
readonly GETENFORCE=$(command -v getenforce)
readonly GETSEBOOL=$(command -v getsebool)
readonly GREP=$(command -v grep)
readonly HOSTNAMECMD=$(command -v hostname)
readonly HWINFO=$(command -v hwinfo)
readonly IFCONFIG=$(command -v ifconfig)
readonly INITCTL=$(command -v initctl)
readonly IP=$(command -v ip)
readonly IPTABLES=$(command -v iptables)
readonly LS=$(command -v ls)
readonly LSBLK=$(command -v lsblk)
readonly LSBRELEASE=$(command -v lsb_release)
readonly LSCPU=$(command -v lscpu)
readonly LSHW=$(command -v lshw)
readonly LSOF=$(command -v lsof)
readonly LSPCI=$(command -v lspci)
readonly LSSCSI=$(command -v lsscsi)
readonly LSUSB=$(command -v lsusb)
readonly LVDISPLAY=$(command -v lvdisplay)
readonly MAILQ=$(command -v mailq)
readonly MOUNT=$(command -v mount)
readonly NAMED=$(command -v named)
readonly NETSTAT=$(command -v netstat)
readonly NMCLI=$(command -v nmcli)
readonly NSLOOKUP=$(command -v nslookup)
readonly PGREP=$(command -v pgrep)
readonly POSTCONF=$(command -v postconf)
readonly POSTFIX=$(command -v postfix)
readonly PS=$(command -v ps)
readonly PVDISPLAY=$(command -v pvdisplay)
readonly RNDC=$(command -v rndc)
readonly ROUTE=$(command -v route)
readonly SCRIPT=$(command -v script)
readonly SED=$(command -v sed)
readonly SEMANAGE=$(command -v semanage)
readonly SERVICE=$(command -v service)
readonly SORT=$(command -v sort)
readonly SYSTEMCTL=$(command -v systemctl)
readonly TAIL=$(command -v tail)
readonly TIMEOUT=$(command -v timeout)
readonly TCPDUMP=$(command -v tcpdump)
readonly UPTIME=$(command -v uptime)
readonly VGDISPLAY=$(command -v vgdisplay)
readonly VIRSH=$(command -v virsh)
readonly VIRTWHAT=$(command -v virt-what)
readonly WHOAMI=$(command -v whoami)
readonly XM=$(command -v xm)
readonly YUM=$(command -v yum)

# Hostnamen einstampfen fuer die "nach oben" Links
readonly HOSTNAMECLN=$($HOSTNAMECMD | $SED 's/[^[:alnum:]-]//g')

# Handelt es sich um eine VM?
if $GREP -qEe "^flags.*hypervisor.*" /proc/cpuinfo
then
    readonly ISVM=true
    readonly VMNOTICE="Virtualisiertes "
    if [[ -n $VIRTWHAT ]]
    then
        readonly HYPERTYPE=$($VIRTWHAT)
    fi
else
    readonly ISVM=false
fi

# Sind wir root?
if [[ $UID == 0 ]]
then
    readonly ISROOT=true
else
    readonly ISROOT=false
    readonly CURUSER=$($WHOAMI)
fi

# Funktionen
vmwarn() {
    if [[ $ISVM == true ]]
    then
        $ECHO -e "\n*Bitte beachten: System ist eine VM.*"
    fi 
}

# RedHat basiertes hat yum, Debian und Freunde haben dpkg und wenn wir nix davon
# finden haben wir was anderes und steigen lieber mal aus.
if [[ -n $YUM ]]
then
    DISTRIBUTION=rhel
elif [[ -n $DPKG ]]
then
    DISTRIBUTION=debian
else
    $ECHO -e "\nWEDER YUM NOCH DPKG GEFUNDEN! GEBE AUF!"
    exit 1
fi

# Hier gehts los

$ECHO -e "# " $($HOSTNAMECMD)
$ECHO -e "generiert am " $($DATE) "\n"

$ECHO -e "<!-- TOC -->\n\n<!-- /TOC -->\n"

###########################################
#
# OS Infos
#
########################################### 

$ECHO -e "## Operating System"

if [[ $DISTRIBUTION == "rhel" ]]
then
    if [[ -n $LSBRELEASE ]]
    then
        $ECHO -e "\n### ${VMNOTICE}RHEL/CentOS. Version" '`lsb_release`:'
        $ECHO -e '```'
        $LSBRELEASE -a 2>/dev/null
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    else
        $ECHO -e "\n### ${VMNOTICE}RHEL/CentOS. Version" '`/etc/redhat-release`:'
        $ECHO -e '```'
        $CAT /etc/redhat-release
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    fi
elif [[ $DISTRIBUTION == "debian" ]]
then
    if [[ -n $LSBRELEASE ]]
    then
        $ECHO -e "\n### ${VMNOTICE}Debian. Version" '`lsb_release`:'
        $ECHO -e '```'
        $LSBRELEASE -a 2>/dev/null
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    else
        $ECHO -e "\n### ${VMNOTICE}Debian. Version" '`/etc/debian_version`:'
        $ECHO -e '```'
        $CAT /etc/debian_version
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    fi
fi

if [[ -f "/etc/issue" ]]
then
    $ECHO -e "\n### Loginmeldung aus" '`/etc/issue`:'
    $ECHO -e '```'
    $CAT /etc/issue
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi

# User und Gruppen
$ECHO -e "\n## User\n"

$ECHO -e "\n### Lokale User aus" '`'/etc/passwd'`:'
$ECHO -e '```'
$CAT /etc/passwd
$ECHO -e '```'
$ECHO "[nach oben](#${HOSTNAMECLN})"

$ECHO -e "\n### Lokale Gruppen aus" '`'/etc/group'`:'
$ECHO -e '```'
$CAT /etc/group
$ECHO -e '```'
$ECHO "[nach oben](#${HOSTNAMECLN})"

# Disabled by default ;)
#if [[ $ISROOT == true ]]
#    then
#        $ECHO -e "\n### Lokale User aus" '`'/etc/shadow'`:'
#        $ECHO -e '```'
#        $CAT /etc/shadow
#        $ECHO -e '```'
#    fi
#fi

# Crontabs
if [[ $ISROOT == true ]]
then
    if [[ -d "/var/spool/cron/crontabs" ]]
    then
        while IFS= read -r -d '' CRONFILE; do
            $ECHO -e "\n### Crontab von $($BASENAME $CRONFILE)"
            $ECHO -e '```'
            $CAT $CRONFILE
            # alternativ:
            # $CRONTAB -l -u $($BASENAME $CRONFILE)
            $ECHO -e '```'
            $ECHO "[nach oben](#${HOSTNAMECLN})"
        done < <(find /var/spool/cron/crontabs -maxdepth 1 -type f -print0)  
    elif [[ -d "/var/spool/cron" ]]
    then
            while IFS= read -r -d '' CRONFILE; do
            $ECHO -e "\n### Crontab von $($BASENAME $CRONFILE)"
            $ECHO -e '```'
            $CAT $CRONFILE
            # alternativ:
            # $CRONTAB -l -u $($BASENAME $CRONFILE)
            $ECHO -e '```'
            $ECHO "[nach oben](#${HOSTNAMECLN})"
        done < <(find /var/spool/cron -maxdepth 1 -type f -print0)  
    fi
else
    $ECHO -e "\n### Crontab vom User " '`'$CURUSER'`:'
    $ECHO -e '```'
    $CRONTAB -l
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi 

# Services, Dienste usw.
if [[ $DISTRIBUTION == "rhel" ]]
then
    $ECHO -e "\### Systemstart"
    if [[ -n $SYSTEMCTL ]]
    then
        $ECHO -e "\n#### SystemD Units (nur Services)" '`systemctl`:'
        $ECHO -e '```'
        $SYSTEMCTL list-units --type=service --no-pager
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"

        $ECHO -e "\n#### SystemD Unit-Files (nur Services)" '`systemctl`:'
        $ECHO -e '```'
        $SYSTEMCTL list-unit-files --type=service --no-pager
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    fi
    if [[ -n $CHKCONFIG ]]
    then
        $ECHO -e "\n#### SystemV Init" '`chkconfig`:'
        $ECHO -e '```'
        $CHKCONFIG
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    fi
elif [[ $DISTRIBUTION == "debian" ]]
then
    if [[ -n $SYSTEMCTL ]]
    then
        $ECHO -e "\n#### SystemD Units (nur Services)" '`systemctl`:'
        $ECHO -e '```'
        $SYSTEMCTL list-units --type=service
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"

        $ECHO -e "\n#### SystemD Unit-Files (nur Services)" '`systemctl`:'
        $ECHO -e '```'
        $SYSTEMCTL list-unit-files --type=service
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    elif [[ -n $INITCTL ]]
    then
        $ECHO -e "\n#### Upstart" '`initctl`:'
        $ECHO -e '```'
        $INITCTL list
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    elif [[ -n $SERVICE ]]
    then
        $ECHO -e "\n#### SystemV Init" '`service`:'
        $ECHO -e '```'
        $SERVICE --status-all
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"

        $ECHO -e "\n#### SystemV rc-Files" '`service`:'
        $ECHO -e '```'
        $LS /etc/rc*.d/
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    else
        $ECHO -e "\n#### SystemV rc-Files" '`service`:'
        $ECHO -e '```'
        $LS /etc/rc*.d/
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"       
    fi
fi

###########################################
#
# HARDWARE und Partitionen
#
###########################################

$ECHO -e "\n## Hardware\n"

if [[ -n $LSHW ]]
then
    $ECHO -e "\n### Hardwareuebersicht" '`lshw -short`:'
    vmwarn
    $ECHO -e '```'
    $LSHW -short
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi 

if [[ -n $LSCPU ]]
then
    $ECHO -e "\n### CPU Info per" '`lscpu`:'
    vmwarn
    [[ $ISROOT == false ]] && $ECHO -e "(Ohne root-Rechte. Nur eingeschraenkte Funktionen.\n)"
    $ECHO -e '```'
    $LSCPU
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
else
    $ECHO -e "\n### CPU Info aus" '`/proc/cpuinfo`:'
    $ECHO -e '```'
    $CAT /proc/cpuinfo
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi 

if [[ -n $HWINFO ]]
then
    $ECHO -e "\n### Hardwareuebrsicht" '`hwinfo`:'
    vmwarn
    $ECHO -e '```'
    $HWINFO -short
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi 

if [[ -n $MOUNT ]]
then
    $ECHO -e "\n### Mountpoints" '`mount`:'
    $ECHO -e '```'
    $MOUNT | $COLUMN -t
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi

if [[ $ISROOT == true ]]
then
    if [[ -n $FDISK ]]
    then
        $ECHO -e "\n### Partitionen" '`fdisk -l`:'
        $ECHO -e '```'
        $FDISK -l
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    fi
fi

if [[ -n $LSBLK ]]
then
    $ECHO -e "\n### Block Devices" '`lsblk`:'
    $ECHO -e '```'
    $LSBLK
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi

if [[ -n $LSSCSI ]]
then
    $ECHO -e "\n### SCSI Devices" '`lsscsi`:'
    vmwarn
    $ECHO -e '```'
    $LSSCSI -L --size -v
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi 

if [[ -n $DF ]]
then
    $ECHO -e "\n### Speicherplatzverbrauch" '`dh -h`:'
    $ECHO -e '```'
    $DF -h
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi 

# LVM?
if [[ $ISROOT == true ]]
then
    # hoffentlich kompatibles grep
    if $GREP "/[[:space:]]" /etc/fstab | $GREP mapper >/dev/null 2>&1
    then
        $ECHO -e "\n### LVM"
        $ECHO -e "\n#### Physical Volumes" '`pvdisplay`:'
        $ECHO -e '```'
        $PVDISPLAY
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
        $ECHO -e "\n#### Volume Groups" '`vgdisplay`:'
        $ECHO -e '```'
        $VGDISPLAY
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
        $ECHO -e "\n#### Logical Volumes" '`lvdisplay`:'
        $ECHO -e '```'
        $LVDISPLAY
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    fi
fi   

if [[ $ISROOT == true ]]
then
    if [[ -n $DMIDECODE ]]
    then
        $ECHO -e "\n### Hardwareinfos per" '`dmidecode`:'
        vmwarn
        $ECHO -e '```'
        $DMIDECODE
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    fi
fi

if [[ -n $LSPCI ]]
then
    $ECHO -e "\n### PCI Devices" '`lspci`:'
    vmwarn
    $ECHO -e '```'
    $LSPCI
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi

if [[ -n $LSUSB ]]
then
    $ECHO -e "\n### USB Devices" '`lsusb`:'
    vmwarn
    $ECHO -e '```'
    $LSUSB
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi

if [[ -n $FREE ]]
then
    $ECHO -e "\n### RAM" '`free`:'
    $ECHO -e '```'
    $FREE
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
else
    $ECHO -e "\n### RAM Info aus" '`/proc/meminfo`:'
    $ECHO -e '```'
    $CAT /proc/meminfo
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi

###########################################
#
# Netzwerk
#
###########################################


$ECHO -e "\n## Netzwerk"

# IP und MAC-Adressem
if [[ -n $IP ]]
then
    $ECHO -e "\n### IP und MAC Adressen" '`ip a; ip l`:'
    $ECHO -e '```'
    $IP a
    $IP l
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"

    $ECHO -e "\n### Routen" '`ip r`:'
    $ECHO -e '```'
    $IP r
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
    
    $ECHO -e "\n### ARP Table" '`ip n`:'
    $ECHO -e '```'
    $IP n | $COLUMN -t
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
else
    ECHO -e "\n### IP und MAC Adressen" '`ifconfig -a`:'
    $ECHO -e '```'
    $IFCONFIG -a
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"

    $ECHO -e "\n### Routen" '`route`:'
    $ECHO -e '```'
    $ROUTE
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
    
    $ECHO -e "\n### ARP Table" '`arp -an`:'
    $ECHO -e '```'
    $ARP -an
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi

# Uebersicht aller Connections
if [[ -n $NMCLI ]]
then
    # nmcli haengt teils wenn Network Manager gar nicht laeuft (https://bugzilla.redhat.com/show_bug.cgi?id=1213327)
    if $PGREP "(NetworkManager|nm-applet)" >/dev/null 2>&1
    then
        $ECHO -e "\n### Connection Uebersicht" '`nmcli con show`:'
        $ECHO -e '```'
        $NMCLI c s
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    fi
fi

# resolv.conf auslesen
if [[ -e "/etc/resolv.conf" ]]
then
    $ECHO -e "\n### DNS Server aus" '`/etc/resolv.conf`:'
    $ECHO -e '```'
    $CAT /etc/resolv.conf
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi

# Aktuelle DNS Konfiguration aus nmcli
if [[ -n $NMCLI ]]
then
    # nmcli haengt teils wenn Network Manager gar nicht laeuft (https://bugzilla.redhat.com/show_bug.cgi?id=1213327)
    if $PGREP "(NetworkManager|nm-applet)" >/dev/null 2>&1
    then
        $ECHO -e "\n### [BETA] DNS Server per" '`nmcli con show <conn> `:'
        $ECHO -e '```'
        for CON in $($NMCLI c s --active | $GREP -iv name | $AWK '{print $1}'); do $ECHO ${CON}:; $NMCLI con s $CON | $GREP DNS; done
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    fi
fi

# ethtool fuer Interfaces aus /proc/net/dev die >0 Bytes in haben. Die ersten 2 Zeilen (Header) und lo werden uebergangen
if [[ -n $ETHTOOL ]]
then
    $ECHO -e "\n### Interfacesettings fuer aktive Interfaces" '`ethtool`:'
    vmwarn
    while read PROCNETDEVLINE
    do
        if [[ ( $($ECHO $PROCNETDEVLINE | $AWK '{print $2}') != 0 ) && ( $($ECHO $PROCNETDEVLINE | $AWK '{print $2}') != [a-zA-Z]+$ ) ]]
        then
            ACTIVEINTERFACE=$($ECHO $PROCNETDEVLINE | $CUT -d: -f1)
            $ECHO -e "\n####" '`'$ACTIVEINTERFACE'`'
            $ECHO -e '```'
            $ETHTOOL $ACTIVEINTERFACE
            $ECHO -e '```'
        fi
    done < <($TAIL -n +3 /proc/net/dev | $GREP -v -Ee "[[:space:]]lo:[[:space:]]")
fi

# Offene Sockets
if [[ $ISROOT == true ]]
then
    if [[ -n $LSOF ]]
    then
        $ECHO -e "\n### Offene TCP Sockets" '`lsof`:'
        $ECHO -e '```'
        $LSOF -iTCP | $GREP -i listen
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    fi
fi

# Versuch CDP Traffic mitzulesen fuer Infos an welchem Switch/Port und in welchem VLAN man ist.
# Bei vielen Interfaces besser auskommentieren wenn kein CDP aktiv oder Updates nur alle 60
# Sekunden kommen.
if [[ ( $ISROOT == true ) && ( -n $TCPDUMP ) && ( -n $TIMEOUT ) && ( $ISVM == false ) ]]
then
    # 2>&1 $ECHO -e "Versuche CDP Pakete zu finden. Kann per aktivem Interface bis zu 60 Sekunden dauern." 
    $ECHO -e "\n### CDP Nachrichten"
    while read PROCNETDEVLINE
    do
        if [[ ( $($ECHO $PROCNETDEVLINE | $AWK '{print $2}') != 0 ) && ( $($ECHO $PROCNETDEVLINE | $AWK '{print $2}') != [a-zA-Z]+$ ) ]]
        then
            ACTIVEINTERFACE=$($ECHO $PROCNETDEVLINE | $CUT -d: -f1)
            $ECHO -e "\n####" '`'$ACTIVEINTERFACE'`'
            $ECHO -e '```'
            $TIMEOUT 61 $TCPDUMP -nn -v -i $ACTIVEINTERFACE -c 1 -s 1500 'ether[20:2] == 0x2000'
            $ECHO -e '```'
        fi
    done < <($TAIL -n +4 /proc/net/dev | $GREP -v -Ee "[[:space:]]lo:[[:space:]]")
fi


###########################################
#
# Security
#
########################################### 

# SELinux
if [[ -n $GETENFORCE ]]
then
    $ECHO -e "\n### SELinux status via " '`getenforce`:'
    $ECHO -e '```'
    $GETENFORCE
    $ECHO -e '```'
fi

if [[ -n $SEMANAGE ]]
then
    $ECHO -e "\n### SELinux boolean Werte via " '`semanage`:'
    $ECHO -e '```'
    $ECHO -e "SELinux boolean                State  Default Description"
    $SEMANAGE boolean -l | $TAIL -n +2 | $SORT
    $ECHO -e '```'    
    $ECHO "[nach oben](#${HOSTNAMECLN})"
elif [[ -n $GETSEBOOL ]]
then
    $ECHO -e "\n### SELinux boolean Werte via " '`getsebool`:'
    $ECHO -e '```'
    $GETSEBOOL -a
    $ECHO -e '```'    
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi

if [[ ( -n $FIREWALLCMD ) && ( -n $SYSTEMCTL ) ]]
then
    $ECHO -e "\n### Firewall Status" '`systemctl`:'
    $ECHO -e '```'
    $SYSTEMCTL status firewalld.service
    $ECHO -e '```'

    if $FIREWALLCMD --state >/dev/null 2>&1
    then
        $ECHO -e "\n### Firewalld Default Zone" '`firewall-cmd`:'
        $ECHO -e '```'
        $FIREWALLCMD --get-default-zone
        $ECHO -e '```'

        $ECHO -e "\n### Firewalld alle Zonen" '`firewall-cmd`:'
        $ECHO -e '```'
        $FIREWALLCMD --get-zones
        $ECHO -e '```'

        $ECHO -e "\n### Firewalld aktive Zonen" '`firewall-cmd`:'
        $ECHO -e '```'
        $FIREWALLCMD --get-active-zones
        $ECHO -e '```'

        while read -r FWDALLZONES
        do
            $ECHO -e "\n#### Permanente Konfiguration pro Zone" '`'$FIREWALLCMD'`'
            for fwdzone in $FWDALLZONES
            do
                $ECHO -e "\n#### Zone:" '`'$fwdzone'`'
                $ECHO -e '```'
                $FIREWALLCMD --permanent --list-all --zone=$fwdzone
                $ECHO -e '```'
            done
        done < <($FIREWALLCMD --get-zones)
    fi
$ECHO "[nach oben](#${HOSTNAMECLN})"
fi

if [[ -n $IPTABLES ]]
then
        $ECHO -e "\n###" '`iptables`' "Regelwerk:"
        $ECHO -e '```'
        $IPTABLES -L
        $ECHO -e '```'

        $ECHO -e "\n###" '`iptables`' "Regelwerk als" '`iptables-save`:'
        $ECHO -e '```'
        $IPTABLES -S
        $ECHO -e '```'
fi    


###########################################
#
# Software
#
########################################### 

$ECHO -e "\n## Software"

if [[ $DISTRIBUTION == "rhel" ]]
then
    $ECHO -e "\n### Repositories" '`yum repolist`:'
    $ECHO -e '```'
    $YUM repolist
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
    $ECHO -e "\n### Installierte Pakete" '`yum list installed`:'
    $ECHO -e '```'
    $YUM list installed
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
elif [[ $DISTRIBUTION == "debian" ]]
then
    $ECHO -e "\n### Repositories" '`apt-cache policy`:'
    $ECHO -e '```'
    $APTCACHE policy
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
    $ECHO -e "\n### Installierte Pakete" '`dpkg -l`:'
    $ECHO -e '```'
    $DPKG -l | $GREP "^.i"
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi

if [[ -n $PS ]]
then
    $ECHO -e "\n### Laufende Prozesse" '`ps`:'
    $ECHO -e '```'
    $PS auxfw
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi

## Crontabs
#if [[ $ISROOT == true ]]
#then
#    if [[ -d "/var/spool/cron/crontabs" ]]
#    then
#        while IFS= read -r -d '' CRONFILE; do
#            $ECHO -e "\n### Crontab von $($BASENAME $CRONFILE)"
#            $ECHO -e '```'
#            $CAT $CRONFILE
#            # alternativ:
#            # $CRONTAB -l -u $($BASENAME $CRONFILE)
#            $ECHO -e '```'
#            $ECHO "[nach oben](#${HOSTNAMECLN})"
#        done < <(find /var/spool/cron/crontabs -maxdepth 1 -type f -print0)  
#    elif [[ -d "/var/spool/cron" ]]
#    then
#            while IFS= read -r -d '' CRONFILE; do
#            $ECHO -e "\n### Crontab von $($BASENAME $CRONFILE)"
#            $ECHO -e '```'
#            $CAT $CRONFILE
#            # alternativ:
#            # $CRONTAB -l -u $($BASENAME $CRONFILE)
#            $ECHO -e '```'
#            $ECHO "[nach oben](#${HOSTNAMECLN})"
#        done < <(find /var/spool/cron/crontabs -maxdepth 1 -type f -print0)  
#    fi
#else
#    $ECHO -e "\n### Crontab vom User " '`'$CURUSER'`:'
#    $ECHO -e '```'
#    $CRONTAB -l
#    $ECHO -e '```'
#    $ECHO "[nach oben](#${HOSTNAMECLN})"
#fi 


# Postfix?
if [[ -n $POSTFIX ]]
then
    if $POSTFIX status >/dev/null 2>&1
    then
        $ECHO -e "\n### Postfix"
        $ECHO -e "\n#### Status" '`postfix status`:'
        $ECHO -e '```'
        $SCRIPT -q -c "$POSTFIX status"      # postfix wirft nix auf STDOUT oder STDERR aus...
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
        $ECHO -e "\n#### Postfix !Default-Config" '`postconf -n`:'
        $ECHO -e '```'
        $POSTCONF -n
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
            if [[ -d /etc/postfix/ ]]
                then
                $ECHO -e "\n#### Postfix Directory" '`/etc/postfix`:'
                $ECHO -e '```'
                $LS -lah /etc/postfix
                $ECHO -e '```'
                $ECHO "[nach oben](#${HOSTNAMECLN})"
            fi
            if [[ -n MAILQ ]]
            then
                $ECHO -e "\n#### Aktuelle Mailqueue" '`mailq`:'
                $ECHO -e '```'
                $MAILQ
                $ECHO -e '```'
                $ECHO "[nach oben](#${HOSTNAMECLN})"
            fi
    fi 
fi

# BIND?
if [[ ( -n $NAMED ) && ( -n $RNDC ) ]]
then
    if $PGREP named >/dev/null 2>&1
    then
        $ECHO -e "\n### ISC BIND"
        $ECHO -e "\n#### Status" '`rndc status`:'
        $ECHO -e '```'
        $RNDC status
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    fi
fi

# Webserver?
httpdstatus() {
    if [[ -n $APACHECTL ]]
    then
        $ECHO -e "\n### Apache Webserver"
        $ECHO -e "\n#### Status" '`apachectl`:'
        $ECHO -e '```'
        $APACHECTL status
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    elif [[ -n $APACHE2CTL ]]
    then
        $ECHO -e "\n### Apache Webserver"
        $ECHO -e "\n#### Status" '`apache2ctl`:'
        $ECHO -e '```'
        $APACHE2CTL status
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    else
        $ECHO -e "\n### Webserver"
        $ECHO -e "Eine Art" '`httpd`' "laeuft aber es ist vermutlich kein Apache."
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    fi
}

if $PGREP httpd >/dev/null 2>&1
then
    httpdstatus
elif $PGREP apache >/dev/null 2>&1
then
    httpdstatus
fi

# Laeuft ein Hypervisor?

if [[ ( -n $XM ) && ( $ISROOT == true ) ]]
then
    $ECHO -e "\n### Xen/libvirt"
elif [[ ( -n $VIRSH ) && ( $ISROOT == true ) ]]
then
    $ECHO -e "\n### KVM/libvirt"
    $ECHO -e "\n#### Liste der VMs" '`virsh`:'
    $ECHO -e '```'
    $VIRSH list --all
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"

    $ECHO -e "\n#### Liste der virtuellen Netzwerke" '`virsh`:'
    $ECHO -e '```'
    $VIRSH net-list --all
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"


    $ECHO -e "\n#### Faehigkeiten des KVM Hosts" '`virsh`:'
    $ECHO -e '```'
    $VIRSH -c qemu:///system capabilities
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"

    $ECHO -e "\n#### Konfiguration der einzelnen VMs" '`virsh`:'
    for GUEST in $($VIRSH list --all | $GREP -vEe "(^-|Id|$^)" | $AWK '{print $2}')
    do
        $ECHO -e "\n#### Gast $GUEST:"
        $ECHO -e '```'
        $VIRSH dumpxml $GUEST
        $ECHO -e '```'
        $ECHO "[nach oben](#${HOSTNAMECLN})"
    done
elif [[ ( -n $DOCKER ) && ( $ISROOT == true ) ]]
then
    $ECHO -e "\n### Docker"
fi

# DRBD?

if [[ -n $DRBDOVERVIEW ]]
then
    $ECHO -e "\n### DRBD"
    $ECHO -e "\n#### Status:"
    $ECHO -e '```'
    $DRBDOVERVIEW
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"

    $ECHO -e "\n#### Status aus" '`proc`:'
    $ECHO -e '```'
    $CAT /proc/drbd
    $ECHO -e '```'
    $ECHO "[nach oben](#${HOSTNAMECLN})"
fi