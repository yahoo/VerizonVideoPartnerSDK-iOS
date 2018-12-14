if [[ $TRAVIS_PULL_REQUEST != false ]] || [[ $TRAVIS_BRANCH != "master" ]]; then echo "Denied! It is not a master branch."; exit 0; fi


body='{
"request": {
"message": "Travis CI Message - Triggered after new changes in SDK",
"branch": "master"
}}'

curl -s -X POST \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-H "Travis-API-Version: 3" \
-H "Authorization: token $TRAVIS_API_TOKEN" \
-d "$body" \
https://api.travis-ci.com/repo/$TESTAPP_REPO/requests

