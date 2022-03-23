local color = SERVER and Color( 0, 130, 255 ) or Color( 222, 169, 9 )
MsgC( color, [[

    88888888888  88                   ad88888ba                           88
    88           88                  d8"     "8b                          ""                ,d
    88           88                  Y8,                                                    88
    88aaaaa      88  8b       d8     `Y8aaaaa,     ,adPPYba,  8b,dPPYba,  88  8b,dPPYba,  MM88MMM
    88"""""      88  `8b     d8'       `"""""8b,  a8"     ""  88P'   "Y8  88  88P'    "8a   88
    88           88   `8b   d8'              `8b  8b          88          88  88       d8   88
    88           88    `8b,d8'       Y8a     a8P  "8a,   ,aa  88          88  88b,   ,a8"   88,
    88           88      Y88'         "Y88888P"    `"Ybbd8"'  88          88  88`YbbdP"'    "Y888
                        d8'                                                  88
                        d8'                                                   88

]])

MsgC( color, "     By PrikolMen#3372\n" )
MsgC( color, "     Status: ", Color( 140, 225, 80 ), "OK\n\n" )

local defaultSpeed = 450
local impactRate = 5

local function FlyMove( ply, mv, cmd )

    local maxSpeed = ply:GetNWInt( "PrikolMen's Fly Script:MaxSpeed", defaultSpeed )
    local vel = mv:GetVelocity()
    local startVel = vel

    if mv:KeyDown( IN_SPEED ) then

        local eyeAngles = ply:EyeAngles()
        if mv:KeyDown( IN_FORWARD ) then
            cmd:RemoveKey( IN_FORWARD )
            vel = vel + eyeAngles:Forward() * 10
        end

        if mv:KeyDown( IN_BACK ) then
            cmd:RemoveKey( IN_BACK )
            vel = vel - eyeAngles:Forward() * 10
        end

        if mv:KeyDown( IN_MOVELEFT ) then
            cmd:RemoveKey( IN_MOVELEFT )
            vel = vel - eyeAngles:Right() * 10
        end

        if mv:KeyDown( IN_MOVERIGHT ) then
            cmd:RemoveKey( IN_MOVERIGHT )
            vel = vel + eyeAngles:Right() * 10
        end

        if mv:KeyDown( IN_JUMP ) then
            cmd:RemoveKey( IN_JUMP )

            if mv:KeyDown( IN_DUCK ) then
                cmd:RemoveKey( IN_DUCK )
                vel[3] = vel[3] - 25
            else
                vel[3] = vel[3] + 25
            end

        elseif mv:KeyDown( IN_DUCK ) then
            cmd:RemoveKey( IN_DUCK )
            vel[3] = vel[3] - 25
        else
            vel[3] = math.max( 2.25, -vel[3] ) -- -startVel[3] --math.max( 9.5025, -startVel[3] )
        end

        cmd:RemoveKey( IN_SPEED )
    else

        if mv:KeyDown( IN_FORWARD ) then
            cmd:RemoveKey( IN_FORWARD )
            vel = vel + ply:EyeAngles():Forward() * 5
        end

        if mv:KeyDown( IN_JUMP ) then
            if mv:KeyDown( IN_DUCK ) then
                cmd:RemoveKey( IN_DUCK )
                vel[3] = math.max( 10, -vel[3] ) - 100
            else
                vel[3] = math.max( 10, -vel[3] ) + 100
            end

            cmd:RemoveKey( IN_JUMP )
        elseif mv:KeyDown( IN_DUCK ) then
            cmd:RemoveKey( IN_DUCK )
            vel[3] = vel[3] - 1
        end

        vel[3] = math.Clamp( vel[3], -math.huge, maxSpeed )
    end

    vel[1] = math.Clamp( vel[1], -maxSpeed, maxSpeed )
    vel[2] = math.Clamp( vel[2], -maxSpeed, maxSpeed )

    if (startVel == vel) then
        local impact = vel:GetNormal() * impactRate
        vel = vel - Vector(impact[1], impact[2])
    end

    mv:SetVelocity( vel )

end

