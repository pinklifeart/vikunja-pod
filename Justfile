#!/usr/bin/env just --justfile

password_dict:="0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#%^*"
installation_path:="/opt/vikunja"
podman_service_files_path:=join(config_directory(), 'containers','systemd')
db_pass:= choose('32', password_dict)
jwt_secret:= choose('64', password_dict)

default:
  just --list

# Installs necessary configuration files without starting the pod
install:
  just generate_env_files
  just copy_service_files

# Installs configuration files and starts the pod
install_and_run:
  just install
  just start_services

# Generates .env.server and .env.db into selected installation directory with environment variables for the containers
generate_env_files: check_installation_path
  just generate_db_env generate_server_env

# Copies service files to $HOME/.config/containers/systemd
copy_service_files: setup_service_files_path
  cp ./vikunja* {{podman_service_files_path}}

# Reloads systemd user daemon and starts the pod
start_services: 
  systemctl --user daemon-reload
  systemctl --user start vikunja-pod

[private]
@check_deps:
  echo "Checking for podman and systemctl..."
  type -p podman || ( echo "podman executable not found in $PATH" && exit 1 )
  type -p systemctl || ( echo "systemctl executable not found in $PATH" && exit 1 )
  
[private]
generate_db_env:
  #!/usr/bin/env sh
  cat << EOF > {{join(installation_path,'.env.db')}}
  POSTGRES_PASSWORD={{db_pass}}
  POSTGRES_USER=vikunja
  EOF

[private]
generate_server_env:
  #!/usr/bin/env sh
  cat << EOF > {{join(installation_path,'.env.server')}}
  VIKUNJA_DATABASE_HOST=vikunja-psql
  VIKUNJA_DATABASE_PASSWORD={{db_pass}}
  VIKUNJA_DATABASE_TYPE=postgres
  VIKUNJA_DATABASE_USER=vikunja
  VIKUNJA_DATABASE_DATABASE=vikunja
  VIKUNJA_SERVICE_JWTSECRET={{jwt_secret}}
  EOF

# TODO: Add a check for postgresql and files directorires in /opt/vikunja
[private]
check_installation_path:
  #!/usr/bin/env sh
  echo "Checking installation path..."
  if test -w {{installation_path}}
  then
    echo "Ok: {{installation_path}}"
  elif test -e {{installation_path}}
  then
    echo "{{installation_path}} exists, but cannot be written to. Please fix directory permissions before proceeding."
    exit 1
  else
    echo "Directory {{installation_path}} doesn't exist. Create the directory or specify a different path."
    exit 1
  fi

[private]
setup_service_files_path:
  #!/usr/bin/env sh
  echo "Checking service file directory..."
  if test -w {{podman_service_files_path}}
  then
    echo "Container unit dir is writeable."
    exit 0
  elif test -e {{podman_service_files_path}}
  then
    echo "{{podman_service_files_path}} exists, but cannot be written to. Please fix directory permissions before proceeding."
    exit 1
  else 
    echo "{{podman_service_files_path}} doesn't exist, attempting to create."
    mkdir -pv {{podman_service_files_path}}
  fi
