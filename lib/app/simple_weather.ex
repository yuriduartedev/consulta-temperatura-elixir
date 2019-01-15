defmodule App.SimpleWeather do
  def start(cities) do
    cities #-> Recebe uma lista de cidades
    |> Enum.map(&create_task/1) #-> Cria uma Task para cada uma delas
    |> Enum.map(&Task.await/1) #-> Processa a resposta de cada Task
  end

  defp create_task(city) do
    #-> Cria uma Task com a temperatura da cidade informada
    Task.async(fn -> temperature_of(city) end)
  end

  #-> Restante do código permanece o mesmo

  defp temperature_of(location) do
    result = get_endpoint(location) |> HTTPoison.get |> parser_response
    case result do
      {:ok, temp} ->
        "#{location}: #{temp} °C"
      :error ->
        "#{location} not found"
    end
  end

  def get_endpoint(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{get_appid()}"
  end

  def get_appid do
    "ff8b367acdfe54bb2280634e476722f0"
  end

  defp parser_response({:ok, %HTTPoison.Response{body: body,status_code: 200}}) do
    body |> JSON.decode! |> compute_temperature
  end

  defp parser_response(_), do: :error

  defp compute_temperature(json) do
    try do
      temp = json["main"]["temp"] |> kelvin_to_celsius
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  defp kelvin_to_celsius(kelvin) do
    (kelvin - 273.15) |> Float.round(1)
  end

end
