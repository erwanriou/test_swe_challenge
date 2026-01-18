# VARIABLES
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# UPDATE ALL DATA FROM REPOSTORIES
printf "\n${GREEN}UPDATE MAIN INFRA REPOSITORY ${NC}"
git fetch
git pull --ff-only

printf "\n${GREEN}UPDATE ALL SUBMODULES ${NC}"
git submodule update --init --recursive -j 8
git submodule foreach 'git checkout develop'
git submodule foreach 'git fetch'
git submodule foreach 'git pull --ff-only'
