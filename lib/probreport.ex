defmodule Probreport do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Probreport.Worker.start_link(arg1, arg2, arg3)
      # worker(Probreport.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Probreport.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defstruct length: nil,
            mean: nil,
            std_dev: nil,
            # maps like %{0.9 => x, 0.95 => y, 0.99 => z}
            conf_half_ranges: %{},
            conf_min: %{},
            conf_max: %{}

  def make_verbose_row(lst, odd, conf_precents) do
    make_raw(lst, conf_precents)
    |> Map.from_struct
    |> Enum.reduce(%{}, fn({key,value}, acc = %{}) ->
      case is_map(value) do
        true -> Enum.reduce(value, acc, fn({percent, value}, acc = %{}) -> Map.put(acc, make_verbose_header(key, percent), prettify_values(value)) end)
        false -> Map.put(acc, make_verbose_header(key), prettify_values(value))
      end
    end)
    |> Map.put(make_verbose_header(:odd), odd)
  end

  def make_csv_header(conf_precents) do
    Enum.map([:odd, :length, :mean, :std_dev], &make_verbose_header/1)
    ++
    Enum.map(conf_precents, &(make_verbose_header(:conf_half_ranges, &1)))
    ++
    Enum.flat_map(conf_precents, fn(percent) -> Enum.map([:conf_min, :conf_max], &(make_verbose_header(&1, percent))) end)
  end

  defp prettify_values(some), do: Maybe.maybe_to_string(some, %Maybe{decimals: 9})

  defp make_verbose_header(:odd), do: "Game Name"
  defp make_verbose_header(:length), do: "Total Spins"
  defp make_verbose_header(:mean), do: "Observed RTP"
  defp make_verbose_header(:std_dev), do: "True Standard Deviation"
  defp make_verbose_header(:conf_half_ranges, percent), do: "#{ round(percent * 100) }% Confidence Range"
  defp make_verbose_header(:conf_min, percent), do: "#{ round(percent * 100) }% Confidence Min"
  defp make_verbose_header(:conf_max, percent), do: "#{ round(percent * 100) }% Confidence Max"

  defp make_raw(lst = [_|_], conf_precents) when is_list(conf_precents) do
    acc = %Probreport{
      length: length(lst),
      mean: Statistics.mean(lst),
      std_dev: Statistics.stdev(lst),
    }
    Enum.reduce(conf_precents, acc, fn(percent, acc = %Probreport{length: lstlen, mean: mean, std_dev: std_dev, conf_half_ranges: conf_half_ranges = %{}, conf_min: conf_min = %{}, conf_max: conf_max = %{}}) ->
      percent = Maybe.to_float(percent)
      true = is_float(percent) and (percent > 0) and (percent < 1)
      delta = :erlmath.qnorm_nif(percent + ((1 - percent) / 2)) * (std_dev / Statistics.Math.sqrt(lstlen))
      %Probreport{acc | conf_half_ranges: Map.put(conf_half_ranges, percent, delta), conf_min: Map.put(conf_min, percent, (mean - delta)), conf_max: Map.put(conf_max, percent, (mean + delta))}
    end)
  end

end
