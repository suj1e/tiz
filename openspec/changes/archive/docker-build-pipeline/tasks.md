# 任务清单

## 前置条件

- [ ] **在 GitHub 仓库配置 Secrets**
  - `ALIYUN_REGISTRY_USERNAME`
  - `ALIYUN_REGISTRY_PASSWORD`

## Java 服务流水线

- [ ] **T1: docker-authsrv.yml**
  - 路径: `.github/workflows/docker-authsrv.yml`
  - context: `tiz-backend/authsrv`
  - PORT: 8101

- [ ] **T2: docker-chatsrv.yml**
  - 路径: `.github/workflows/docker-chatsrv.yml`
  - context: `tiz-backend/chatsrv`
  - PORT: 8102

- [ ] **T3: docker-contentsrv.yml**
  - 路径: `.github/workflows/docker-contentsrv.yml`
  - context: `tiz-backend/contentsrv`
  - PORT: 8103

- [ ] **T4: docker-practicesrv.yml**
  - 路径: `.github/workflows/docker-practicesrv.yml`
  - context: `tiz-backend/practicesrv`
  - PORT: 8104

- [ ] **T5: docker-quizsrv.yml**
  - 路径: `.github/workflows/docker-quizsrv.yml`
  - context: `tiz-backend/quizsrv`
  - PORT: 8105

- [ ] **T6: docker-usersrv.yml**
  - 路径: `.github/workflows/docker-usersrv.yml`
  - context: `tiz-backend/usersrv`
  - PORT: 8107

- [ ] **T7: docker-gatewaysrv.yml**
  - 路径: `.github/workflows/docker-gatewaysrv.yml`
  - context: `tiz-backend/gatewaysrv`
  - PORT: 8080

## Python 服务流水线

- [ ] **T8: docker-llmsrv.yml**
  - 路径: `.github/workflows/docker-llmsrv.yml`
  - context: `tiz-backend/llmsrv`
  - 无需 PORT 参数

## 前端流水线

- [ ] **T9: docker-tiz-web.yml**
  - 路径: `.github/workflows/docker-tiz-web.yml`
  - context: `tiz-web`
  - 无需 PORT 参数

## 验证

- [ ] **T10: 验证流水线**
  - 提交并推送到 GitHub
  - 手动触发一个流水线测试
  - 检查阿里云镜像仓库是否推送成功
