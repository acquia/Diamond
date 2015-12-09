class acquia_base::admin_users(
  $accounts = {}
){

  create_resources(acquia_base::admin_users::create, $accounts)
}
