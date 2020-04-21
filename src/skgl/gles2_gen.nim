proc open*(self: var FrameBuffer) {.inline.} =
    assert self.Gluint == 0
    glGenFramebuffers(1, cast[ptr Gluint](addr self))

proc open*(self: var RenderBuffer) {.inline.} =
    assert self.Gluint == 0
    glGenRenderbuffers(1, cast[ptr Gluint](addr self))

proc open*(self: var Buffer) {.inline.} =
    assert self.Gluint == 0
    glGenBuffers(1, cast[ptr Gluint](addr self))

proc open*(self: var Texture) {.inline.} =
    assert self.Gluint == 0
    glGenTextures(1, cast[ptr Gluint](addr self))


proc close*(self: var FrameBuffer) {.inline.} =
    assert self.Gluint != 0
    glDeleteFramebuffers(1, cast[ptr Gluint](addr self))
    self = 0.FrameBuffer

proc close*(self: var RenderBuffer) {.inline.} =
    assert self.Gluint != 0
    glDeleteRenderbuffers(1, cast[ptr Gluint](addr self))
    self = 0.RenderBuffer

proc close*(self: var Buffer) {.inline.} =
    assert self.Gluint != 0
    glDeleteBuffers(1, cast[ptr Gluint](addr self))
    self = 0.Buffer

proc close*(self: var Texture) {.inline.} =
    assert self.Gluint != 0
    glDeleteTextures(1, cast[ptr Gluint](addr self))
    self = 0.Texture


