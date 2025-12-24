# macOS 快捷键查询工具

一个基于 Web 的 macOS 快捷键查询工具，可以快速搜索和浏览 macOS 键盘快捷键。

## 功能特性

- 🔍 **智能搜索**：支持按功能名称或快捷键搜索
- 📂 **分类筛选**：按分类快速筛选快捷键
- 🎨 **美观界面**：现代化的 UI 设计，响应式布局
- ⚡ **实时搜索**：输入即时搜索，无需点击按钮

## 安装和运行

### 方法一：使用启动脚本（推荐）

```bash
./run.sh
```

启动脚本会自动检查并安装依赖，然后启动应用。

### 方法二：手动启动

#### 1. 安装依赖

```bash
pip install -r requirements.txt
```

或使用 pip3：

```bash
pip3 install -r requirements.txt
```

#### 2. 运行应用

```bash
python app.py
```

或使用 python3：

```bash
python3 app.py
```

#### 3. 访问应用

在浏览器中打开：http://localhost:5000

### 方法三：使用 Docker 部署

#### 使用 Dockerfile 构建镜像

```bash
# 构建 Docker 镜像
docker build -t shortcut-search-tool .

# 运行容器
docker run -d -p 5000:5000 --name shortcut-search shortcut-search-tool
```

#### 使用 Docker Compose（推荐）

```bash
# 启动服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 停止服务
docker-compose down

# 查看日志
docker-compose logs -f
```

#### 访问应用

在浏览器中打开：http://localhost:5000

## 项目结构

```
shortcut-search-tool/
├── app.py              # Flask 后端应用
├── templates/
│   └── index.html      # 前端页面
├── requirements.txt    # Python 依赖
└── README.md          # 项目说明
```

## API 接口

### 获取所有快捷键
```
GET /api/shortcuts
```

### 搜索快捷键
```
GET /api/search?q=关键词&category=分类名
```

参数：
- `q`: 搜索关键词（可选）
- `category`: 分类名称（可选）

### 获取所有分类
```
GET /api/categories
```

## 使用说明

1. **搜索功能**：在搜索框中输入功能名称或快捷键关键词，系统会实时显示匹配结果
2. **分类筛选**：使用下拉菜单选择特定分类，只显示该分类下的快捷键
3. **清除搜索**：点击"清除"按钮重置所有筛选条件

## 技术栈

- **后端**：Flask (Python)
- **前端**：HTML + CSS + JavaScript
- **样式**：原生 CSS（无框架依赖）
