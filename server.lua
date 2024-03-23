--Add serverside logic here!
--The event triggered by the client when they quit character creation is 'lbg-chardone', with the character table passed as an argument
RegisterServerEvent('lbg-chardone')
AddEventHandler('lbg-chardone', function(characterDetails, characterId, model)
    -- Extract keys and values
    local columns = {}
    local skinValues = {}
    local charValues = { model, characterId }

    -- Insert characterId at the beginning of skinValues
    table.insert(skinValues, 1, characterId) -- Note: We are adding it at the beginning.

    for k, v in pairs(characterDetails) do
        table.insert(columns, k)
        table.insert(skinValues, v)
    end

    -- Construct the SQL query for the INSERT part
    local insertPart = "INSERT INTO skins (characterId, " ..
        table.concat(columns, ", ") .. ") VALUES (?, " .. string.rep('?,', #columns - 1) .. "?)"

    -- Construct the SQL query for the ON DUPLICATE KEY UPDATE part
    local updateParts = {}
    for _, col in ipairs(columns) do
        table.insert(updateParts, col .. " = VALUES(" .. col .. ")")
    end
    local updatePart = "ON DUPLICATE KEY UPDATE " .. table.concat(updateParts, ", ")

    -- Combine the two parts
    local skinsSql = insertPart .. " " .. updatePart
    local characterSql = "UPDATE characters SET model = ? WHERE characterId = ?"

    -- Now you can use `sql` as your query string and `values` as your argument list in oxmysql.
    exports.oxmysql:execute(skinsSql, skinValues)
    exports.oxmysql:execute(characterSql, charValues)
end)