local function DroneMode( ply, mv, cmd )
    local maxSpeed = ply:GetNWInt( "PrikolMen's Fly Script:MaxSpeed", defaultSpeed )
    local vel = mv:GetVelocity()
    local startVel = vel

    local eyeAngles = ply:GetAngles()
    if mv:KeyDown( IN_FORWARD ) then
        cmd:RemoveKey( IN_FORWARD )
        vel = vel + eyeAngles:Forward() * maxSpeed
    end

    if mv:KeyDown( IN_BACK ) then
        cmd:RemoveKey( IN_BACK )
        vel = vel - eyeAngles:Forward() * maxSpeed
    end

    if mv:KeyDown( IN_MOVELEFT ) then
        cmd:RemoveKey( IN_MOVELEFT )
        vel = vel - eyeAngles:Right() * maxSpeed
    end

    if mv:KeyDown( IN_MOVERIGHT ) then
        cmd:RemoveKey( IN_MOVERIGHT )
        vel = vel + eyeAngles:Right() * maxSpeed
    end

    if mv:KeyDown( IN_JUMP ) then
        cmd:RemoveKey( IN_JUMP )

        if mv:KeyDown( IN_DUCK ) then
            cmd:RemoveKey( IN_DUCK )
            vel[3] = vel[3] - (maxSpeed + 10)
        else
            vel[3] = vel[3] + (maxSpeed + 10)
        end

    elseif mv:KeyDown( IN_DUCK ) then
        cmd:RemoveKey( IN_DUCK )
        vel[3] = vel[3] - maxSpeed / 2
    else
        vel[3] = math.max( 0, -vel[3] )
    end

    if (startVel == vel) then
        local normal = vel:GetNormal()
        vel[1] = vel[1] - normal[1] * impactRate
        vel[2] = vel[2] - normal[2] * impactRate
    end

    local curTime = CurTime()
    vel[3] = vel[3] + math.sin( curTime ) * ( 5 + math.sin( curTime * 0.2 ) * 3 )

    mv:SetVelocity( vel )
end

