class Batch
  attr_accessor :v, :vn, :vt
  attr_accessor :material
  
  def initialize
    @v, @vn, @vt = [], [], []

    @mtl = Material.new
    @mtl.dif = [0,1,0]
  end
  def compile
    @num_vtx = @v.size/3
    size = @num_vtx * 4

    @v = @v .pack('f*')
    
    @buffers = {}
    @buffers[:vertex]  = VertexBuffer.new(@v, @num_vtx)
    @buffers[:tex_coord] = VertexBuffer.new(@vt.pack('f*'), @num_vtx, TEX_COORD) unless @vt.empty?
  end
  def draw
    # @buffers.each do |name, buffer|
    #   buffer.use { Shader.current.set_attr_ptr!(name, nil) }
    # end

    # cannot use for glDrawArrays
    @material.use if @material

    if material and material.tex_path
      glBindTexture(GL_TEXTURE_2D, material.tex_path)
      glEnable(GL_TEXTURE_2D)
      glEnable(GL_NORMALIZE)
    end

    
    
    if @buffers[:tex_coord]
      @buffers[:tex_coord].use do
        @buffers[:vertex].use do
          GL.DrawArrays(GL::TRIANGLES, 0, @num_vtx)
        end
      end
    else
      @buffers[:vertex].use do
        GL.DrawArrays(GL::TRIANGLES, 0, @num_vtx)
      end
    end
    

    if material and material.tex_path
      glDisable(GL_TEXTURE_2D)
      glDisable(GL_NORMALIZE)
    end
    
  end
end
