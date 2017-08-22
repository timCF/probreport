defmodule Probreport.Keno2 do
  @percents [0.9, 0.95, 0.99]
  @balls Exkeno.Keno.Classic2.balls
  @winlen Exkeno.Keno.Classic2.winlen
  @bet_sizes Exkeno.Keno.Classic2.paytable |> Map.keys |> Enum.sort
  @csv_header Probreport.make_csv_header(@percents)
  def generate do
    rounds = Enum.map(1..1_000_000, fn(_) -> Erlng.shuffle(@balls) |> Enum.take(@winlen) end)
    Enum.map(@bet_sizes, fn(size) ->
      bet = Erlng.shuffle(@balls) |> Enum.take(size)
      Enum.map(rounds, &(Exkeno.Keno.Classic2.win(bet, &1)))
      |> Probreport.make_verbose_row("Keno-2 pick #{ size }", @percents)
    end)
    |> Csvex.encode(%{keys: @csv_header})
    |> (fn(data) -> File.write!("./keno_2_rtp.csv", data) end).()
  end
end
