defmodule DogAPI.Ptin do
  @moduledoc """
  PTIN Information and the Freedom of Information Act

  `https://www.irs.gov/tax-professionals/ptin-information-and-the-freedom-of-information-act`
  `https://www.irs.gov/pub/irs-utl/foia-extract.zip`
  `https://www.irs.gov/pub/irs-utl/foia-hawaii-extract.zip`

  ## Example.

  """

  alias NimbleCSV.RFC4180, as: CSV

  def download(file) do
    url = 'https://www.irs.gov/pub/irs-utl/#{file}'
    headers = []
    path_to_file =
      System.tmp_dir!()
      |> Path.join(file)
      |> String.to_charlist()

    http_request_opts = [
      ssl: [
      verify: :verify_peer,
      cacerts: :public_key.cacerts_get(),
      customize_hostname_check: [
        match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
    ]]]

    {:ok, :saved_to_file} =
      :httpc.request(:get, {url, headers}, http_request_opts, [stream: path_to_file])

    {:ok, data} = :file.read_file(path_to_file)

    case :zip.unzip(data, [{:cwd, ~c'/tmp/'}]) do
      {:ok, [content]} ->
        #parse(content)
        content
      {:error, error} ->
        error
    end
  end

  def proba(path) do
    header = [
      :last_name,
      :first_name,
      :middle_name,
      :suffix,
      :dba,
      :bus_addr_line1,
      :bus_addr_line2,
      :bus_addr_line3,
      :bus_addr_city,
      :bus_st_code,
      :bus_addr_zip,
      :bus_cntry_cde,
      :website,
      :bus_phne_nbr,
      :profession,
      :afsp_indicator
    ]

    none = [
      :middle_name,
      :suffix,
      :dba,
      :bus_addr_line1,
      :bus_addr_line2,
      :bus_addr_line3,
      :bus_addr_city,
      :bus_cntry_cde,
      :website,
      :bus_phne_nbr,
      :afsp_indicator
    ]

    path
    |> File.stream!()
    |> Stream.map(&String.downcase(&1))
    |> Stream.drop(1)
    |> Stream.map(&String.replace(&1, "\"", ""))
    |> Stream.map(&String.trim(&1, "\n"))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(&Stream.zip(header, &1))
    |> Stream.map(&(Map.new(&1)))
    |> Stream.map(&(Map.drop(&1, none)))
    |> Enum.take(3)
  end

  def parse(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.downcase(&1))
    |> CSV.parse_stream()
    |> Stream.map(fn [
      last_name,
      first_name,
      _middle_name,
      _suffix,
      _dba,
      _bus_addr_line1,
      _bus_addr_line2,
      _bus_addr_line3,
      _bus_addr_city,
      bus_st_code,
      bus_addr_zip,
      _bus_cntry_cde,
      _website,
      _bus_phne_nbr,
      profession,
      _afsp_indicator
    ] -> %{
      bus_addr_zip: bus_addr_zip,
      bus_st_code: bus_st_code,
      first_name: first_name,
      last_name: last_name,
      profession: String.upcase(profession)
    }
    end)
    |> Enum.to_list()
    |> Enum.take(3)
  end

  def parse!(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.downcase(&1))
    |> CSV.parse_stream(skip_headers: false)
    |> Stream.transform(nil, fn
      headers, nil -> {[], headers}
      row, headers -> {[Enum.zip(headers, row) |> Map.new()], headers}
    end)
    |> Enum.to_list()
    |> Enum.take(3)
  end
end