if SERVER then

    local luaData = {
        ["steamids"] = {
            -- { canFly, noFallDamage, MaxSpeed, silent, drone }
            ["STEAM_0:1:70096775"] = { true, false, defaultSpeed, false }
        },
        ["models"] = {
            ["models/prikolmen/mothica_pm.mdl"] = { true, true, 500, true },
            ["models/loyalists/mmd/flandre/flandre_mp_pm.mdl"] = { true, true, 600 }
        }
    }

    local customData = {
        ["steamids"] = {},
        ["models"] = {}
    }

    local function bool( a )
        if not isstring( a ) then
            return false
        end

        a = a:lower()

        if (a == "true") then
            return true
        end

        if (a == "yes") then
            return true
        end

        if (a == "y") then
            return true
        end

        if (a == "да") then
            return true
        end

        if (a == "д") then
            return true
        end

        return false
    end

    local function int( a )
        a = tonumber( a )
        if (a == 0) or (a == nil) then
            return 450
        end

        return a
    end

    local function yesNo( a )
        return bool( a ) and "Yes" or "No"
    end

    local actions = {
        ["add"] = {
            ["steamid"] = function( steamid, canFly, noFallDamage, MaxSpeed, silent, drone )
                if steamid == nil then
                    print( "Please enter steamid.")
                    return
                end

                customData["steamids"][ steamid ] = { bool( canFly ), bool( noFallDamage ), int( MaxSpeed ), bool( silent ), bool( drone ) }
                print("Added steamid: ", steamid, "Can flight: ", yesNo(canFly), " No FallDamage: ", yesNo( noFallDamage ), " MaxSpeed: ", MaxSpeed or defaultSpeed, " Silent: ", yesNo( silent ), " Is Drone: ", yesNo( drone ))
            end,
            ["steamid64"] = function( steamid64, canFly, noFallDamage, MaxSpeed, silent, drone )
                if steamid64 == nil then
                    print( "Please enter steamid64.")
                    return
                end

                customData["steamids"][ util.SteamIDFrom64( steamid64 ) ] = { bool( canFly ), bool( noFallDamage ), int( MaxSpeed ), bool( silent ), bool( drone ) }
                print("Added steamid64: ", steamid64, "Can flight: ", yesNo(canFly), " No FallDamage: ", yesNo( noFallDamage ), " MaxSpeed: ", MaxSpeed or defaultSpeed, " Silent: ", yesNo( silent ), " Is Drone: ", yesNo( drone ))
            end,
            ["model"] = function( mdl, canFly, noFallDamage, MaxSpeed, silent, drone )
                if mdl == nil then
                    print( "Please enter model path.")
                    return
                end

                customData["models"][ mdl ] = { bool( canFly ), bool( noFallDamage ), int( MaxSpeed ), bool( silent ), bool( drone ) }
                print("Added model: ", mdl, "Can flight: ", yesNo(canFly), " No FallDamage: ", yesNo( noFallDamage ), " MaxSpeed: ", MaxSpeed or defaultSpeed, " Silent: ", yesNo( silent ), " Is Drone: ", yesNo( drone ))
            end
        },
        ["remove"] = {
            ["steamid"] = function( steamid )
                customData["steamids"][ steamid ] = nil
            end,
            ["steamid64"] = function( steamid64 )
                customData["steamids"][ util.SteamIDFrom64( steamid64 ) ] = nil
            end,
            ["model"] = function( mdl )
                customData["models"][ mdl ] = nil
            end
        },
        ["info"] = function()
            MsgC( Color( 70, 225, 250 ), "Fly Script\nby PrikolMen#3372\nTo use fly, just add yourself in flight list!\nExample: flight steamid" )
        end
    }

    concommand.Add("flight", function( ply, cmd, args )
        if IsValid( ply ) then
            return
        end

        local act1 = actions[ args[1] ]
        local tp = type( act1 )
        if (tp == "table") then
            local act2 = act1[ args[2] ]
            if type( act2 ) == "function" then
                act2( args[3], args[4], args[5], args[6], args[7] )
            end
        elseif (tp == "function") then
            act1()
        else
            actions.info()
        end
    end,
    function( cmd, argsStr )
        if argsStr:Replace( " ", "" ) == "" then
            return {cmd .. " add", cmd .. " remove", cmd .. " info"}
        end

        local args = argsStr:Split( " " )
        if (args[4] == nil) and table.HasValue({"info", "add", "remove"}, args[2]:Replace( " ", "" )) then
            if (args[3] == "") then
                return {cmd .. argsStr .. "steamid ", cmd .. argsStr .. "steamid64 ", cmd .. argsStr .. "model " }
            elseif (args[3] == nil) then
                return {cmd .. argsStr .. " steamid ", cmd .. argsStr .. " steamid64", cmd .. argsStr .. " model " }
            end

            if (args[3] == "model") then
                if (args[4] == "") then
                    local models = {}
                    for name, mdl in pairs( player_manager.AllValidModels() ) do
                        table.insert( models, cmd .. argsStr .. mdl )
                    end

                    return models
                elseif (args[4] == nil) then
                    local models = {}
                    for name, mdl in pairs( player_manager.AllValidModels() ) do
                        table.insert( models, cmd .. argsStr .. " " .. mdl )
                    end

                    return models
                end
            end
        end
    end)

    local fileJSON = file.Read( "fly_script.dat", "DATA" )
    if fileJSON then
        local JSON = util.Decompress( fileJSON )
        if JSON and not JSON == "" then
            for name, value in pairs( util.JSONToTable( JSON ) ) do
                customData[ name ] = value
            end
        end
    end

    hook.Add("ShutDown", "PrikolMen's Fly Script", function()
        file.Write( "fly_script.dat", util.Compress( util.TableToJSON( customData ) ) )
    end)

    local function setupData( ply, data )
        ply:SetNWBool( "PrikolMen's Fly Script:CanFly", data[1] or true )
        ply:SetNWBool( "PrikolMen's Fly Script:FallDamage", data[2] or false )

        if (data[5] == true) then
            if type( data[3] ) == "number" then
                ply:SetNWInt( "PrikolMen's Fly Script:MaxSpeed", data[3] / 100 )
            end
        else
            ply:SetNWInt( "PrikolMen's Fly Script:MaxSpeed", data[3] or defaultSpeed )
        end

        ply:SetNWBool( "PrikolMen's Fly Script:Silent", data[4] or false )
        ply:SetNWBool( "PrikolMen's Fly Script:Drone", data[5] or false )
    end

    local function playerCheck( ply, oldMdl, newMdl )
        ply:SetNWBool( "PrikolMen's Fly Script:InFlight", false )
        ply:SetNWBool( "PrikolMen's Fly Script:CanFly", true )

        timer.Simple(0, function()
            if IsValid( ply ) then

                local mdlData1 = luaData["models"][ newMdl or ply:GetModel():lower() ]
                if (mdlData1) then
                    setupData( ply, mdlData1 )
                    return
                end

                local mdlData2 = customData["models"][ newMdl or ply:GetModel() ]
                if (mdlData2) then
                    setupData( ply, mdlData2 )
                    return
                end

                local plyData2 = customData["steamids"][ ply:SteamID() ]
                if (plyData2) then
                    setupData( ply, plyData2 )
                    return
                end

                local plyData1 = luaData["steamids"][ ply:SteamID() ]
                if (plyData1) then
                    setupData( ply, plyData1 )
                end

            end
        end)
    end

    hook.Add( "PlayerSpawn", "PrikolMen's Fly Script", playerCheck )
    hook.Add( "OnPlayerSetModel", "PrikolMen's Fly Script", playerCheck )

    local function InFlight( ply, bool )
        ply:SetNWBool( "PrikolMen's Fly Script:InFlight", bool )
    end

    hook.Add("PlayerEnteredVehicle", "PrikolMen's Fly Script", function( ply )
        if ply:GetNWBool( "PrikolMen's Fly Script:InFlight", false ) then
            InFlight( ply, false )
        end
    end)

    hook.Add("SetupMove", "PrikolMen's Fly Script", function(ply, mv, cmd)
        if ply:GetNWBool( "PrikolMen's Fly Script:CanFly", false ) then
            if ply:GetNWBool( "PrikolMen's Fly Script:InFlight", false ) then
                cmd:ClearButtons()
                cmd:ClearMovement()

                if ply:IsOnGround() or ply:InVehicle() or (ply:WaterLevel() > 0) then
                    InFlight( ply, false )
                else
                    if ply:GetNWBool( "PrikolMen's Fly Script:Drone", false ) then
                        DroneMode( ply, mv, cmd )
                    else
                        FlyMove( ply, mv, cmd )
                    end
                end

            elseif not ply:IsOnGround() then
                if mv:KeyDown(IN_JUMP) then
                    InFlight( ply, true )
                    cmd:RemoveKey(IN_JUMP)
                end
            end
        elseif ply:GetNWBool( "PrikolMen's Fly Script:InFlight", false ) then
            InFlight( ply, true )
        end
    end)

