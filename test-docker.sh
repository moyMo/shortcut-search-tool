#!/bin/bash
# Docker 部署测试脚本

echo "=== macOS 快捷键查询工具 Docker 部署测试 ==="
echo ""

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

echo "✅ Docker 已安装: $(docker --version)"

# 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "⚠️  Docker Compose 未安装，将使用 Docker 命令测试"
    USE_COMPOSE=false
else
    echo "✅ Docker Compose 已安装: $(docker-compose --version)"
    USE_COMPOSE=true
fi

echo ""
echo "1. 测试 Docker 构建..."
docker build -t shortcut-search-test .

if [ $? -eq 0 ]; then
    echo "✅ Docker 构建成功"
else
    echo "❌ Docker 构建失败"
    exit 1
fi

echo ""
echo "2. 测试 Docker 运行..."
docker run -d -p 5002:5000 --name test-container shortcut-search-test
sleep 3

# 检查容器状态
if docker ps | grep -q test-container; then
    echo "✅ 容器启动成功"
    
    # 测试 API
    echo ""
    echo "3. 测试 API 接口..."
    sleep 2
    
    echo "测试 /api/shortcuts 接口:"
    curl -s http://localhost:5002/api/shortcuts | jq '.success' 2>/dev/null || curl -s http://localhost:5002/api/shortcuts | grep -o '"success":[^,]*'
    
    echo ""
    echo "测试 /api/categories 接口:"
    curl -s http://localhost:5002/api/categories | jq '.success' 2>/dev/null || curl -s http://localhost:5002/api/categories | grep -o '"success":[^,]*'
    
    echo ""
    echo "测试 /api/search 接口 (搜索'代码'):"
    curl -s "http://localhost:5002/api/search?q=%E4%BB%A3%E7%A0%81" | jq '.total' 2>/dev/null || curl -s "http://localhost:5002/api/search?q=%E4%BB%A3%E7%A0%81" | grep -o '"total":[^,]*'
    
    # 停止测试容器
    echo ""
    echo "4. 清理测试容器..."
    docker stop test-container
    docker rm test-container
    echo "✅ 测试容器已清理"
else
    echo "❌ 容器启动失败"
    docker logs test-container
    exit 1
fi

echo ""
if [ "$USE_COMPOSE" = true ]; then
    echo "5. 测试 Docker Compose..."
    docker-compose up -d
    sleep 3
    
    if docker-compose ps | grep -q "Up"; then
        echo "✅ Docker Compose 启动成功"
        echo "应用运行在: http://localhost:5000"
        echo ""
        echo "管理命令:"
        echo "  docker-compose ps      # 查看状态"
        echo "  docker-compose logs    # 查看日志"
        echo "  docker-compose down    # 停止服务"
        echo ""
        echo "✅ 所有测试通过！"
    else
        echo "❌ Docker Compose 启动失败"
        docker-compose logs
        exit 1
    fi
else
    echo "✅ 所有测试通过！"
    echo "使用以下命令运行应用:"
    echo "  docker run -d -p 5000:5000 --name shortcut-search shortcut-search-tool"
fi

echo ""
echo "=== 部署测试完成 ==="
