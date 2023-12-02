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
include disable_autofs

class disable_autofs {
  service {'autofs':
    enable => false,
    ensure => 'stopped',
  }
}
include disable_abrtd

class disable_abrtd {
  service {'abrtd':
    enable => false,
    ensure => 'stopped',
  }
}
include disable_ntpdate

class disable_ntpdate {
  service {'ntpdate':
    enable => false,
    ensure => 'stopped',
  }
}
include disable_oddjobd

class disable_oddjobd {
  service {'oddjobd':
    enable => false,
    ensure => 'stopped',
  }
}
include disable_qpidd

class disable_qpidd {
  service {'qpidd':
    enable => false,
    ensure => 'stopped',
  }
}
include disable_rdisc

class disable_rdisc {
  service {'rdisc':
    enable => false,
    ensure => 'stopped',
  }
}
include disable_atd

class disable_atd {
  service {'atd':
    enable => false,
    ensure => 'stopped',
  }
}
