# MTLB Node
node 'master.dev' {
	class { 'r10k':
  		remote => 'git@github.com:connectsolutions/control.git',
	}
}

node 'mtlb.dev' {
  include ::role::mtlb

}

# Trash-it Server
node 'dev1.dev' {
  notice("Hello world")
}






