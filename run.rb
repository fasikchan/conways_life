require 'tty-screen'

class Main

  def initialize
    @config = {
      screen_size: TTY::Screen.size,
      fps: 5
    }
  end

  def execute
    game = Game.new(@config)
    game.execute
  end

end

class Game

  attr_reader :screen_y, :screen_x, :field, :cell_symbol, :empty_symbol, :fps

  def initialize(config)
    @fps      = config[:fps]
    @screen_y = config[:screen_size][0] - 1
    @screen_x = config[:screen_size][1] / 2

    @field = Field.new(screen_y, screen_x)
    @cell_symbol  = '*'
    @empty_symbol = ' '
  end

  def execute
    100000.times do
      frame = Frame.new(self)
      frame.calculate
      frame.render
    end
  end

end

class Frame

  def initialize(game)
    @y     = game.screen_y
    @x     = game.screen_x
    @fps   = game.fps
    @field = game.field

    @cell_symbol  = game.cell_symbol
    @empty_symbol = game.empty_symbol

    @screen = Array.new(@y){ Array.new(@x) { @empty_symbol } }
  end

  def calculate
    @field.data.each do |cells|
      cells.each do |cell|
        lived_neighbors = 0

        cell.cells_around.each do |coordinates|
          y = coordinates[0]
          x = coordinates[1]

          next if y > (@y - 1)
          next if x > (@x - 1)

          next if y < 0
          next if x < 0

          neighbor = @field.data[y][x]

          lived_neighbors += 1 if neighbor.alive?
        end

        if lived_neighbors == 3
          cell.born!
        end

        if lived_neighbors < 2 || lived_neighbors > 3
          cell.die!
        end

        if cell.alive?
          @screen[cell.y][cell.x] = @cell_symbol
        else
          @screen[cell.y][cell.x] = @empty_symbol
        end
      end
    end
  end

  def render
    rendering_started_at = Time.now

    filled_screen_map = @screen.map{ |row| row.join(' ') }
    puts filled_screen_map
    rendering_ended_at = Time.now

    difference = rendering_ended_at - rendering_started_at

    sleep ((1 - difference) / @fps)
  end


end

class Field

  attr_reader :data

  def initialize(height, width)
    @height = height
    @width  = width

    @data = Array.new(height) { Array.new(width) }
    @data.map!.with_index do |cells, x|
      cells.map!.with_index do |_, y|
        cell = Cell.new(x, y)
        cell
      end
    end
  end

end

class Cell

  attr_reader :y, :x, :status

  def initialize(y, x)
    @y  = y
    @x  = x

    @status = (rand(1..100) > 90 ? :alive : :dead)
  end

  def die!
    @status = :dead
    nil
  end

  def born!
    @status = :alive
    nil
  end

  def alive?
    status == :alive
  end

  def dead?
    status == :dead
  end

  def cells_around
    [
      [y-1,x-1],
      [y-1,x  ],
      [y-1,x+1],
      [y  ,x-1],
      [y  ,x+1],
      [y+1,x-1],
      [y+1,x  ],
      [y+1,x+1]
    ]
  end

end

Main.new.execute