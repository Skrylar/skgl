
def task_gles2():
    yield {
    	'name': 'compile',
    	'actions': [
            'm4 -P src/skgl/gles2.m4 > src/skgl/gles2_gen.nim',
            'nim c src/skgl/gles2',
            'git add src/skgl/gles2.nim src/skgl/gles2_gen.nim src/skgl/gles2.m4',
            'git commit -m "checkpoint"'],
    	'targets': ['src/skgl/gles2_gen.nim', 'src/skgl/gles2'],
    	'file_dep': ['src/skgl/gles2.nim', 'src/skgl/gles2.m4']
    }

