set -e

GIT_TAG=`git tag --points-at HEAD`

echo ">> Branch: $TRAVIS_BRANCH, Pull Request: $TRAVIS_PULL_REQUEST, Tag: $TRAVIS_TAG ($GIT_TAG)"

if [ "$TRAVIS_PULL_REQUEST" = "false" ] && [ "$TRAVIS_BRANCH" = "master" ]
then
	npm uninstall snockets
	npm install snockets

	cake build:dist

	mv build/dist batman.js
	tar cvzf batman-master.tar.gz batman.js
	travis-artifacts upload --path batman-master.tar.gz --target-path '' --cache-control no-cache

	if [[ -n "$GIT_TAG" ]]; then
		NAME_WITH_TAG="batman-${GIT_TAG}.tar.gz"
		mv batman-master.tar.gz "$NAME_WITH_TAG"
		travis-artifacts upload --path "$NAME_WITH_TAG" --target-path ''
	fi
else
	echo ">> Not pushing artifacts to S3"
fi
