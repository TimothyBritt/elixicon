defmodule Elixicon do
  require Integer

  @moduledoc """
    Generates custom github-style identicon avatar images from strings
  """

  def generate do
    Elixicon.random_string
    |> Elixicon.build_image_struct
  end

  def generate(string) do
    string
    |> Elixicon.build_image_struct
  end

  def build_image_struct(string) do
    string
    |> Elixicon.initialize_image_struct
    |> Elixicon.pick_rgb
    |> Elixicon.construct_grid
    |> Elixicon.filter_odd_cells
    |> Elixicon.build_pixel_map
  end

  @doc """
    Generates and returns a random string of 7 characters in length

  ## Examples
      iex> Elixicon.random_string |> String.length
      7
  """
  def random_string do
    :crypto.strong_rand_bytes(7)
    |> Base.url_encode64
    |> binary_part(0, 7)
  end

  @doc """
    Converts `string` to a list of `byte()s`, each representing the value of one byte.

  ## Examples
      iex> Identicon.bytes_list("Timothy")
      [130, 5, 44, 217, 64, 146, 195, 100, 255, 140, 88, 232, 60, 34, 6, 5]
  """
  @spec bytes_list(String.t) :: list
  def bytes_list(string) do
    :crypto.hash(:md5, string)
    |> :binary.bin_to_list
  end

  @doc """
    Processes a `string` and returns a `struct` of type `%Identicon.Image{hex: hex_list}`

  ## Examples

      iex> Elixicon.initialize_image_struct("Timothy")
      %Elixicon.Image{color: nil, grid: nil, hex: [130, 5, 44, 217, 64, 146, 195, 100, 255, 140, 88, 232, 60, 34, 6, 5], pixel_map: nil}
  """
  @spec initialize_image_struct(String.t) :: %Elixicon.Image{hex: list}

  def initialize_image_struct(string) do
    hex = string
    |> Elixicon.bytes_list

    %Elixicon.Image{hex: hex}
  end

  @doc """
    Picks the RGB fill color for the `%Elixicon.Image{}` from the first three hex values in the `hex` list. Returns a new `%Identicon.Image{}` with `color` set to a tuple.

  ## Examples

      iex> Elixicon.initialize_image_struct("Timothy") |> Elixicon.pick_rgb
      %Elixicon.Image{color: {130, 5, 44}, grid: nil, hex: [130, 5, 44, 217, 64, 146, 195, 100, 255, 140, 88, 232, 60, 34, 6, 5], pixel_map: nil}
  """

  @spec pick_rgb(%Elixicon.Image{hex: list}) :: %Elixicon.Image{hex: list, color: tuple}

  def pick_rgb(%Elixicon.Image{hex: [ r, g, b | _tail ]} = image) do
    %Elixicon.Image{image | color: {r, g, b}}
  end

  def mirror_row([a, b, c]) do
    [a, b, c, b, a]
  end

  @doc """
    Constructs the 5x5 pixel art grid by chunking the `hex_list` into groups of 3 values, then mirroring the values to be rendered along the vertical axis. Returns a new `%Identicon.Image{}` with `grid` set to a list of tuples with value/index pairs.

  ## Examples

      iex> Elixicon.initialize_image_struct("Timothy") |> Elixicon.pick_rgb |> Elixicon.construct_grid
      %Elixicon.Image{
      color: {130, 5, 44},
      grid: [
      {130, 0}, {5, 1}, {44, 2}, {5, 3}, {130, 4},
      {217, 5}, {64, 6}, {146, 7}, {64, 8}, {217, 9},
      {195, 10}, {100, 11}, {255, 12}, {100, 13}, {195, 14},
      {140, 15}, {88, 16}, {232, 17}, {88, 18}, {140, 19},
      {60, 20}, {34, 21}, {6, 22}, {34, 23}, {60, 24}
      ],
      hex: [130, 5, 44, 217, 64, 146, 195, 100, 255, 140, 88, 232, 60, 34, 6, 5],
      pixel_map: nil
      }
  """

  @spec construct_grid(%Elixicon.Image{hex: list, color: tuple}) :: %Elixicon.Image{hex: list, color: tuple, grid: list}

  def construct_grid(%Elixicon.Image{hex: hex_list} = image) do
    grid =
      hex_list
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index
      %Elixicon.Image{image | grid: grid}
  end

  @doc """
    Filters the blank cells from the grid, leaving only the cells to be filled with the `color` rgb value. Cells with odd values are to be left blank. Returns a new `%Identicon.Image{}` with the filtered `grid`.

  ## Examples

      iex> Elixicon.initialize_image_struct("Timothy") |> Elixicon.pick_rgb |> Elixicon.construct_grid |> Elixicon.filter_odd_cells
      %Elixicon.Image{color: {130, 5, 44}, grid: [{130, 0}, {44, 2}, {130, 4}, {64, 6}, {146, 7}, {64, 8}, {100, 11}, {100, 13}, {140, 15}, {88, 16}, {232, 17}, {88, 18}, {140, 19}, {60, 20}, {34, 21}, {6, 22}, {34, 23}, {60, 24}], hex: [130, 5, 44, 217, 64, 146, 195, 100, 255, 140, 88, 232, 60, 34, 6, 5], pixel_map: nil}
  """

  @spec filter_odd_cells(%Elixicon.Image{hex: list, color: tuple, grid: list}) :: %Elixicon.Image{hex: list, color: tuple, grid: list}

  def filter_odd_cells(%Elixicon.Image{grid: grid} = image) do
    filtered =
      grid
      |> Enum.filter(fn({value, _index}) -> Integer.is_even(value) end )

    %Elixicon.Image{image | grid: filtered}
  end

  @doc """
    Generates the boundaries of each rectangle to be filled on the image canvas. Returns a new `%Identicon.Image{}` with the `pixel_map` as a list of tuples each containing a pair of tuples representing the top left and bottom right coordinates of each rectangle on the canvas. These values will be used by the `:egd` library to draw each cell.

  ## Examples

      iex> Elixicon.initialize_image_struct("Timothy") |> Elixicon.pick_rgb |> Elixicon.construct_grid |> Elixicon.filter_odd_cells |> Elixicon.build_pixel_map
      %Elixicon.Image{color: {130, 5, 44}, grid: [{130, 0}, {44, 2}, {130, 4}, {64, 6}, {146, 7}, {64, 8}, {100, 11}, {100, 13}, {140, 15}, {88, 16}, {232, 17}, {88, 18}, {140, 19}, {60, 20}, {34, 21}, {6, 22}, {34, 23}, {60, 24}], hex: [130, 5, 44, 217, 64, 146, 195, 100, 255, 140, 88, 232, 60, 34, 6, 5], pixel_map: [{{0, 0}, {50, 50}}, {{100, 0}, {150, 50}}, {{200, 0}, {250, 50}}, {{50, 50}, {100, 100}}, {{100, 50}, {150, 100}}, {{150, 50}, {200, 100}}, {{50, 100}, {100, 150}}, {{150, 100}, {200, 150}}, {{0, 150}, {50, 200}}, {{50, 150}, {100, 200}}, {{100, 150}, {150, 200}}, {{150, 150}, {200, 200}}, {{200, 150}, {250, 200}}, {{0, 200}, {50, 250}}, {{50, 200}, {100, 250}}, {{100, 200}, {150, 250}}, {{150, 200}, {200, 250}}, {{200, 200}, {250, 250}}]}
  """

  @spec build_pixel_map(%Elixicon.Image{hex: list, color: tuple, grid: list}) :: %Elixicon.Image{hex: list, color: tuple, grid: list, pixel_map: list}

  def build_pixel_map(%Elixicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_value, index}) ->
      top_x = rem(index, 5) * 50
      top_y = div(index, 5) * 50
      top_left = {top_x, top_y}
      bottom_right = {top_x + 50, top_y + 50}

      {top_left, bottom_right}
    end

    %Elixicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
    Uses `:egd` to render the final Elixicon for preflight processing. Returns a binary of the image.

    Note: Since the binary is too lengthy for documentation, find the assertions for this function in the `test/elixicon_test.exs` file.
  """

  @spec render_image(%Elixicon.Image{hex: list, color: tuple, grid: list, pixel_map: list}) :: binary

  def render_image(%Elixicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

end
