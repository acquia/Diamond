class acquia_base::docker::docker_storage_setup {
  # Workaround for https://github.com/projectatomic/docker-storage-setup/pull/102
  file { '/etc/systemd/system/docker-storage-setup.service':
    content => template('acquia_base/docker/docker-storage-setup.service.erb'),
  }
}
