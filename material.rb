class Material
  attr_reader :amb, :dif, :spe # float[0]
  attr_reader :shn             # 0..128
  attr_accessor :tex_path

  def initialize
    @amb = [0.2, 0.2, 0.2, 1.0]
    @dif = [0.8, 0.8, 0.8, 1.0]
    @spe = [0.0, 0.0, 0.0, 1.0]
    @shn = 0
  end
  def self.load filename
    MaterialFactory.new(filename).get
  end
  def use
    GL.Material(GL_FRONT_AND_BACK, GL_AMBIENT,   amb)
    GL.Material(GL_FRONT_AND_BACK, GL_DIFFUSE,   dif)
    GL.Material(GL_FRONT_AND_BACK, GL_SPECULAR,  spe)
    GL.Material(GL_FRONT_AND_BACK, GL_SHININESS, [shn])
  end
  def amb= color
    @amb = to_rgba(color)
  end
  def dif= color
    @dif = to_rgba(color)
  end
  def spe= color
    @spe = to_rgba(color)
  end
  def shn= value
    unless value.between?(1,128)
      raise ArgumentError, "Shiningness expected 1..128(Integer) but #{value}"
    end
    @shn = value
  end

  private
  def to_rgba color
    throw ArgumentError unless color.size.between?(3,4)
    rgba = color.map { |v| v.to_f }
    # append alpha value
    rgba << 1.0 if rgba.size == 3
    rgba
  end
end


class MaterialFactory
  def initialize filename
    @filename = filename
  end
  def get
    return @mtls if @mtls

    @mtls = {}
    mtl = nil
    
    File.read(@filename).each_line do |line|
      next if line =~ /^(#|\s*$)/ # skip comment and empty line
      next unless line.chomp =~ /^(.+?)\s+(.*)/
      cmd, args = $1, $2.split(' ')

      
      if cmd == 'newmtl'
        unless args[0]
          mtl = nil # skip unnamed material
        else
          mtl = @mtls[args[0]] = Material.new
        end
      end

      if mtl
        case cmd
        when 'Ns' then mtl.shn = args[0].to_i
        when 'Ka' then mtl.amb = args.map { |s| s.to_f }
        when 'Kd' then mtl.dif = args.map { |s| s.to_f }
        when 'Ks' then mtl.spe = args.map { |s| s.to_f }
        when 'map_Kd'
          require 'pathname'
          mtl.tex_path = Pathname.new(File.absolute_path(@filename)).dirname + args[0]
        end
      end
    end

    @mtls
  end
end
