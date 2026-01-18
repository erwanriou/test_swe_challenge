# VARIABLES
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[1;36m'
NC='\033[0m' # No Color

# HELPERS FUNCTION
function remove() {
  # PARAMS
  HOSTNAME=$1
  # INTERNAL HELPERS
  function yell() { printf "$0: $*" >&2; }
  function try() { "$@" || die "cannot $*"; }
  function die() {
    yell "$*"
    exit 111
  }
  # LOGIC
  if
    [ -n "$(grep $HOSTNAME /etc/hosts)" ]
  then
    printf "$HOSTNAME found in /etc/hosts. Removing now...\n"
    try sudo sed -ie "/[[:space:]]$HOSTNAME/d" "/etc/hosts"
  else
    yell "$HOSTNAME was not found in /etc/hosts"
  fi
}


# CHECK INSTALATIONS
function check_install() {
  # DEFINE VARIABLES CONDITIONS
  DOCKER_INSTALLED=$(docker -v | grep "Docker version" | awk '{ print $2 }')
  SKAFFOLD_INSTALLED=$(skaffold options | grep "The" | awk '{ print $2 }')
  MINIKUBE_INSTALLED=$(minikube version | grep version | awk '{ print $1 }')
  MINIKUBE_RUNNING=$(minikube status | grep host | awk '{ print $2 }')

  if [ ! "$DOCKER_INSTALLED" = "version" ]; then
    printf "\n${RED}DOCKER INSTALLATION REQUIRED ${NC}"
    printf "\n${RED}CHECK https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository ${NC}"
    exit
  fi

  # CHECK SKAFFOLD IS INSTALLED
  if [ ! "$SKAFFOLD_INSTALLED" = "following" ]; then
    printf "\n${RED}SKAFFOLD INSTALLATION REQUIRED ${NC}"
    printf "\n${RED}RUN curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && sudo install skaffold /usr/local/bin/ ${NC}"
    exit
  fi

  # CHECK MINKUBE IS INSTALLED
  if [ ! "$MINIKUBE_INSTALLED" = "minikube" ]; then
    printf "\n${RED}MINIKUBE INSTALLATION REQUIRED ${NC}"
    printf "\n${RED}CHECK https://minikube.sigs.k8s.io/docs/start/ ${NC}"
    exit
  fi

  # CHECK MINKUBE IS ILAUNCHED
  if [ ! "$MINIKUBE_RUNNING" = "Running" ]; then
    minikube start --kubernetes-version=v1.27.3 --memory 8192 --cpus 4
    sleep 10s
    printf "\n${RED}MINIKUBE NOW RUNNING ${NC}"
  else
    printf "\n${GREEN}MINIKUBE ALREADY RUNNING ${NC}"
  fi
}

function check_nginx() {
  # VARIABLES
  NGINX=$(kubectl get pods -n ingress-nginx | grep ingress-nginx-controller | awk '{ print $3 }')

  # LOGIC
  printf "\n${GREEN}CHECK IF INGRESS NGINX IS INSTALLED ${NC}"
  if [ ! "$NGINX" = "Running" ]; then
    printf "\n${GREEN}INSTALLING INGRESS NGINX ${NC}"
    minikube addons enable ingress
  else
    printf "\n${GREEN}INGRESS NGINX ALREADY INSTALLED AND RUNNING ${NC}"
  fi
}

function check_ip() {
  printf "\n${GREEN}ADD MINIKUBE IP TO ECT/HOST${NC}\n"
  MINIKUBE_IP=$(minikube ip)
  # REMOVE OLD ECTHOST VALUES
  remove "www.swe-challenge.dev"

  # ADDING CORRECT ONES
  echo "${MINIKUBE_IP}  www.swe-challenge.dev" | sudo tee -a /etc/hosts

  # ADD CORRECT MEMORY ATTRIBUTION
  sudo sysctl -w fs.inotify.max_user_watches=10485760
  sudo sysctl -w fs.inotify.max_user_instances=100000
}


# 1 - NOTE CHECK INSTALLATIONS
check_install

# 2 - NOTE CHANGE CONTEXT
kubectl config use-context minikube

# 3 - NOTE CHECK IF NGINX IS RUNNING
check_nginx

# 4 - NOTE ADD MINIKUBE IP TO ECT/HOST
check_ip

# 5 - NOTE LAUNCH SKAFFOLD
INGRESS_NAMESPACE_ENV=$(kubectl get deployments --all-namespaces | grep ingress-nginx-controller | awk '{ print $1 }')
printf "\n${GREEN}LAUNCHING SKAFFOLD ${NC}"
printf "\n${GREEN}INGRESS NGINX VARIABLE SETUP AS ${INGRESS_NAMESPACE_ENV} ${NC}"
skaffold dev --filename='infra/skaffold/all.yml'

# 6 - NOTE FALLBACK
kubectl config use-context minikube
kubectl -n default delete deployment,pod,services --all
