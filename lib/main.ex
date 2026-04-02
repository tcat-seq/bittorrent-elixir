defmodule CLI do
  def main(argv) do
    case argv do
      ["decode" | [encoded_str | _]] ->
        # You can use print statements as follows for debugging, they'll be visible when running tests.
        IO.puts(:stderr, "Logs from your program will appear here!")

        # TODO: Uncomment the code below to pass the first stage
        decoded_str = Bencode.decode(encoded_str)
        IO.puts(Jason.encode!(decoded_str))

      [command | _] ->
        IO.puts("Unknown command: #{command}")
        System.halt(1)

      [] ->
        IO.puts("Usage: your_program.sh <command> <args>")
        System.halt(1)
    end
  end
end

defmodule Bencode do
  require Logger

  # def decode(encoded_value) when is_binary(encoded_value) do
  # def decode(encoded_value) do
  # Byte strings are formatted as <length>:<content>. To decode them,
  # first extract the length digits before the colon, then use that length
  # to capture the exact number of bytes.
  def decode(<<char, _::binary>> = encoded_value) when char in 48..57 do
    Logger.debug("Bencode.decode: encoded_value: #{encoded_value}")

    binary_data = :binary.bin_to_list(encoded_value)
    Logger.debug("Bencode.decode: binary_data: #{binary_data}")

    case Enum.find_index(binary_data, fn char -> char == 58 end) do
      nil ->
        IO.puts("The ':' character is not found in the binary")

      index ->
        # RAS: added "//1" to address the "warning: negative steps are not supported
        # in Enum.slice/2". This warning in Elixir v1.19.4 is part of a deprecation
        # process that began in a previous version. To fix this, we need to explicitly
        # use the first..last//step notation for ranges with negative steps instead
        # of implicitly relying on the function's internal handling"

        # rest = Enum.slice(binary_data, index+1..-1)
        rest = Enum.slice(binary_data, (index + 1)..-1//1)
        List.to_string(rest)
    end
  end

  # Integers in Bencode are formatted as i<number>e. Use binary pattern matching
  # to capture everything between "i" and "e".
  def decode(<<"i", rest::binary>>) do
    # extract until the "e" marker
    [int_str, remaining] = String.split(rest, "e", parts: 2)
    # Logger.debug("Bencode.decode: decoding integer: int: #{int_str}, remaining: #{remaining}")

    String.to_integer(int_str)
  end

  def decode(_), do: "Invalid encoded value: not binary"
end
