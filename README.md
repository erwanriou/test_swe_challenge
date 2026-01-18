# TEST SWE CHALLENGE Infra Repository

## Table of Contents

- [Required](#Required)
- [Pre-installation](#Pre-installation)
- [Installation](#installation)
- [Architecture](#architecture)

## Required

- nvm with node 20.9.0. https://github.com/nvm-sh/nvm
  ```sh
  nvm install 20.9.0
  nvm alias default 20.9.0
  ```
- For git if first time use the following script below just before clone the repository.
  ```sh
  git config --global user.email ***@***.com
  git config --global user.name ***some_name
  git config --global credential.helper store
  git config --global core.ignorecase false
  ```
- Linux or Mac (with minikube only)
- Zed installed `curl -f https://zed.dev/install.sh | sh`
- Last Chrome/Firefox Version

## Pre-installation

Linux/Ubuntu:

- Install Docker Engine using the repo: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
- Install kubectl:
```sh
curl -LO https://dl.k8s.io/release/v1.27.3/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```
- Install minikube:
```sh
curl -LO https://storage.googleapis.com/minikube/releases/v1.31.2/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```
- Install skaffold (used for dev environment): https://skaffold.dev/docs/install/


## Installation

- Launch minikube a first time (RECOMMANDED STEP)
  ```sh
  # launch minikube
  minikube start --kubernetes-version=v1.27.3 --memory 8192 --cpus 4
  ```
- Make sure to upload **⚠️ ALL THE SECRETS ⚠️** needed and apply them to your kubernetes cluster (Sent by email together)
- Start the project with:
  ```sh
  cd ~/Documents
  git clone https://github.com/erwanriou/test_swe_challenge.git
  cd test_swe_challenge
  zed . # or whatever IDE you are using
  npm run update
  npm run dev
  ```
- You can check the installation with `kubectl get pods`.
- Front will not have certificate, you can bypass chrome security with `thisisunsafe`: https://miguelpiedrafita.com/chrome-thisisunsafe or with Firefox: https://timleland.com/firefox-allow-self-signed-certificate/

## Architecture

TODO WORK IN PROGRESS
