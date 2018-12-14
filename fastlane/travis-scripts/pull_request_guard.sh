is_master_build() {
	if [[ "${TRAVIS_PULL_REQUEST}" = "false" && "${TRAVIS_BRANCH}" = "master" ]]
		then
		echo "This is master build!"
		return 0
	else 
		echo "This is pull request or something else!"
		return 1
	fi
}