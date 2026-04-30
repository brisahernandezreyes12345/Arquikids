# -*- mode: python ; coding: utf-8 -*-
a = Analysis(
    ['main.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('views', 'views'),
        ('assets', 'assets'),
        ('database/crear_tablas_sqlite.sql', 'database'),
    ],
    hiddenimports=[
        'pystray', 'PIL', 'PIL.Image', 'PIL.ImageDraw','uvicorn.logging', 'uvicorn.loops', 'uvicorn.loops.auto',
        'uvicorn.protocols', 'uvicorn.protocols.http',
        'uvicorn.protocols.http.auto', 'uvicorn.protocols.websockets',
        'uvicorn.protocols.websockets.auto', 'uvicorn.lifespan',
        'uvicorn.lifespan.on', 'fastapi', 'pydantic',
        'starlette', 'anyio', 'anyio._backends._asyncio',
    ],
    hookspath=[],
    noarchive=False,
)
pyz = PYZ(a.pure)
exe = EXE(
    pyz, a.scripts, a.binaries, a.datas,
    name='ArquiKids',
    debug=False,
    console=False,          # Sin ventana negra de consola
)