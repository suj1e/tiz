# 任务清单

## 部署流水线 (9个)

- [ ] **T1: deploy-authsrv.yml**
- [ ] **T2: deploy-chatsrv.yml**
- [ ] **T3: deploy-contentsrv.yml**
- [ ] **T4: deploy-practicesrv.yml**
- [ ] **T5: deploy-quizsrv.yml**
- [ ] **T6: deploy-usersrv.yml**
- [ ] **T7: deploy-gatewaysrv.yml**
- [ ] **T8: deploy-llmsrv.yml**
- [ ] **T9: deploy-tiz-web.yml**

## 同时需要修改

- [ ] **T10: 修改构建流水线**
  - docker-xxx.yml 的 tags 需要添加 `sha-xxx` 格式
  - 当前已有，确认格式正确

## 服务器准备 (手动)

- [ ] 安装 Docker + docker-compose
- [ ] 登录阿里云镜像仓库
- [ ] 创建 npass 网络
- [ ] 创建 /opt/dev/deploy/staging/.env 文件
