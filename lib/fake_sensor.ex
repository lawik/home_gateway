defmodule FakeSensor do
    use GenServer
    alias MySensors.{Broadcast, SensorValue}

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do
        schedule_data()
        {:ok, nil}
    end

    def handle_info(:work, nil) do
        sensor_value = %SensorValue{
            type: "temperature",
            value: 5.0 + :rand.uniform(),
            inserted_at: DateTime.utc_now(),
            updated_at: DateTime.utc_now()
        }
        IO.inspect(sensor_value)
        dispatch(sensor_value, :insert_or_update)
        schedule_data()
        {:noreply, nil}
    end

    defp schedule_data() do
        Process.send_after(self(), :work, 2000)
    end

    defp dispatch(data, kind) do
        Broadcast.dispatch({kind, data})
        data
    end
end