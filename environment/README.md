For remote server automation and command execution Fabric and Capistrano scripts are used. 

When using Fabric and Capistrano on a large number of servers, execution can be in parallel or sequentially. 

It is possible to perform the remote execution using the Puppet/Chef but their approach is mostly pull based (nodes pulling configuration from master) and Fabric/Capistrano execution model is push based. 

Both Fabric and Capistrano execute predefined tasks. Tasks are nothing but Python/Ruby functions with the wrapper around the Bash/Powershell commands.