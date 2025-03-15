--[[
Timer simplifié pour gérer les animations dans Fructidor
Inspiré de HUMP (https://github.com/vrld/hump)
]]

local Timer = {}
Timer.__index = Timer

function Timer.new()
    return setmetatable({
        functions = {},
        tween = {}
    }, Timer)
end

local function _tween(f, self, len, obj, target, method, after, ...)
    local t, args = 0, {...}
    
    method = method or "linear"
    after = after or function() end
    
    -- Table des fonctions d'interpolation
    local interp = {
        linear = function(s, e, t) return s + (e - s) * t end,
        outQuad = function(s, e, t) return s + (e - s) * (1 - (1 - t) * (1 - t)) end,
        inQuad = function(s, e, t) return s + (e - s) * t * t end
    }
    
    local id = f(function(dt)
        t = t + dt
        if t <= len then
            -- Interpoler les valeurs en fonction du temps écoulé
            local progress = t / len
            for k, v in pairs(target) do
                if type(v) == "number" and obj[k] ~= nil then
                    obj[k] = interp[method](obj[k], v, progress)
                end
            end
        else
            -- Animation terminée
            for k, v in pairs(target) do
                if type(v) == "number" and obj[k] ~= nil then
                    obj[k] = v
                end
            end
            Timer.cancel(self, id)
            after(obj)
        end
    end, obj)
    
    return id
end

function Timer:update(dt)
    -- Copier la liste des fonctions pour éviter les problèmes de modification pendant l'itération
    local to_update = {}
    for handle, delay in pairs(self.functions) do
        to_update[handle] = delay
    end
    
    for handle, delay in pairs(to_update) do
        delay = delay - dt
        if delay <= 0 then
            -- Vérifier que le handle existe toujours dans tween
            if self.tween[handle] then
                local func = self.tween[handle].func
                local params = self.tween[handle].params
                
                if func then
                    func(dt, unpack(params))
                end
            end
        end
        
        -- Vérifier si le handle existe toujours avant de mettre à jour
        if self.functions[handle] then
            self.functions[handle] = delay
        end
    end
end

function Timer:tween(len, obj, target, method, after, ...)
    return _tween(function(f, ...) 
        local handle = { func = f, params = {...} }
        self.tween[handle] = handle
        self.functions[handle] = 0
        return handle
    end, self, len, obj, target, method, after, ...)
end

function Timer:cancel(handle)
    if handle then
        self.functions[handle] = nil
        self.tween[handle] = nil
    end
end

function Timer:clear()
    self.functions = {}
    self.tween = {}
end

return Timer
