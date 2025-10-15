# Google Cloud CLI aliases
# Based on https://cloud.google.com/sdk/docs/configurations
# Note: Avoided conflicts with common git aliases (gc, gca, gcl, gcs, gcu, gs, etc.)

# Configuration management
export alias gccfg = gcloud config configurations create
export alias gcact = gcloud config configurations activate
export alias gclist = gcloud config configurations list
export alias gcdel = gcloud config configurations delete
export alias gcset = gcloud config set
export alias gcunset = gcloud config unset
export alias gcconfig = gcloud config list
 
# Authentication
export alias gclogin = gcloud auth login
export alias gcauth = gcloud auth list
export alias gcapp = gcloud auth application-default login
 
# Project management
export alias gcproj = gcloud config set project
export alias gcget = gcloud config get-value project
 
# Compute Engine
export alias gcinst = gcloud compute instances list
export alias gccreate = gcloud compute instances create
export alias gcdelete = gcloud compute instances delete
export alias gcssh = gcloud compute ssh
export alias gck8sget = gcloud container clusters get-credentials
 
# Storage
export alias gcst = gcloud storage
export alias gcstls = gcloud storage ls
export alias gcstcp = gcloud storage cp
export alias gcstrm = gcloud storage rm
 
# General shortcuts
export alias gcloud = gcloud
export alias gcinfo = gcloud info
export alias gcver = gcloud version
