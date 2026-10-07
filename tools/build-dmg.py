#!/usr/bin/env python3
"""Package the Chinese app as a drag-to-install disk image."""
from pathlib import Path
import shutil
import subprocess
import tempfile

from ds_store import DSStore

ROOT = Path(__file__).resolve().parent.parent
APP_NAME = 'RemoveMacAI 中文版.app'
RELEASE = '1.0.1-zh-Hans.1'
app = ROOT / '.build' / APP_NAME
if not app.is_dir():
    raise SystemExit('先运行 tools/build-app.sh 构建中文版应用。')
subprocess.run(['codesign', '--verify', '--strict', str(app)], check=True)
dist = ROOT / 'dist'
dist.mkdir(exist_ok=True)
image = dist / f'RemoveMacAI-{RELEASE}-arm64.dmg'
with tempfile.TemporaryDirectory(prefix='removemacai-dmg-') as folder:
    stage = Path(folder) / 'stage'
    stage.mkdir()
    subprocess.run(['ditto', '--norsrc', str(app), str(stage / APP_NAME)], check=True)
    (stage / 'Applications').symlink_to('/Applications')
    (stage / '安装说明.txt').write_text('''RemoveMacAI 中文版 1.0.1 · 简体中文第 1 版

安装：将“RemoveMacAI 中文版”拖到 Applications（应用程序）。
随后推出此磁盘映像，从“应用程序”启动中文版。

首次打开若提示无法验证开发者，请前往：
系统设置 → 隐私与安全性 → 仍要打开。

适用于 Apple 芯片 Mac，已在 macOS 27.0.1 验证。
本版本使用本地签名，未经 Apple 公证。

可与英文原版并存，共用已有操作记录和 RemoveMacAI 描述文件。
应用系统调整前请检查预览；后台项目开关立即生效。
模拟器和时间机器本地快照会永久删除，不经过废纸篓。

源码与更新：https://github.com/nextwa/RemoveMacAI
上游项目：https://github.com/omlahore/RemoveMacAI
许可证：MIT；授权文件位于应用包 Contents/Resources。
''', encoding='utf-8')
    shutil.copyfile(ROOT / 'README.zh-Hans.md', stage / '中文使用指南.md')
    with DSStore.open(str(stage / '.DS_Store'), 'w+') as store:
        store['.']['bwsp'] = {
            'ShowStatusBar': False, 'ShowPathbar': False,
            'ShowToolbar': False, 'ShowSidebar': False,
            'WindowBounds': '{{200, 160}, {680, 440}}',
            'ContainerShowSidebar': False,
        }
        store['.']['icvp'] = {
            'viewOptionsVersion': 1, 'backgroundType': 1,
            'backgroundColorRed': 0.97, 'backgroundColorGreen': 0.98,
            'backgroundColorBlue': 0.98, 'iconSize': 100.0,
            'textSize': 14.0, 'gridSpacing': 100.0,
            'gridOffsetX': 0.0, 'gridOffsetY': 0.0,
            'arrangeBy': 'none', 'labelOnBottom': True,
            'showIconPreview': True, 'showItemInfo': False,
        }
        store['.']['vSrn'] = ('long', 1)
        store['.']['vstl'] = ('type', 'icnv')
        for name, position in [
            (APP_NAME, (180, 140)), ('Applications', (500, 140)),
            ('安装说明.txt', (180, 325)), ('中文使用指南.md', (500, 325)),
        ]:
            store[name]['Iloc'] = position
    subprocess.run([
        'hdiutil', 'create', '-ov', '-format', 'UDZO', '-fs', 'HFS+',
        '-volname', 'RemoveMacAI 中文版', '-srcfolder', str(stage), str(image),
    ], check=True)
print(image)
