git_config() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}


upload_tar() {
  if [ -z "$GITHUB_PAT" ]; then
    echo "Error: variable GITHUB_PAT not found."
    exit 1
  fi

  pushd $HOME/R/Library

  tar -cvzf - * | split -b 20M - "cache.tar.gz.part-"

  if [ -d ".git" ]; then
    rm -rf .git
  fi

  git init
  git checkout --orphan cache-$DYNVERSE_BRANCH

  git add cache.tar.gz*
  git commit --allow-empty -m "Travis build: $TRAVIS_BUILD_NUMBER [ci skip]"

  git remote add origin https://${GITHUB_PAT}@github.com/dynverse/travis_package_cacher.git
  git push --force origin cache-$DYNVERSE_BRANCH

  rm cache.tar.gz*

  popd
}
