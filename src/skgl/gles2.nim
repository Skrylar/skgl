import opengl

type
    ShaderProgram* = distinct GLuint
    VertexShader* = distinct GLuint
    FragmentShader* = distinct GLuint
    Buffer* = distinct GLuint
    FrameBuffer* = distinct GLuint
    RenderBuffer* = distinct GLuint
    Texture* = distinct GLuint

    attributes* = object
        ## I am a shim to allow array notation to enable or disable
        ## attribute arrays.

type
    TargetBuffer* {.pure.} = enum
        Array        = GL_ARRAY_BUFFER
        ElementArray = GL_ELEMENT_ARRAY_BUFFER

    BufferUsage* {.pure.} = enum
        Stream  = GL_STREAM_DRAW
        Static  = GL_STATIC_DRAW
        Dynamic = GL_DYNAMIC_DRAW

    TargetTexture* {.pure.} = enum
        TwoD          = GL_TEXTURE_2D
        CubeXPositive = GL_TEXTURE_CUBE_MAP_POSITIVE_X
        CubeXNegative = GL_TEXTURE_CUBE_MAP_NEGATIVE_X
        CubeYPositive = GL_TEXTURE_CUBE_MAP_POSITIVE_Y
        CubeYNegative = GL_TEXTURE_CUBE_MAP_NEGATIVE_Y
        CubeZPositive = GL_TEXTURE_CUBE_MAP_POSITIVE_Z
        CubeZNegative = GL_TEXTURE_CUBE_MAP_NEGATIVE_Z

    CullMode* {.pure.} = enum
        Front        = GL_FRONT
        Back         = GL_BACK
        FrontAndBack = GL_FRONT_AND_BACK

    DepthFunction* {.pure.} = enum
        Never    = GL_NEVER
        Less     = GL_LESS
        Equal    = GL_EQUAL
        Lequal   = GL_LEQUAL
        Greater  = GL_GREATER
        NotEqual = GL_NOTEQUAL
        Gequal   = GL_GEQUAL
        Always   = GL_ALWAYS

    RenderBufferAttachment* {.pure.} = enum
        Color   = GL_COLOR_ATTACHMENT0
        Depth   = GL_DEPTH_ATTACHMENT
        Stencil = GL_STENCIL_ATTACHMENT

    FaceOrientation* {.pure.} = enum
        Clockwise        = GL_CW
        Counterclockwise = GL_CCW

proc `active_texture=`*(unit: int) {.inline.} =
    ## Sets the active texture unit.
    gl_active_texture((GL_TEXTURE0.cint + unit.cint).Glenum)

proc active_texture*(): int {.inline.} =
    ## Retrieves the active texture unit.
    var tmp: Glint
    gl_get_integerv(GL_ACTIVE_TEXTURE, addr tmp)
    result = tmp.int

proc max_texture_units*(): int {.inline.} =
    ## Retrieves the maximum number of texture units you can use.
    var tmp: Glint
    gl_get_integerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, addr tmp)
    result = tmp.int

proc bind_attribute_location*(
    self: var ShaderProgram; index: uint; name: cstring) {.inline.} =
        gl_bind_attrib_location(self.Gluint, index.Gluint, name)

proc open*(self: var ShaderProgram) {.inline.} =
    ## Create a new program which contains shaders.
    assert self.cint == 0
    self = glcreateprogram().ShaderProgram

proc open*(self: var VertexShader) {.inline.} =
    ## Create a vertex shader handle.
    assert self.cint == 0
    self = glcreateshader(GL_VERTEX_SHADER).VertexShader

proc open*(self: var FragmentShader) {.inline.} =
    ## Create a fragment shader handle.
    assert self.cint == 0
    self = glcreateshader(GL_FRAGMENT_SHADER).FragmentShader

proc attach*[T:VertexShader|FragmentShader](self: var ShaderProgram; shader: T) {.inline.} =
    ## Attach a shader to a program.
    assert self.Gluint != 0
    assert shader.Gluint != 0
    glattachshader(self.Gluint, shader.Gluint)

template `~=`*[T:VertexShader|FragmentShader](self: var ShaderProgram; other: T) =
    ## Aliases the concatenation operator to append shaders to programs.
    self.attach(other)

proc use*(self: ShaderProgram) {.inline.} =
    ## Binds the shader program for use.
    assert self.Gluint != 0
    gluseprogram(self.Gluint)

proc link*(self: var ShaderProgram): bool {.inline.} =
    ## Links the shader program.
    assert self.Gluint != 0
    gllinkprogram(self.Gluint)
    var temp: GLint
    glgetprogramiv(self.GLuint, GL_LINK_STATUS, addr temp)
    return temp != GL_FALSE.GLint

proc compile*[T:VertexShader|FragmentShader](self: var T): bool {.inline.} =
    ## Compiles a GLSL shader and returns whether that was successful.
    assert self.cint != 0
    glcompileshader(self.GLuint)
    var temp: GLint
    glgetshaderiv(self.GLuint, GL_COMPILE_STATUS, addr temp)
    return temp != GL_FALSE.GLint

