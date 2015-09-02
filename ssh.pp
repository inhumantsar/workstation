class { 'ssh':
  storeconfigs_enabled => false,
  server_options => {
    'PasswordAuthentication' => 'yes',
    'PermitRootLogin'        => 'no',
    'Port'                   => '22',
  },
}
