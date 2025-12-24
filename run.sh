#!/bin/bash
# macOS 快捷键查询工具启动脚本

echo "正在启动 macOS 快捷键查询工具..."
echo ""

# 检查是否安装了依赖
if ! python3 -c "import flask" 2>/dev/null; then
    echo "检测到未安装依赖，正在安装..."
    pip3 install -r requirements.txt
    echo ""
fi

# 启动应用
echo "应用将在 http://localhost:5000 启动"
echo "按 Ctrl+C 停止服务"
echo ""
python3 app.py