proc `source=`*[T:VertexShader|FragmentShader](self: var T; source: string) =
    ## Uploads GLSL source code for the shader.
    var x: Glint = source.len.Glint
    var y = unsafeaddr source[0]
    glshadersource(self.Gluint, 1, cast[cstringarray](addr y), addr x)

proc infolog*(self: ShaderProgram): string =
    ## Returns the infolog from a program.
    var loglength: Glint
    glgetprogramiv(self.Gluint, GL_INFO_LOG_LENGTH, addr loglength)
    result = new_string(loglength)
    glgetprograminfolog(self.Gluint, loglength, nil, addr result[0])

proc infolog*[T:FragmentShader|VertexShader](self: T): string =
    ## Returns the infolog from a shader.
    var loglength: Glint
    glgetshaderiv(self.Gluint, GL_INFO_LOG_LENGTH, addr loglength)
    result = new_string(loglength)
    glgetshaderinfolog(self.Gluint, loglength, nil, addr result[0])

proc use*(self: Buffer; target: GLenum) {.inline.} =
    ## Binds a buffer to the specified target.
    glbindbuffer(target, self.Gluint)

proc use_array*(self: Buffer) {.inline.} =
    ## Binds the buffer for use with glBuffer and glVertexPointers.
    glbindbuffer(Gl_array_buffer, self.Gluint)

proc use_element*(self: Buffer) {.inline.} =
    ## Binds the buffer for use with glDrawElements.
    glbindbuffer(Gl_element_array_buffer, self.Gluint)

proc find_uniform*(self: ShaderProgram; name: string): Glint {.inline.} =
    ## Locates the index of a uniform with the given name, within a
    ## shader program.
    assert self.Gluint != 0
    return glgetuniformlocation(self.Gluint, name.cstring)

proc use*(self: Framebuffer; target: Glenum) =
    ## Binds the frame buffer to a target.
    gl_bind_framebuffer(target, self.Gluint)

proc use*(self: Renderbuffer; target: Glenum) =
    ## Binds the render buffer to a target.
    gl_bind_renderbuffer(target, self.Gluint)

proc `blend_color=`*(r, g, b, a: float) {.inline.} =
    ## Changes the blending color.
    gl_blend_color(r.Glclampf, g.Glclampf, b.Glclampf, a.Glclampf)

proc `blend_equation=`*(mode: Glenum) {.inline.} =
    ## Sets the blend equation.
    gl_blend_equation(mode)

proc set_blend_equation_separate*(mode_rgb, mode_alpha: Glenum) {.inline.} =
    ## Sets separate blend equations for RGB and Alpha channels.
    gl_blend_equation_separate(mode_rgb, mode_alpha)

proc set_blend_function*(sfactor, dfactor: Glenum) {.inline.} =
    ## Sets the blending function.
    gl_blend_func(sfactor, dfactor)

proc set_blend_function_separate*(
    src_rgb, dst_rgb, src_alpha, dst_alpha: Glenum) {.inline.} =
        ## Sets blend functions for RGB and alpha channels.
        gl_blend_func_separate(src_rgb, dst_rgb, src_alpha, dst_alpha)

proc upload_buffer*(
    target: TargetBuffer;
    size: csizet;
    data: pointer;
    usage: BufferUsage) {.inline.} =
        ## Uploads data to the currently bound buffer.
        gl_buffer_data(target.Glenum, size.Glsizeiptr, data, usage.Glenum)

proc upload_sub_buffer*(
    target: TargetBuffer;
    offset: int;
    size: csizet;
    data: pointer) {.inline.} =
        ## Uploads data to a subset of the currently bound buffer.
        gl_buffer_sub_data(
            target.Glenum,
            offset.Glintptr,
            size.Glsizeiptr,
            data)

proc framebuffer_status*(target: Glenum = GL_FRAMEBUFFER): Glenum {.inline.} =
    ## Returns the status of the currently bound framebuffer object In .
    ## GLES2 the target must be the framebuffer, so that is the default.
    ## argument to this procedure                                      .
    return gl_check_framebuffer_status(target)

proc clear*(mask: Glbitfield) {.inline.} =
    ## Clears some buffers. TODO would like some macros that take a
    ## type-safe set and output the bit field in the background.
    gl_clear(mask)

proc set_clear_color*(r, g, b, a: Glclampf) {.inline.} =
    gl_clear_color(r, g, b, a)

proc set_clear_color*(r, g, b, a: float) {.inline.} =
    gl_clear_color(r.Glclampf, g.Glclampf, b.Glclampf, a.Glclampf)

proc `clear_depth=`*(depth: Glclampf) {.inline.} =
    gl_clear_depthf(depth)

proc `clear_depth=`*(depth: float) {.inline.} =
    gl_clear_depthf(depth)

proc `clear_stencil=`*(stencil: Glint) {.inline.} =
    ## Sets the value the stencil buffer will be filled with when the
    ## stencil buffer is cleared.
    gl_clear_stencil(stencil)

