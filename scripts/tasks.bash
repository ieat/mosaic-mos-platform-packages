#!/dev/null

if ! test "${#}" -eq 0 ; then
	echo "[ee] invalid arguments; aborting!" >&2
	exit 1
fi

while read _package_name ; do
	
	if test -e "${_packages}/${_package_name}/sources/.disabled" ; then
		continue
	fi
	
	cat <<EOS

${_package_name}-rpm@requisites : pallur-packages@python2 pallur-packages@rpm pallur-bootstrap

${_package_name}-rpm@prepare : ${_package_name}-rpm@requisites ${_package_name}@package
	${_scripts}/prepare ${_package_name}

${_package_name}-rpm@package : ${_package_name}-rpm@prepare
	${_scripts}/package ${_package_name}

${_package_name}-rpm@deploy : ${_package_name}-rpm@package
	${_scripts}/deploy ${_package_name}

pallur-distribution@requisites : ${_package_name}-rpm@requisites
pallur-distribution@prepare : ${_package_name}-rpm@prepare
pallur-distribution@package : ${_package_name}-rpm@package
pallur-distribution@deploy : ${_package_name}-rpm@deploy

EOS
	
done < <(
	find "${_packages}" -xdev -mindepth 1 -maxdepth 1 -type d -printf '%f\n' \
	| sort
)

cat <<EOS

mosaic-platform-controller@package : mosaic-node@package mosaic-node-wui@package mosaic-node-boot@package

EOS

exit 0