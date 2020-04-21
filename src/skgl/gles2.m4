m4_define(thing, `proc open*(self: var $1) {.inline.} =
    assert self.Gluint == 0
    $2(1, cast[ptr Gluint](addr self))
')m4_dnl
thing(FrameBuffer, glGenFramebuffers)
thing(RenderBuffer, glGenRenderbuffers)
thing(Buffer, glGenBuffers)
thing(Texture, glGenTextures)
m4_undefine(`thing')
m4_define(thing, `proc close*(self: var $1) {.inline.} =
    assert self.Gluint != 0
    $2(1, cast[ptr Gluint](addr self))
    self = 0.$1
')m4_dnl
thing(FrameBuffer, glDeleteFramebuffers)
thing(RenderBuffer, glDeleteRenderbuffers)
thing(Buffer, glDeleteBuffers)
thing(Texture, glDeleteTextures)
m4_undefine(`thing')
