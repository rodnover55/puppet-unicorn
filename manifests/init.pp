class unicorn (
  $config,
  $working_directory,
  $socket,
  $pid,
  $owner = 'www-data',
  $groupt = 'www-data',
  $stderr_path = "/var/log/unicorn.stderr.log",
  $stdout_path = "/var/log/unicorn.stdout.log",
  $worker_processes = 2,
  $preload_app = true,
  $timeout = 30
) {
  file { $stderr_path:
    owner => $owner,
    group => $groupt,
    mode  => 644,
    ensure => "present"
  }

  file { $stdout_path:
    owner => $owner,
    group => $groupt,
    mode  => 644,
    ensure => "present"
  }

  exec { "rvm gemset create unicorn":
    unless => "rvm gemset list | grep -c 'unicorn'"
  }

  rvm_gem { ["@unicorn/unicorn", "@unicorn/bundler", "@unicorn/rake"]:
    ensure => "present"
  }

  exec { "rvm wrapper @unicorn unicorn_rails bundler rake":
    require => Exec["rvm gemset create unicorn"]
  }

  file {"Setting unicorn config":
    ensure  => present,
    owner   => $owner,
    group   => $group,
    path    => $config,
    content => template("unicorn/unicorn.rb.erb")
  }

  file { "Setting unicorn service":
    ensure  => present,
    path    => "/etc/init.d/unicorn",
    mode    => 0755,
    content => template("unicorn/unicorn.init-d.erb")
  }

  service { "unicorn":
    require => [File["Setting unicorn service"], File["Setting unicorn config"], File[$stderr_path], File[$stdout_path]],
    ensure => "running",
    enable => true
  }

}