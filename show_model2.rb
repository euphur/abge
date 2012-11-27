# -*- coding: utf-8 -*-
require 'opengl'
require 'sdl'
require './sgl.rb'


class ShowModel < Application
  def initialize
    super(width:800, height:600, title:'Model Sample')
    
    @world = CoordinateSpace.new
    # @world << Model.load('../models/beach_ball.obj')
    @world << Model.load('../models/reversi_board.obj')

    # Shader.map_attrs(vertex:'vVertex')
    # @shader = Shader.new({ file:'simple.vert'}, {file:'simple.frag'})
    
    # @world << Model.load('board.obj') << Model.load('pawn.obj')

    def to_triangle(a,b,c,d)
      a+b+c + a+c+d
    end
    
    data = to_triangle([0,0,0], [0,1,0], [1,1,0], [1,0,0]).pack("f*")
    @vb = VertexBuffer.new(data, 4)

    # v = []
    # v << [-0.5, -0.5,  0.5]
    # v << [ 0.5, -0.5,  0.5]
    # v << [ 0.5,  0.5,  0.5]
    # v << [-0.5,  0.5,  0.5]
    # v << [ 0.5, -0.5, -0.5]
    # v << [-0.5, -0.5, -0.5]
    # v << [-0.5,  0.5, -0.5]
    # v << [ 0.5,  0.5, -0.5]

    # v2 = []
    # v2 += to_triangle(v[0], v[1], v[2], v[3])
    # v2 += to_triangle(v[4], v[5], v[6], v[7])
    # v2 += to_triangle(v[1], v[4], v[7], v[2])
    # v2 += to_triangle(v[5], v[0], v[3], v[6])
    # v2 += to_triangle(v[3], v[2], v[7], v[6])
    # v2 += to_triangle(v[1], v[0], v[5], v[4])
  end
  def draw
    glViewport(0, 0, 800, 600);
 
    glMatrixMode (GL_PROJECTION);
    glLoadIdentity
    gluPerspective(70.0, 800.0/600, 1.0, 100.0);
    
    GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
    GL.MatrixMode(GL::MODELVIEW)
    GL.LoadIdentity

    GL.Enable(GL::DEPTH_TEST)
    

    GL.Translate(0, -5, -10)
    # GL.Color(255,0,0)

    @world.draw

    # @vb.use do
    #   GL.DrawArrays(GL::TRIANGLES, 0, @vb.num_vtx)
    # end
  end
end


ShowModel.new.run
