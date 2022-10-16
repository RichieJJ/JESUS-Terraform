cat << EOF >> ~/.ssh/config

HOST $(hostname)
  HostName $(hostname)
  User $(user)
  IdentityFile $(IdentityFile)


  EOF
  
