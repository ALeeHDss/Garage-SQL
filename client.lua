-- Importar la biblioteca SQLite
local SQL = require('sqlite')

-- Conectar a la base de datos
local db = SQL.open('garage.db')

-- Crear una función para guardar el vehículo actual en el garaje
function SaveVehicle()
    -- Obtener el modelo y la placa del vehículo actual
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local model = GetEntityModel(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)

    -- Obtener la posición del vehículo
    local position = { x = GetEntityCoords(vehicle, true).x, y = GetEntityCoords(vehicle, true).y, z = GetEntityCoords(vehicle, true).z }

    -- Insertar la información en la base de datos
    db:exec('INSERT INTO garage (vehicle_model, vehicle_plate, position) VALUES (?, ?, ?)', model, plate, json.encode(position))

    -- Mostrar un mensaje en el chat
    TriggerEvent('chat:addMessage', { args = { 'Garage', 'Vehículo guardado exitosamente.' } })
end

-- Crear una función para spawnar un vehículo guardado en el garaje
function SpawnVehicle(id)
    -- Obtener la información del vehículo guardado desde la base de datos
    local result = db:query('SELECT * FROM garage WHERE id = ?', id)

    -- Si no se encontró ningún vehículo guardado, mostrar un mensaje en el chat
    if not result or #result == 0 then
        TriggerEvent('chat:addMessage', { args = { 'Garage', 'No se encontró ningún vehículo guardado con ese ID.' } })
        return
    end

    -- Crear un vehículo en la posición guardada
    local vehicle = CreateVehicle(result[1].vehicle_model, json.decode(result[1].position), GetEntityHeading(PlayerPedId()), true, false)
    SetVehicleNumberPlateText(vehicle, result[1].vehicle_plate)

    -- Mostrar un mensaje en el chat
    TriggerEvent('chat:addMessage', { args = { 'Garaje', 'Vehículo spawnado exitosamente.' } })
end

-- Asignar un botón para guardar el vehículo actual en el garaje
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(1, 38) then -- Presionar "E" para guardar el vehículo
            -- Verificar si el jugador está dentro de un vehículo
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if not DoesEntityExist(vehicle) then
                TriggerEvent('chat:addMessage', { args = { 'Garage', 'Debes estar dentro de un vehículo para guardarlo.' } })
                return
            end

            -- Verificar si el vehículo es propio
            if not IsVehicleModelInCdimage(GetEntityModel(vehicle)) then
                TriggerEvent('chat:addMessage', { args = { 'Garage', 'No puedes guardar un vehículo que no es tuyo.' } })
                return
            end

            -- Llamar a la función para guardar el vehículo
            SaveVehicle()
        end
    end
end)