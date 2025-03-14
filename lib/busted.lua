
-- Implémentation simplifiée de busted pour Lua/LÖVE
-- Ceci est une version minimale pour faire fonctionner les tests

local busted = {}

-- Collection de tests
local tests = {}
local currentDescribe = nil
local failures = {}
local successes = 0
local pendingCount = 0
local stats = { assertions = 0 }

-- API principale de busted
function busted.describe(description, callback)
    local oldDescribe = currentDescribe
    currentDescribe = {
        description = description,
        tests = {},
        before_each = nil
    }
    table.insert(tests, currentDescribe)
    callback()
    currentDescribe = oldDescribe
    
    return currentDescribe
end

function busted.it(description, callback)
    if not currentDescribe then
        error("it() doit être appelé à l'intérieur d'un describe()")
    end
    
    table.insert(currentDescribe.tests, {
        description = description,
        callback = callback,
        pending = callback == nil
    })
    
    return currentDescribe.tests[#currentDescribe.tests]
end

function busted.pending(description)
    if not currentDescribe then
        error("pending() doit être appelé à l'intérieur d'un describe()")
    end
    
    table.insert(currentDescribe.tests, {
        description = description,
        pending = true
    })
    
    return currentDescribe.tests[#currentDescribe.tests]
end

function busted.before_each(callback)
    if not currentDescribe then
        error("before_each() doit être appelé à l'intérieur d'un describe()")
    end
    
    currentDescribe.before_each = callback
end

-- Assertions
local assert_mt = {}

function assert_mt.__index(_, key)
    return function(...)
        stats.assertions = stats.assertions + 1
        local status, err = pcall(assert[key], ...)
        if not status then
            error(err, 2)
        end
        return true
    end
end

busted.assert = setmetatable({
    equals = function(expected, actual, message)
        if expected ~= actual then
            error(message or ("Attendu: " .. tostring(expected) .. ", Obtenu: " .. tostring(actual)), 2)
        end
        return true
    end,
    
    same = function(expected, actual, message)
        -- Test simple d'égalité pour les tables (ne vérifie pas les tables imbriquées)
        if type(expected) ~= "table" or type(actual) ~= "table" then
            error("same() s'attend à recevoir deux tables", 2)
        end
        
        for k, v in pairs(expected) do
            if actual[k] ~= v then
                error(message or ("Différence à la clé " .. tostring(k)), 2)
            end
        end
        
        for k, _ in pairs(actual) do
            if expected[k] == nil then
                error(message or ("Clé supplémentaire: " .. tostring(k)), 2)
            end
        end
        
        return true
    end,
    
    is_true = function(value, message)
        if value ~= true then
            error(message or ("Attendu true, obtenu: " .. tostring(value)), 2)
        end
        return true
    end,
    
    is_false = function(value, message)
        if value ~= false then
            error(message or ("Attendu false, obtenu: " .. tostring(value)), 2)
        end
        return true
    end,
    
    is_nil = function(value, message)
        if value ~= nil then
            error(message or ("Attendu nil, obtenu: " .. tostring(value)), 2)
        end
        return true
    end,
    
    is_not_nil = function(value, message)
        if value == nil then
            error(message or "La valeur ne devrait pas être nil", 2)
        end
        return true
    end
}, assert_mt)

-- Mock simple
function busted.mock(table, key)
    local old = table[key]
    table[key] = function() end
    return {
        revert = function()
            table[key] = old
        end
    }
end

-- Fonction pour exécuter tous les tests
function busted.run()
    print("\n=== Tests Busted ===\n")
    
    for _, suite in ipairs(tests) do
        print("Exécution de: " .. suite.description)
        
        for _, test in ipairs(suite.tests) do
            if test.pending then
                pendingCount = pendingCount + 1
                print("  PENDING: " .. test.description)
            else
                io.write("  " .. test.description .. " ... ")
                local status, err = pcall(function()
                    if suite.before_each then
                        suite.before_each()
                    end
                    test.callback()
                end)
                
                if status then
                    successes = successes + 1
                    print("OK")
                else
                    table.insert(failures, {
                        suite = suite.description,
                        test = test.description,
                        error = err
                    })
                    print("ÉCHEC")
                    print("    " .. err)
                end
            end
        end
        print("")
    end
    
    -- Afficher un résumé
    print("=== Rapport ===")
    print("Tests: " .. successes + #failures)
    print("Réussis: " .. successes)
    print("Échecs: " .. #failures)
    print("En attente: " .. pendingCount)
    print("Assertions: " .. stats.assertions)
    print("===============")
    
    return #failures == 0
end

-- Fonction pour nettoyer les tests
function busted.clear()
    tests = {}
    failures = {}
    successes = 0
    pendingCount = 0
    stats.assertions = 0
end

return busted
