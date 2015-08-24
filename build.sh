#!/bin/bash

# only proceed script when started not by pull request (PR)
if [ $TRAVIS_PULL_REQUEST == "true" ]; then
  echo "this is PR, exiting"
  exit 0
fi

# enable error reporting to the console
set -e

# build site with jekyll, by default to `_site' folder
jekyll build

# cleanup
rm -rf ../${GH_ORG}.github.io.master

#clone `master' branch of the repository using encrypted GH_TOKEN for authentification
git clone https://${GH_TOKEN}@github.com/${GH_ORG}/${GH_ORG}.github.io.git ../riodelamiel.github.io.master

# copy generated HTML site to `master' branch
cd _site
rsync -v -r --delete --exclude=build.sh * ../${GH_ORG}.github.io.master

cd ../${GH_ORG}.github.io.master

# commit and push generated content to `master' branch
# since repository was cloned in write mode with token auth - we can push there
git config user.email "${GH_MAIL}"
git config user.name "${GH_USER}"
git add -A .
git status
git commit -a -m "Travis page build #${TRAVIS_BUILD_NUMBER}"
git push --quiet origin master > /dev/null 2>&1 

