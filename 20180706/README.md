# 更新Kubernetes在Amazon的docker仓库的动态密码
```bash
dockerconfigjson='{"auths":{"xxxxecr.amazonaws.com":{"password":"'$(aws ecr get-login --no-include-email | awk '{print $6}')'","username":"AWS"}}}'
kubectl get secret registry -o yaml --namespace OkabeRintarou | sed 's/\(\.dockerconfigjson: \).*/\1'$(echo -n $dockerconfigjson | base64 -w0)'/' | kubectl replace -f -
```
如果使用rancher管理集群,还可以通过api来更新
```bash
password=$(aws ecr get-login --no-include-email | awk '{print $6}')
curl -ksL -u "${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY}" -H 'Content-Type: application/json' -X PUT -d '{......{"xxxxecr.amazonaws.com":{"username":"AWS","password":"'$password'"}},"type":"dockerCredential",xxxxx}' 'https://rancher.beijing.com/v3/project/xxxxx/dockerCredentials/xxxxx:registry'
```
以上内容可以手动修改密码时在浏览器中用`F12`查看