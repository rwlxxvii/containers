include install_aide

class install_aide {
  package { 'aide':
    ensure => 'installed',
  }
}
include install_rng-tools

class install_rng-tools {
  package { 'rng-tools':
    ensure => 'installed',
  }
}
include remove_abrt-libs

class remove_abrt-libs {
  package { 'abrt-libs':
    ensure => 'purged',
  }
}
include remove_abrt-server-info-page

class remove_abrt-server-info-page {
  package { 'abrt-server-info-page':
    ensure => 'purged',
  }
}
include remove_gssproxy

class remove_gssproxy {
  package { 'gssproxy':
    ensure => 'purged',
  }
}
include remove_iprutils

class remove_iprutils {
  package { 'iprutils':
    ensure => 'purged',
  }
}
include remove_krb5-workstation

class remove_krb5-workstation {
  package { 'krb5-workstation':
    ensure => 'purged',
  }
}
include remove_tuned

class remove_tuned {
  package { 'tuned':
    ensure => 'purged',
  }
}
include disable_debug-shell

class disable_debug-shell {
  service {'debug-shell':
    enable => false,
    ensure => 'stopped',
  }
}
include install_tmux

class install_tmux {
  package { 'tmux':
    ensure => 'installed',
  }
}
include install_kbd

class install_kbd {
  package { 'kbd':
    ensure => 'installed',
  }
}
include install_opensc

class install_opensc {
  package { 'opensc':
    ensure => 'installed',
  }
}
include install_openssl-pkcs11

class install_openssl-pkcs11 {
  package { 'openssl-pkcs11':
    ensure => 'installed',
  }
}
include install_audit

class install_audit {
  package { 'audit':
    ensure => 'installed',
  }
}
include enable_auditd

class enable_auditd {
  service {'auditd':
    enable => true,
    ensure => 'running',
  }
}
include install_rsyslog-gnutls

class install_rsyslog-gnutls {
  package { 'rsyslog-gnutls':
    ensure => 'installed',
  }
}
include install_rsyslog

class install_rsyslog {
  package { 'rsyslog':
    ensure => 'installed',
  }
}
include enable_rsyslog

class enable_rsyslog {
  service {'rsyslog':
    enable => true,
    ensure => 'running',
  }
}
include install_firewalld

class install_firewalld {
  package { 'firewalld':
    ensure => 'installed',
  }
}
include enable_firewalld

class enable_firewalld {
  service {'firewalld':
    enable => true,
    ensure => 'running',
  }
}
include disable_autofs

class disable_autofs {
  service {'autofs':
    enable => false,
    ensure => 'stopped',
  }
}
include disable_systemd-coredump

class disable_systemd-coredump {
  service {'systemd-coredump':
    enable => false,
    ensure => 'stopped',
  }
}
include install_policycoreutils

class install_policycoreutils {
  package { 'policycoreutils':
    ensure => 'installed',
  }
}
include remove_abrt

class remove_abrt {
  package { 'abrt':
    ensure => 'purged',
  }
}
include disable_kdump

class disable_kdump {
  service {'kdump':
    enable => false,
    ensure => 'stopped',
  }
}
include install_fapolicyd

class install_fapolicyd {
  package { 'fapolicyd':
    ensure => 'installed',
  }
}
include enable_fapolicyd

class enable_fapolicyd {
  service {'fapolicyd':
    enable => true,
    ensure => 'running',
  }
}
include remove_vsftpd

class remove_vsftpd {
  package { 'vsftpd':
    ensure => 'purged',
  }
}
include remove_krb5-server

class remove_krb5-server {
  package { 'krb5-server':
    ensure => 'purged',
  }
}
include remove_sendmail

class remove_sendmail {
  package { 'sendmail':
    ensure => 'purged',
  }
}
include remove_rsh-server

class remove_rsh-server {
  package { 'rsh-server':
    ensure => 'purged',
  }
}
include remove_telnet-server

class remove_telnet-server {
  package { 'telnet-server':
    ensure => 'purged',
  }
}
include remove_tftp-server

class remove_tftp-server {
  package { 'tftp-server':
    ensure => 'purged',
  }
}
include enable_rngd

class enable_rngd {
  service {'rngd':
    enable => true,
    ensure => 'running',
  }
}
include install_openssh-server

class install_openssh-server {
  package { 'openssh-server':
    ensure => 'installed',
  }
}
include enable_sshd

class enable_sshd {
  service {'sshd':
    enable => true,
    ensure => 'running',
  }
}
include ssh_private_key_perms

class ssh_private_key_perms {
  exec { 'sshd_priv_key':
    command => "chmod 0640 /etc/ssh/*_key",
    path    => '/bin:/usr/bin'
  }
}
include ssh_public_key_perms

class ssh_public_key_perms {
  exec { 'sshd_pub_key':
    command => "chmod 0644 /etc/ssh/*.pub",
    path    => '/bin:/usr/bin'
  }
}
include install_usbguard

class install_usbguard {
  package { 'usbguard':
    ensure => 'installed',
  }
}
include enable_usbguard

class enable_usbguard {
  service {'usbguard':
    enable => true,
    ensure => 'running',
  }
}
