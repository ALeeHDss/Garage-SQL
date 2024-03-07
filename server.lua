-- Importar la biblioteca SQLite
local SQL = require('sqlite')

-- Conectar a la base de datos
local db = SQL.open('garage.db')

-- Crear un evento para spawnar un vehículo guardado en el garaje
RegisterNetEvent('garage:spawnVehicle')
AddEventHandler('garage:spawnVehicle', function(id)
    -- Verific