# 批量修改ssh密码
```bash
for i in {1..100}; do
    sshpass -p old_password ssh root@192.168.0.$i 'echo "new_password" | passwd --stdin root'
done
```