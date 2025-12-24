# Docker 部署指南

本文档提供 macOS 快捷键查询工具的 Docker 部署说明。

## 前提条件

- 已安装 Docker（版本 20.10+）
- 已安装 Docker Compose（版本 2.0+，可选但推荐）
- 基本的 Docker 命令行知识

## 部署方法

### 方法一：使用 Docker Compose（推荐）

Docker Compose 提供了最简单的一键部署方式。

#### 1. 启动服务

```bash
# 在项目根目录执行
docker-compose up -d
```

#### 2. 验证部署

```bash
# 检查容器状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 测试 API
curl http://localhost:5000/api/shortcuts
```

#### 3. 管理服务

```bash
# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 重新构建并启动
docker-compose up -d --build

# 查看实时日志
docker-compose logs -f shortcut-search
```

### 方法二：使用 Docker 命令

#### 1. 构建 Docker 镜像

```bash
# 构建镜像
docker build -t shortcut-search-tool .

# 查看构建的镜像
docker images | grep shortcut-search-tool
```

#### 2. 运行容器

```bash
# 运行容器（后台模式）
docker run -d \
  -p 5000:5000 \
  --name shortcut-search \
  shortcut-search-tool

# 运行容器（交互模式，查看日志）
docker run -p 5000:5000 --name shortcut-search shortcut-search-tool
```

#### 3. 管理容器

```bash
# 查看运行中的容器
docker ps

# 查看所有容器（包括停止的）
docker ps -a

# 停止容器
docker stop shortcut-search

# 启动已停止的容器
docker start shortcut-search

# 重启容器
docker restart shortcut-search

# 删除容器
docker rm shortcut-search

# 删除镜像
docker rmi shortcut-search-tool
```

### 方法三：使用生产环境配置

创建 `docker-compose.prod.yml` 文件用于生产环境：

```yaml
version: '3.8'

services:
  shortcut-search:
    build: .
    container_name: shortcut-search-tool-prod
    ports:
      - "5000:5000"
    environment:
      - FLASK_APP=app.py
      - FLASK_ENV=production
      - PYTHONUNBUFFERED=1
    volumes:
      - ./translation.md:/app/translation.md:ro
      - ./templates:/app/templates:ro
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/api/shortcuts"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

使用生产配置启动：

```bash
docker-compose -f docker-compose.prod.yml up -d
```

## 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| FLASK_APP | app.py | Flask 应用入口文件 |
| FLASK_ENV | production | 运行环境（production/development） |
| FLASK_RUN_HOST | 0.0.0.0 | 绑定主机地址 |
| PYTHONUNBUFFERED | 1 | 禁用 Python 输出缓冲 |

### 端口映射

- 容器内部端口：5000
- 主机映射端口：5000（可在 docker-compose.yml 中修改）

### 数据卷

- `./translation.md:/app/translation.md:ro` - 只读挂载快捷键数据文件
- `./templates:/app/templates:ro` - 只读挂载模板文件

## 故障排除

### 1. 端口冲突

如果端口 5000 已被占用，修改端口映射：

```yaml
# docker-compose.yml
ports:
  - "8080:5000"  # 主机端口:容器端口
```

### 2. 构建失败

```bash
# 清理构建缓存
docker system prune -a

# 重新构建
docker-compose build --no-cache
```

### 3. 容器无法启动

```bash
# 查看详细日志
docker logs shortcut-search-tool

# 进入容器调试
docker exec -it shortcut-search-tool /bin/bash
```

### 4. 健康检查失败

```bash
# 临时禁用健康检查
# 在 docker-compose.yml 中注释掉 healthcheck 部分
```

## 安全建议

1. **使用非 root 用户**：Dockerfile 已配置使用 appuser 用户运行应用
2. **只读挂载**：数据文件以只读方式挂载，防止意外修改
3. **生产环境配置**：使用生产环境配置，禁用调试模式
4. **网络隔离**：在生产环境中考虑使用 Docker 网络隔离

## 更新部署

### 更新应用代码

```bash
# 拉取最新代码
git pull origin main

# 重新构建并启动
docker-compose up -d --build
```

### 更新依赖

1. 更新 `requirements.txt` 文件
2. 重新构建镜像：
   ```bash
   docker-compose build --no-cache
   docker-compose up -d
   ```

## 性能优化

### 多阶段构建（可选）

如需进一步优化镜像大小，可使用多阶段构建：

```dockerfile
# 第一阶段：构建
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# 第二阶段：运行
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
USER 1000
EXPOSE 5000
CMD ["python", "app.py"]
```

## 支持与反馈

如有部署问题，请检查：
1. Docker 和 Docker Compose 版本
2. 系统资源（内存、磁盘空间）
3. 网络连接和防火墙设置

参考文档：
- [Docker 官方文档](https://docs.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [Flask 部署指南](https://flask.palletsprojects.com/en/stable/deploying/)