else

    hook.Add("SetupMove", "PrikolMen's Fly Script", function(ply, mv, cmd)
        if ply:GetNWBool( "PrikolMen's Fly Script:CanFly", false ) then
            if ply:GetNWBool( "PrikolMen's Fly Script:InFlight", false ) then
                cmd:ClearButtons()
                cmd:ClearMovement()

                if not ply:IsOnGround() then
                    if ply:GetNWBool( "PrikolMen's Fly Script:Drone", false ) then
                        DroneMode( ply, mv, cmd )
                    else
                        FlyMove( ply, mv, cmd )
                    end
                end

            -- elseif not ply:IsOnGround() then
            --     if mv:KeyDown( IN_JUMP ) then
            --         cmd:RemoveKey( IN_JUMP )
            --     end
            end
        end
    end)

end

-- Animations
hook.Add("CalcMainActivity", "PrikolMen's Fly Script", function(ply, velocity)
    if ply:GetNWBool( "PrikolMen's Fly Script:InFlight", false ) then

        if not ply:IsOnGround() then
            local idealact = ACT_INVALID
            if IsValid( ply:GetActiveWeapon() ) then
                idealact = ACT_MP_SWIM
            else
                idealact = ACT_HL2MP_IDLE + 9
            end

            return idealact , ACT_INVALID
        end

        local vel = ply:GetVelocity()
        if (vel:Length() > defaultSpeed) or (vel[3] > 300) then
            local tr = util.QuickTrace(ply:GetPos(), Vector(0, 0, -1) * 200, function(ent)
                if ent:IsPlayer() or ent:IsVehicle() or (ent == ply) then return false end
                return true
            end)

            if tr.Hit then
                local pos = tr.HitPos
                local size = math.abs( vel[3] ) / 5

                timer.Create("FlyDust_" .. ply:SteamID64(), 0.1, 3, function()
                    local fx = EffectData()
                    fx:SetOrigin( pos )
                    fx:SetScale( size )
                    util.Effect( "ThumperDust", fx )
                end)
            end
        end
    end
end)

hook.Add("UpdateAnimation", "PrikolMen's Fly Script", function( ply )
	if ply:GetNWBool( "PrikolMen's Fly Script:InFlight", false ) then
		ply:SetPlaybackRate( ply:GetVelocity():Length() < 100 and 0.25 or 0 )
		return true
	end
end)

-- Extra Stuff
hook.Add("GetFallDamage", "PrikolMen's Fly Script", function( ply )
	if ply:GetNWBool( "PrikolMen's Fly Script:InFlight", false ) and ply:GetNWBool( "PrikolMen's Fly Script:FallDamage", false ) then
		return 0
	end
end)

hook.Add("PlayerFootstep", "PrikolMen's Fly Script", function( ply )
    if ply:GetNWBool( "PrikolMen's Fly Script:Silent", false ) then
        return true
    end
end)
