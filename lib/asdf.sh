run_command() {
  local callback_args="${@:2}"
  run_callback_if_command "--version" $1 asdf_version       $callback_args
  run_callback_if_command "install"   $1 install_command    $callback_args
  run_callback_if_command "uninstall" $1 uninstall_command  $callback_args
  run_callback_if_command "list"      $1 list_command       $callback_args
  run_callback_if_command "list-all"  $1 list_all_command   $callback_args
  run_callback_if_command "help"      $1 help_command       $callback_args


  help_command
  exit 1
}


install_command() {
  local package=$1
  local full_version=$2
  local source_path=$(get_source_path $package)

  check_if_source_exists $source_path

  IFS=':' read -a version_info <<< "$full_version"
  if [ "${version_info[0]}" = "tag" ] || [ "${version_info[0]}" = "commit" ]
  then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi

  local install_path=$(get_install_path $package $full_version)
  ${source_path}/bin/install $install_type $version $install_path "${@:3}"
}


uninstall_command() {
  local package=$1
  local full_version=$2
  local source_path=$(get_source_path $package)

  check_if_source_exists $source_path
  if [ ! -d "$source_path/$full_version" ]
  then
    display_error "No such version"
    exit 1
  fi

  IFS=':' read -a version_info <<< "$full_version"
  if [ "${version_info[0]}" = "tag" ] || [ "${version_info[0]}" = "commit" ]
    then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi

  local install_path=$(get_install_path $package $full_version)
  ${source_path}/bin/uninstall $install_type $version $install_path "${@:3}"
}


get_install_path() {
  local package=$1
  local version=$2
  mkdir -p $(asdf_dir)/installs/${package}

  echo $(asdf_dir)/installs/${package}/${version}
}


list_all_command() {
  local source_path=$(get_source_path $1)
  check_if_source_exists $source_path
  ${source_path}/bin/list-all
}


list_command() {
  local source_path=$(get_source_path $1)
  check_if_source_exists $source_path
  echo "TODO"
  # echo ./$(asdf_dir)/sources/$1/list
  #TODO list versions installed with the installs/erlang/.installs file
  # the .installs file will have lines of the format "version hash"
}


help_command() {
  echo "display help message"
}