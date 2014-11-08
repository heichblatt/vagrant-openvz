# Vagrant-defined OpenVZ Host

The OpenVZ host will download some templates and put all its containers into `192.168.134.0/24`.

    vagrant up
    vagrant ssh
    sudo -i
    vzctl create 101 --ostemplate centos-7-x86_64
    vzctl set 101 --ipadd 172.16.0.1 --save
    vzctl set 101 --nameserver inherit --save
    vzctl set 101 --onboot no --save
    vzctl start 101
    vzctl enter 101
    uname -a
    vzctl stop 101
    vzctl destroy 101
