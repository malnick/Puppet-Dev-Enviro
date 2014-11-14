# MTLB Node
#node 'master.dev' {
#	class { 'r10k':
 # 		remote => 'git@github.com:connectsolutions/control.git',
#	}
#}

# Trash-it Server
node 'do.dev.here' { 
  include ::role::mtlb
}






