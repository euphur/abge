class Model
  def initialize
    @batches = []
  end
  def << batch
    @batches << batch
  end
  def self.load filename
    ModelFactory.new(filename).get
  end
  def draw
    @batches.each do |batch|
      batch.draw
    end
  end
end


class ModelFactory
  def initialize filename
    @filename = filename
  end
  def get
    return @model if @model

    batches = []
    batch = nil
    materials = nil
    v, vn, vt = [], [], []

    File.read(@filename).each_line do |line|
      next if line =~ /^(#|\s*$)/ # skip comment and empty line
      next unless line.chomp =~ /^(.+?)\s+(.*)/
      cmd, args = $1, $2.split(' ')

      case cmd
      when 'v'  then v  << args.map {|s| s.to_f}
      when 'vn' then vn << args.map {|s| s.to_f}
      when 'vt' then vt << args.map {|s| s.to_f}
      when 'f'
        # divide quadrangle to two triangles
        args = args[0..2] + args[2..3] + args[0,1] if args.size == 4

        args.each do |s|
          v_idx, vt_idx, vn_idx =
            s.split('/').map {|s| s.empty? ? nil : s.to_i-1}

          batch.v  += v [v_idx]
          batch.vt += vt[vt_idx] if vt_idx
          batch.vn += vn[vn_idx] if vn_idx
        end
      when 'g'
      when 'usemtl'
        batches << Batch.new
        batch = batches.last

        batch.material = materials[args[0]]
        require 'pp'
        pp materials[args[0]]

        if batch.material and batch.material.tex_path
          tex = SDL::Surface.load(batch.material.tex_path.to_s)

          # to texture class
          batch.material.tex_path = @tex_name = glGenTextures(1)[0]
          glBindTexture(GL_TEXTURE_2D, @tex_name)

          glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
          # glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

          glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT )
          glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT )

          GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGBA, tex.w, tex.h, 0, GL::RGBA,
                        GL::UNSIGNED_BYTE, tex.pixels)
        end
      when 'mtllib'
        require 'pathname'
        mtl_filename = Pathname.new(File.absolute_path(@filename)).dirname + args[0]
        materials = Material.load(mtl_filename)
      end
    end

    @model = Model.new
    batches.each do |batch|
      batch.compile
      @model << batch
    end
    
    @model    
  end
end
