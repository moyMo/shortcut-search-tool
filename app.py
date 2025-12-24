from flask import Flask, render_template, jsonify, request
from flask_cors import CORS
import re
import os

app = Flask(__name__)
CORS(app)

# 解析快捷键文件
def parse_shortcuts(file_path):
    """解析 translation.md 文件，提取快捷键数据"""
    shortcuts = []
    current_category = None
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
        
        # 跳过标题行
        if line == '默认 macOS 键盘映射':
            continue
        
        # 检测分类标题（以 ** 开头和结尾）
        if line.startswith('**') and line.endswith('**'):
            current_category = line.strip('*')
            continue
        
        # 检测快捷键行（包含功能名和快捷键）
        # 格式：功能名 快捷键
        if current_category and not line.startswith('**'):
            # 尝试匹配：功能名后面跟着快捷键的模式
            # 快捷键通常包含特殊符号如 ⌘, ⌃, ⌥, ⇧, F数字等
            # 匹配模式：功能名 + 空格 + 快捷键（快捷键可能包含多个部分）
            parts = line.split()
            if len(parts) >= 2:
                # 找到第一个包含快捷键符号的部分
                shortcut_start_idx = None
                for i, part in enumerate(parts):
                    if any(char in part for char in '⌘⌃⌥⇧⎋⌨⌦↩⇥F←→↑↓'):
                        shortcut_start_idx = i
                        break
                    # 也检查是否是 "Space", "双击" 等
                    if part in ['Space', '双击'] or part.startswith('F') and part[1:].isdigit():
                        shortcut_start_idx = i
                        break
                
                if shortcut_start_idx is not None:
                    function_name = ' '.join(parts[:shortcut_start_idx])
                    shortcut_keys = ' '.join(parts[shortcut_start_idx:])
                    
                    if function_name and shortcut_keys:
                        shortcuts.append({
                            'category': current_category,
                            'function': function_name,
                            'shortcut': shortcut_keys
                        })
    
    return shortcuts

# 加载快捷键数据
SHORTCUTS_FILE = os.path.join(os.path.dirname(__file__), 'translation.md')
shortcuts_data = parse_shortcuts(SHORTCUTS_FILE)

@app.route('/')
def index():
    """主页面"""
    return render_template('index.html')

@app.route('/api/shortcuts', methods=['GET'])
def get_shortcuts():
    """获取所有快捷键"""
    return jsonify({
        'success': True,
        'data': shortcuts_data,
        'total': len(shortcuts_data)
    })

@app.route('/api/search', methods=['GET'])
def search_shortcuts():
    """搜索快捷键"""
    query = request.args.get('q', '').strip().lower()
    category = request.args.get('category', '').strip()
    
    if not query and not category:
        return jsonify({
            'success': True,
            'data': shortcuts_data,
            'total': len(shortcuts_data)
        })
    
    results = []
    for item in shortcuts_data:
        # 按分类筛选
        if category and item['category'] != category:
            continue
        
        # 按关键词搜索（功能名或快捷键）
        if query:
            if (query in item['function'].lower() or 
                query in item['shortcut'].lower()):
                results.append(item)
        else:
            results.append(item)
    
    return jsonify({
        'success': True,
        'data': results,
        'total': len(results)
    })

@app.route('/api/categories', methods=['GET'])
def get_categories():
    """获取所有分类"""
    categories = list(set(item['category'] for item in shortcuts_data))
    categories.sort()
    return jsonify({
        'success': True,
        'data': categories
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)

