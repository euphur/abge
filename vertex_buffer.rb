VERTEX = 0
NORMAL = 1
TEX_COORD = 2

class VertexBuffer
  attr_reader :num_vtx
  
  def initialize data, num_vtx, type=VERTEX
    @num_vtx = num_vtx
    @id = glGenBuffers(1)[0]
    @type = type
    GL.BindBuffer(GL::ARRAY_BUFFER, @id)
    GL.BufferData(GL::ARRAY_BUFFER, data.size, data, GL::STATIC_DRAW)
    GL.BindBuffer(GL::ARRAY_BUFFER, 0)
  end
  
  # bind this buffer
  def use &block
    # GL::EnableVertexAttribArray(@id) # for shader
    case @type
    when VERTEX    then GL::EnableClientState(GL::VERTEX_ARRAY)
    when NORMAL    then GL::EnableClientState(GL::NORMAL_ARRAY)
    when TEX_COORD then GL::EnableClientState(GL::TEXTURE_COORD_ARRAY)
    end
    
    GL::BindBuffer(GL::ARRAY_BUFFER, @id)
    case @type
    when VERTEX    then GL::VertexPointer(3, GL::FLOAT, 0, 0)
    when NORMAL    then GL::NormalPointer(3, GL::FLOAT, 0, 0)
    when TEX_COORD then GL::TexCoordPointer(2, GL::FLOAT, 0, 0)
    end
    
    yield
    GL::BindBuffer(GL::ARRAY_BUFFER, 0)
    GL::DisableClientState(GL::VERTEX_ARRAY)
    # GL::DisableVertexAttribArray(@id) # for shader
  end
end
