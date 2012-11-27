class Application
  def initialize args
    SDL.init(SDL::INIT_VIDEO)
    SDL::GL.set_attr(SDL::GL::DOUBLEBUFFER, 1)
    SDL.setVideoMode(args[:width], args[:height], 32, SDL::OPENGL)
    SDL::WM.set_caption(args[:title], '')
  end
  def run
    loop do
      while event = SDL::Event.poll
        case event
        when SDL::Event2::KeyDown, SDL::Event2::Quit
          exit
        end
      end
      
      redraw
      sleep 0.01
    end
  end
  
  private
  def redraw
    draw
    SDL::GL.swap_buffers
  end
end

class CoordinateSpace
  def initialize
    @children = []
  end
  def << child
    @children << child
    self
  end
  def draw
    @children.each { |c| c.draw }
  end
end
