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
  package {"unicorn":
    provider  => "gem",
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
    content => template("unicorn/unicorn.init-d.erb")
  }

  service { "unicorn":
    require => [File["Setting unicorn service"], File["Setting unicorn config"], package["unicorn"]],
    ensure => "running",
    enable => true
  }

}