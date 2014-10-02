# Frontend Server
node "u-du-csxstgnode.fed.cs.int" {
  include ::role::csx_frontend
}

# Trash-it Server
node 'dev1.dev' {
  notice("Hello world")
}

# MySQL Server
node 'u-du-csxstgsql.fed.cs.int' {
  include ::role::csx_mysql
}

# Backend Server
node "u-du-csxstgnode.fed.cs.int" {
  include ::role::csx_backend
}
