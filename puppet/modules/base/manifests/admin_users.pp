class base::admin_users(
  $accounts = {}
){

  create_resources(base::admin_users::create, $accounts)
}
