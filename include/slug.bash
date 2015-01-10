
slug-import() {
	declare desc="Import a gzipped slug tarball from URL or STDIN "
	declare url="$1"
	ensure-paths
	if [[ "$(ls -A $app_path)" ]]; then
		return 1
	elif [[ "$url" ]]; then
		curl -s --retry 2 "$url" | tar -xzC "$app_path"
	else
		cat | tar -xzC "$app_path"
	fi
}

slug-generate() {
	declare desc="Generate a gzipped slug tarball from the current app"
	ensure-paths
	local compress_option="-z"
	if which pigz > /dev/null; then
		compress_option="--use-compress-program=pigz"
	fi
	local slugignore_option
	if [[ -f "$app_path/.slugignore" ]]; then
		slugignore_option="-X $app_path/.slugignore"
	fi
	tar $compress_option $slugignore_option \
		--exclude='.git' \
		-C "$app_path" \
		-cf "$slug_path" \
    	.
	local slug_size="$(du -Sh $slug_path | cut -f1)"
	title "Compiled slug size is $slug_size"
}

slug-export() {
	declare desc="Export generated slug tarball to URL (PUT) or STDOUT"
	declare url="$1"
	ensure-paths
	if [[ ! -f "$slug_path" ]]; then
		return 1
	fi
	if [[ "$url" ]]; then
		curl -0 -s -o /dev/null --retry 2 -X PUT -T "$slug_path" "$url"
	else
		cat "$slug_path"
	fi
}