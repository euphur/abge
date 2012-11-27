class Shader
  ShaderSetupError = Class.new(StandardError)

  @@current = nil
  def self.current
    @@current
  end
  
  private
  def self.current= shader
    @@current = shader
  end
  public

  def self.map_attrs hash
    @@general_attrs = hash
  end
  
  def initialize vs, fs
    vs_str = vs[:string]
    vs_str ||= vs[:file] && File.read(vs[:file])
    fs_str = fs[:string]
    fs_str ||= fs[:file] && File.read(fs[:file])

    raise ArgumentError unless vs_str and fs_str
    
    @program = init_program(vs_str, fs_str)
    @attrs = init_attributes
    @unifs = init_uniforms

    yield self if block_given?
  end

  def use &block
    Shader.current = self
    glUseProgram @program
    
    yield self
    
    glUseProgram 0
    Shader.current = nil
  end

  private
  def get_attr name
    if n = @@general_attrs[name]
      @attrs[n]
    else
      @attrs[name]
    end
  end
  public
  
  def set_attr name, value
    attr = get_attr(name)
    raise ArgumentError, "undefined attribute name: '#{name}'" unless attr
    glVertexAttrib3f(attr[:loc], *value)
  end
  
  def set_attr_ptr name, data
    raise ArgumentError, "undefined attribute name: '#{name}'"  unless attr = get_attr(name)
    glEnableVertexAttribArray(attr[:loc])
    glVertexAttribPointer(attr[:loc], 3, GL_FLOAT, false, 0, data)
  end

  # not raise exception when the attribute not found
  def set_attr_ptr! name, data
    return unless attr = get_attr(name)
    glEnableVertexAttribArray(attr[:loc])
    glVertexAttribPointer(attr[:loc], 3, GL_FLOAT, false, 0, data)
  end

  def uniform hash
    hash.each do |name, value|
      set_uniform(name, value)
    end
  end
  
  def set_uniform name, value
    unif = @unifs[name]
    raise ArgumentError, "undefined uniform name: '#{name}'" unless unif
    
    case unif[:type]
    when GL_FLOAT
      glUniform1f(unif[:loc], value)
    when GL_FLOAT_VEC3
      glUniform3fv(unif[:loc], value)
    when GL_FLOAT_VEC4
      glUniform4fv(unif[:loc], value)
    when GL_FLOAT_MAT3
      glUniformMatrix3fv(unif[:loc], false, value)
    when GL_FLOAT_MAT4
      glUniformMatrix4fv(unif[:loc], false, value)
    else
      raise NotImplemented, "Uniform data type #{unif[:type]}"
    end
    unif[:set] = true
  end
  
  private
  
  def raise_with_log obj, name
    raise ShaderSetupError, "\n#{name} error\n"+('-'*50)+"\n"+glGetShaderInfoLog(obj)+('-'*50)
  end

  def init_program vs_str, fs_str
    vs = glCreateShader(GL_VERTEX_SHADER)
    fs = glCreateShader(GL_FRAGMENT_SHADER)

    glShaderSource(vs, vs_str)
    glShaderSource(fs, fs_str)

    glCompileShader(vs)
    raise_with_log(vs, 'vertex shader'  ) unless glGetShaderiv(vs, GL_COMPILE_STATUS)
    glCompileShader(fs)
    raise_with_log(fs, 'fragment shader') unless glGetShaderiv(fs, GL_COMPILE_STATUS)

    program = glCreateProgram
    glAttachShader(program, vs)
    glAttachShader(program, fs)

    glLinkProgram(program)
    glDeleteShader(vs)
    glDeleteShader(fs)
    
    raise_with_log(program, "link") unless glGetProgramiv(program, GL_LINK_STATUS)
    
    program
  end

  def init_attributes
    attrs = {}
    glGetProgramiv(@program, GL_ACTIVE_ATTRIBUTES).times do |i|
      attr = glGetActiveAttrib(@program, i)
      name = attr[2].unpack('Z*')[0] # Ruby string from null-terminated string
      loc = glGetAttribLocation(@program, name)
      attrs[name] = { size:attr[0], type:attr[1], loc:loc }
    end
    attrs
  end

  def init_uniforms
    unifs = {}
    glGetProgramiv(@program, GL_ACTIVE_UNIFORMS).times do |i|
      unif = glGetActiveUniform(@program, i)
      name = unif[2].unpack('Z*')[0] # Ruby string from null-terminated string
      loc = glGetUniformLocation(@program, name)
      unifs[name] = { size:unif[0], type:unif[1], loc:loc }
    end
    unifs
  end
  
end
