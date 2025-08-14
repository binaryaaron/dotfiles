

_add_to_path() {
    new_path=${1%/}
    if [ -d "$1" ] && ! echo "$PATH" | grep -E -q "(^|:)$new_path($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH="${PATH:+${PATH}:}$new_path"
        else
            PATH="$new_path:${PATH:+${PATH}:}"
        fi
    fi
}
