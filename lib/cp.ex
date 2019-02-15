defmodule CP do
  @moduledoc """
  Documentation for CP.
  """

  @doc """
  Hello world.

  ## Examples

      iex> CP.hello()
      :world

  """
  @header ["url", "username", "password", "extra", "name", "grouping", "fav"]

  def magic(pw_stream) do
    pw_stream
    |> Stream.filter(&is_good_time?/1)
    |> Stream.map(&convert_to_map/1)
    |> check_pws
  end

  defp is_good_time?(tup) do
    {:ok, value} = tup
    value && @header !== value
  end

  defp convert_to_map(tup) do
    {:ok, [url, username, password, _extra, _name, _grouping, _fav]} = tup
    
    hashed_pw = hash_pw(password)
    {hashed_pfx, hashed_sfx} = String.split_at(hashed_pw, 5)

    %{
      :url => url,
      :username => username,
      :hashed_pw => hashed_pw,
      :hashed_pfx => hashed_pfx,
      :hashed_sfx => hashed_sfx
    }
  end

  defp check_pws(stream_of_pws) do
    Stream.map(stream_of_pws, &check_pw/1)
  end

  defp check_pw(pw_map) do
    %{:hashed_sfx => sfx, :hashed_pfx => pfx} = pw_map
    check_resp = &(String.contains?(&1, sfx))
    

    check_pw_api(pfx).body
    |> String.split
    |> Enum.filter(check_resp)
    |> length
    |> case do
      1 -> {:breach_found, pw_map}
      0 -> {:ok, pw_map}
      # So... there are two SHA hashs in the Pwned Passwords API
      _ -> {:wat, pw_map}
    end
  end

  defp check_pw_api(hashed_short) do
    HTTPoison.get!('https://api.pwnedpasswords.com/range/#{hashed_short}')
  end

  defp hash_pw(pw) do
    :crypto.hash(:sha, pw) |> Base.encode16
  end
end
