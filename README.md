# Elixicon
### Easy Breezy Github-Style Default User Icons!

Elixicon allows you to quickly and easily generate default user identity avatar/icons similar to the default avatars you find on Github. You can generate these avatars randomly, or pass a string to derive the avatar image from it.

## Installation

The package can be installed in your Elixir project by adding `elixicon` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elixicon, "~> 0.1.0"}
  ]
end
```

### Try It In the Shell for Hacking and Profit

Alternatively, if you'd like to tinker with the tool in the shell, you can close this repository:

```shell
  git clone https://github.com/TimothyBritt/elixicon.git
  cd elixicon
```

Then fire up an `iex` repl with the library using:

```shell
  iex -S mix
```

## Usage

Generate a random Elixicon with `Elixicon.generate/0`:

```elixir
  Elixicon.generate
```

This will save your Elixicon to the filesystem. Most of the time you will probably prefer to have a more portable image, so you can also generate a random Base64 URL Elixicon `Elixicon.generate_base64/0`:

```elixir
  Elixicon.generate_base64
```

Both of these functions use a randomly generated string to derive the Elixicon from. But, you can also pass a string, if you'd like to have a more predictable way to generate the images using `generate/1` and `generate_base64/1`:

```elixir
  Elixicon.generate("Timothy")
  Elixicon.generate_base64("Timothy")
```

## Enjoy

You will have beautiful default user avatar icons that users will love!

## Contribute

Have some ideas? Feedback? Something broken? No workie?

If you have a question, please create an issue and I'll have a look ASAP.
If you'd like to contribute, please feel free to fork the project, make some changes and create a pull request. Please ensure that you are following some basic guidelines:

* Write tests. The code is well-covered and there are plenty of examples.
* Write documentation. The project uses [ExDoc](https://github.com/elixir-lang/ex_doc) to automate the generation of documentation.
* Write examples and DocTests.
* Keep it clean.
