# etcd-backupper

Docker image : `jclab/etcd-backupper:release-0.0.1`

# Example

Kubernetes

Secret:

```yaml
kind: Secret
apiVersion: v1
metadata:
  name: k8s-backup-etcd-ssh
  namespace: kube-system
type: Opaque
data:
  privkey.pem: 'BASE64 ENCODED PRIVATE KEY'
  known_hosts: 'BASE64 ENCODED KNOWN HOSTS'
```

Cron Job
```yaml
kind: CronJob
apiVersion: batch/v1beta1
metadata:
  name: k8s-cluster-etcd-backup-cronjob
  namespace: kube-system
spec:
  schedule: 0 0 * * *
  concurrencyPolicy: Allow
  suspend: false
  jobTemplate:
    metadata:
      creationTimestamp: null
      labels:
        job: k8s-cluster-etcd-backup-cronjob
    spec:
      template:
        metadata:
          creationTimestamp: null
          labels:
            job: k8s-cluster-etcd-backup-cronjob
        spec:
          volumes:
            - name: etcd-certs
              hostPath:
                path: /etc/kubernetes/pki/etcd
                type: DirectoryOrCreate
            - name: ssh-secret
              secret:
                secretName: k8s-backup-etcd-ssh
                defaultMode: 400
          containers:
            - name: main
              image: 'jclab/etcd-backupper:release-0.0.1'
              command:
                - /bin/bash
                - '-c'
                - >-
                  set -e;
                  BACKUP_FILE_NAME=etcd-`date "+%Y-%m-%d_%H-%M-%S"`-snapshot.bin;
                  export BACKUP_FILE=/tmp/${BACKUP_FILE_NAME};
                  export REMOTE_PATH=/backup/zeron-k8s-etcd/${BACKUP_FILE_NAME};
                  ETCDCTL_API=3 etcdctl --endpoints
                  https://${K8S_NODE_HOST_IP}:2379
                  --cacert=/etc/kubernetes/pki/etcd/ca.crt
                  --cert=/etc/kubernetes/pki/etcd/server.crt
                  --key=/etc/kubernetes/pki/etcd/server.key snapshot save
                  ${BACKUP_FILE};
                  /opt/scp_backup.sh
              env:
                - name: ETCDCTL_API
                  value: '3'
                - name: K8S_NODE_NAME
                  valueFrom:
                    fieldRef:
                      apiVersion: v1
                      fieldPath: spec.nodeName
                - name: K8S_NODE_HOST_IP
                  valueFrom:
                    fieldRef:
                      apiVersion: v1
                      fieldPath: status.hostIP
                - name: SSH_KEY_FILE
                  value: /root/ssh-secret/privkey.pem
                - name: SSH_KNOWN_HOSTS_FILE
                  value: /root/ssh-secret/known_hosts
                - name: REMOTE_HOST
                  value: 'BACKUP_REMOTE_SERVER'
                - name: REMOTE_USER
                  value: 'BACKUP_REMOTE_USER'
              resources: {}
              volumeMounts:
                - name: etcd-certs
                  mountPath: /etc/kubernetes/pki/etcd
                - name: ssh-secret
                  mountPath: /root/ssh-secret
              terminationMessagePath: /dev/termination-log
              terminationMessagePolicy: File
              imagePullPolicy: IfNotPresent
          tolerations:
            # this toleration is to have the daemonset runnable on master nodes
            # remove it if your masters can't run pods
            - key: node-role.kubernetes.io/master
              effect: NoSchedule
          affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                  - matchExpressions:
                      - key: node-role.kubernetes.io/master
                        operator: Exists
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
```
