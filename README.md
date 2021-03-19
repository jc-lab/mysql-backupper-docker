# mysql-backupper

Docker image : `jclab/mysql-backupper:release-0.0.1`

# Example

Kubernetes

Secret:

```yaml
kind: Secret
apiVersion: v1
metadata:
  name: mysql-backup-ssh-cred
type: Opaque
data:
  privkey.pem: 'BASE64 ENCODED PRIVATE KEY'
  known_hosts: 'BASE64 ENCODED KNOWN HOSTS'

---

kind: Secret
apiVersion: v1
metadata:
  name: mysqk-backup-db-cred
type: Opaque
data:
  host: 'BASE64 ENCODED HOST'
  username: 'BASE64 ENCODED USERNAME'
  password: 'BASE64 ENCODED PASSWORD'
```

Cron Job
```yaml
kind: CronJob
apiVersion: batch/v1beta1
metadata:
  name: k8s-cluster-mysql-backup-cronjob
spec:
  schedule: 0 0 * * *
  concurrencyPolicy: Allow
  suspend: false
  jobTemplate:
    metadata:
      creationTimestamp: null
      labels:
        job: k8s-cluster-mysql-backup-cronjob
    spec:
      template:
        metadata:
          creationTimestamp: null
          labels:
            job: k8s-cluster-mysql-backup-cronjob
        spec:
          restartPolicy: OnFailure
          volumes:
            - name: ssh-secret
              secret:
                secretName: mysql-backup-ssh-cred
                defaultMode: 400
          containers:
            - name: main
              image: 'jclab/mysql-backupper:release-0.0.1'
              command:
                - /bin/bash
                - '-c'
                - >-
                  set -e;
                  BACKUP_FILE_NAME=mysql-`date "+%Y-%m-%d_%H-%M-%S"`.sql;
                  export BACKUP_FILE=/tmp/${BACKUP_FILE_NAME};
                  export REMOTE_PATH=/backup/mysql/${BACKUP_FILE_NAME};
                  /opt/mysql_dump.sh;
                  /opt/scp_backup.sh
              env:
                - name: MYSQLDUMP_OPTIONS
                  value: '--all-databases --hex-blob'
                - name: SSH_KEY_FILE
                  value: /root/ssh-secret/privkey.pem
                - name: SSH_KNOWN_HOSTS_FILE
                  value: /root/ssh-secret/known_hosts
                - name: REMOTE_HOST
                  value: 'BACKUP_REMOTE_SERVER'
                - name: REMOTE_USER
                  value: 'BACKUP_REMOTE_USER'
                - name: MYSQL_HOST
                  valueFrom:
                    secretKeyRef:
                      name: mysqk-backup-db-cred
                      key: host
                - name: MYSQL_USER
                  valueFrom:
                    secretKeyRef:
                      name: mysqk-backup-db-cred
                      key: username
                - name: MYSQL_PASS
                  valueFrom:
                    secretKeyRef:
                      name: mysqk-backup-db-cred
                      key: password
              resources: {}
              volumeMounts:
                - name: ssh-secret
                  mountPath: /root/ssh-secret
              terminationMessagePath: /dev/termination-log
              terminationMessagePolicy: File
              imagePullPolicy: IfNotPresent
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
```