proc `clear_stencil=`*(stencil: int) {.inline.} =
    ## Sets the value the stencil buffer will be filled with when the
    ## stencil buffer is cleared.
    gl_clear_stencil(stencil.Glint)

proc set_color_mask*(r, g, b, a: bool = true) {.inline.} =
    gl_color_mask(r.Glboolean, g.Glboolean, b.Glboolean, a.Glboolean)

proc upload_compressed_texture_2d*(
    target: TargetTexture;
    level: int;
    internal_format: Glenum;
    width, height: int;
    size: csizet;
    data: pointer) {.inline.} =
        gl_compressed_tex_image_2d(
            target.Glenum,
            level.Glint,
            internal_format,
            width.Glsizei,
            height.Glsizei,
            0, # GLES2 says the border must be zero
            size.Glsizei,
            data)

proc upload_compressed_sub_texture_2d*(
    target: TargetTexture;
    level: int;
    xoffset, yoffset: int;
    width, height: int;
    internal_format: Glenum;
    size: csizet;
    data: pointer) {.inline.} =
        gl_compressed_tex_subimage_2d(
            target.Glenum,
            level.Glint,
            xoffset.Glint,
            yoffset.Glint,
            width.Glsizei,
            height.Glsizei,
            internal_format,
            size.Glsizei,
            data)

proc copy_tex_image_2d*(
    target: TargetTexture;
    internal_format: Glenum;
    level: int;
    x, y: int;
    width, height: int) {.inline.} =
        gl_copy_tex_image_2d(
            target.Glenum,
            level.Glint,
            internal_format,
            x.Glint,
            y.Glint,
            width.Glsizei,
            height.Glsizei,
            0)

proc copy_tex_sub_image_2d*(
    target: TargetTexture;
    level: int;
    xoffset, yoffset: int;
    x, y: int;
    width, height: int) {.inline.} =
        gl_copy_tex_sub_image_2d(
            target.Glenum,
            level.Glint,
            xoffset.Glint,
            yoffset.Glint,
            x.Glint,
            y.Glint,
            width.Glsizei,
            height.Glsizei)

proc `cull_face=`*(mode: CullMode) {.inline.} =
    ## Sets the policy on culling faces of polygons.
    gl_cull_face(mode.Glenum)

proc `depth_func=`*(mode: DepthFunction) {.inline.} =
    ## Sets the depth testing function.
    gldepthfunc(mode.Glenum)

proc `depth_mask=`*(mode: bool) {.inline.} =
    ## Sets if the depth buffer may be written to.
    gldepthmask(mode.Glboolean)

proc set_depth_mask*(near, far: float) {.inline.} =
    gldepthrangef(near.Glclampf, far.Glclampf)

proc set_attribute_enabled*(index: int; enabled: bool) {.inline.} =
    ## Sets whether a particular vertex attribute array will be enabled and usable by shaders.
    assert index >= 0
    if enabled:
        glenablevertexattribarray(index.Gluint)
    else:
        gldisablevertexattribarray(index.Gluint)

proc `[]=`*(self: type[attributes]; index: int; enabled: bool) {.inline.} =
    ## Allows you to enable or disable attribute arrays with such as
    ## Attributes[0] = true
    set_attribute_enabled(index, enabled)

proc attach*(self: RenderBuffer; point: RenderBufferAttachment) {.inline.} =
    ## Attaches a render buffer to the current framebuffer.
    glframebufferrenderbuffer(
        GL_FRAMEBUFFER, # GLES2 says it must be this
        point.Glenum,
        GL_RENDERBUFFER, # GLES2 says it must be this
        self.Gluint)

proc attach*(
    texture: Texture;
    attachment: RenderBufferAttachment;
    texure_target: TargetTexture;
    level: int) {.inline.} =
        ## Attaches a texture to the current framebuffer.
        glframebuffertexture2d(
                GL_FRAMEBUFFER, # GLES2 says it must be
                attachment.Glenum,
                texure_target.Glenum,
                texture.Gluint,
                level.Glint)

proc `front_face=`*(mode: FaceOrientation) {.inline.} =
    glfrontface(mode.Glenum)

proc scissor*(x, y, width, height: int) {.inline.} =
    glscissor(x.Glint, y.Glint, width.Glsizei, height.Glsizei)

proc set_stencil_func*(
    fun: DepthFunction;
    reference: int;
    mask: uint) {.inline.} =
        glstencilfunc(fun.Glenum, reference.Glint, mask.Gluint)

proc set_stencil_func*(
    face: CullMode;
    fun: DepthFunction;
    reference: int;
    mask: uint) {.inline.} =
        glstencilfuncseparate(
            face.Glenum,
            fun.Glenum,
            reference.Glint,
            mask.Gluint)

proc `stencil_mask=`*(mask: uint) {.inline.} =
    glstencilmask(mask.Gluint)

proc set_stencil_mask*(mask: uint) {.inline.} =
    glstencilmask(mask.Gluint)

proc set_stencil_mask*(face: CullMode; mask: uint) {.inline.} =
    glstencilmaskseparate(face.Glenum, mask.Gluint)

include gles2_gen

