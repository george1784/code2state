#!/bin/bash


kubectl get psp | grep my-release | awk 'BEGIN { FS = " " } { print $1 }' | ( while read line
  do
    kubectl delete psp ${line}
  done
  )
  
 kubectl get clusterroles | grep my-release | awk 'BEGIN { FS = " " } { print $1 }' | ( while read line
  do
    kubectl delete clusterroles ${line}
  done
  )
  
 kubectl get clusterrolebinding | grep my-release | awk 'BEGIN { FS = " " } { print $1 }' | ( while read line
  do
    kubectl delete clusterrolebinding ${line}
  done
  )
  
 kubectl get MutatingWebhookConfiguration | grep my-release | awk 'BEGIN { FS = " " } { print $1 }' | ( while read line
  do
    kubectl delete MutatingWebhookConfiguration ${line}
  done
  )

 kubectl get ValidatingWebhookConfiguration | grep my-release | awk 'BEGIN { FS = " " } { print $1 }' | ( while read line
  do
    kubectl delete ValidatingWebhookConfiguration ${line}
  done
  )
  
  
  kubectl get svc -nkube-system | grep my-release | awk 'BEGIN { FS = " " } { print $1 }' | ( while read line
  do
    kubectl delete svc ${line} -nkube-system
  done
  )
