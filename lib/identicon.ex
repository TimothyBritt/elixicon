defmodule Identicon do
  @moduledoc """
    Generates identicon avatars from custom strings.
  """

  def main(string) do
    string
    |> Identicon.generate_image
    |> Identicon.pick_color
    |> Identicon.build_grid
  end

  @doc """
    Returns a Base 16 encoded string of the MD5 hashed string argument.

  ## Examples
      iex> Identicon.string_signature("Timothy")
      "82052CD94092C364FF8C58E83C220605"
  """
  def string_signature(string) do
    :crypto.hash(:md5, string)
    |> Base.encode16
  end

  @doc """
    Converts `string` to a list of `byte()s`, each representing the value of one byte.

  ##Examples
      iex> Identicon.bytes_list("Timothy")
      [130, 5, 44, 217, 64, 146, 195, 100, 255, 140, 88, 232, 60, 34, 6, 5]
  """
  def bytes_list(string) do
    :crypto.hash(:md5, string)
    |> :binary.bin_to_list
  end

  def generate_image(string) do
    hex = string
    |> Identicon.bytes_list

    %Identicon.Image{hex: hex}
  end

  def pick_color(%Identicon.Image{hex: [ r, g, b | _tail ]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex_list} = image) do
    grid =
      hex_list
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index
      %Identicon.Image{image | grid: grid}
  end

  def mirror_row([a, b, c]) do
    [a, b, c, b, a]
  end
end
