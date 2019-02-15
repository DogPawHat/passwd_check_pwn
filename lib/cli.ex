defmodule CP.CLI do
    def main(args \\ []) do
        IO.puts("Reading file\n\n")
        {_a, paths, _invalid} = OptionParser.parse(args, strict: [])

        hd(paths)
        |> get_results
        |> Stream.filter(&get_bad_thing/1)
        |> return_results
    end

    defp get_bad_thing(result) do
        case result do
            {:ok, _value} -> false
            {:breach_found, _value} -> true
            {:wat, _value} -> true
        end
    end

    defp get_results(path) do
        path
        |> match_file
        |> CP.magic
    end

    defp return_results(_results = []) do
        IO.puts("OK: No breaches found")
    end

    defp return_results(results) do
        Enum.map(results, &return_result/1)
    end

    defp return_result(result) do
        case result do
            {:ok, value} -> IO.puts("OK: No breach for #{value[:url]}")
            {:breach_found, value} -> IO.puts("WARNING: Breach of #{value[:username]} found for #{value[:url]}")
            {:wat, value} -> IO.puts("WAT: Wat of #{value[:username]} found for #{value[:url]}")
        end
    end

    defp match_file(path) do
        expand_path(path)
        |> File.stream!
        |> CSV.decode
    end

    defp expand_path(path) do
        Path.expand("./#{path}")
    end
end