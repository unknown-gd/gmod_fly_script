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
            vel[3] = math.max( 10, -vel[3] )
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

    end

    vel[1] = math.Clamp( vel[1], -maxSpeed, maxSpeed )
    vel[2] = math.Clamp( vel[2], -maxSpeed, maxSpeed )
    vel[3] = math.Clamp( vel[3], -math.huge, maxSpeed )

    if (startVel == vel) then
        vel = vel - vel:GetNormal() * impactRate
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
        return a == "true" and true or false
    end

    local function int( a )
        a = tonumber( a )
        if (a == 0) or (a == nil) then
            return 450
        end

        return a
    end

    local function yesNo( a )
        return bool( a ) and "yes" or "no"
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
            MsgC( Color( 70, 225, 250 ), "Fly Script\nby PrikolMen#3372\nNow you can fly, just add yourself in fly list!" )
        end
    }

    concommand.Add("flight", function( ply, cmd, args )
        local act1 = actions[ args[1] ]
        local tp = type( act1 )
        if (tp == "table") then
            local act2 = act1[ args[2] ]
            if type( act2 ) == "function" then
                act2( args[3], args[4], args[5], args[6], args[7] )
            end
        elseif (tp == "function") then
            act1()
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
                -- Lua Data
                do
                    local mdlData = luaData["models"][ newMdl or ply:GetModel():lower() ]
                    if (mdlData == nil) then
                        local plyData = luaData["steamids"][ ply:SteamID() ]
                        if (plyData) then
                            setupData( ply, plyData )
                        end
                    else
                        setupData( ply, mdlData )
                    end
                end
                -- Custom Data
                do
                    local mdlData = customData["models"][ newMdl or ply:GetModel() ]
                    if (models == nil) then
                        local plyData = customData["steamids"][ ply:SteamID() ]
                        if (plyData) then
                            setupData( ply, plyData )
                        end
                    else
                        setupData( ply, mdlData )
                    end
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

                if not ply:IsOnGround() then
                    if ply:GetNWBool( "PrikolMen's Fly Script:Drone", false ) then
                        DroneMode( ply, mv, cmd )
                    else
                        FlyMove( ply, mv, cmd )
                    end
                else
                    InFlight( ply, false )
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

            elseif not ply:IsOnGround() then
                if mv:KeyDown( IN_JUMP ) then
                    cmd:RemoveKey( IN_JUMP )
                end
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
		ply:SetPlaybackRate( 0 )
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

-- EC2 Fix

if CLIENT then
    timer.Simple(0, function()
        if EnhancedCameraTwo then

            local function ApproximatePlayerModel( ply )
                -- Return a value suitable for detecting model changes
                return ply:GetNWString("EnhancedCameraTwo:TrueModel", ply:GetModel())
            end

            local function GetPlayerBodyGroups( ply )
                local bodygroups = {}
                for num, tbl in ipairs( ply:GetBodyGroups() ) do
                    bodygroups[ tbl.id ] = ply:GetBodygroup( tbl.id )
                end
                return bodygroups
            end

            local function GetPlayerMaterials( ply )
                local materials = {}
                for num, path in ipairs( ply:GetMaterials() ) do
                    materials[ num - 1 ] = ply:GetSubMaterial( num - 1 )
                end
                return materials
            end

            hook.Add("UpdateAnimation", "EnhancedCameraTwo:UpdateAnimation", function( ply )
                if ( LocalPlayer():EntIndex() == ply:EntIndex() ) then
                    local modelChanged = false
                    local poseChanged = false

                    local self = EnhancedCameraTwo

                    -- Handle model changes
                    modelChanged = self:HasChanged("model", ApproximatePlayerModel(ply)) or modelChanged
                    modelChanged = self:HasTableChanged("bodyGroups", GetPlayerBodyGroups(ply)) or modelChanged
                    --modelChanged = self:HasTableChanged("materials", GetPlayerMaterials()) or modelChanged
                    modelChanged = self:HasChanged("skin", ply:GetSkin()) or modelChanged
                    modelChanged = self:HasChanged("material", ply:GetMaterial()) or modelChanged
                    modelChanged = self:HasTableChanged("color", ply:GetColor()) or modelChanged
                    if not IsValid(self.entity) or modelChanged then
                        poseChanged = true
                        self:OnModelChange()
                    end

                    -- Set flexes to match
                    -- Flexes will reset if not set on every frame
                    for i = 0, ply:GetFlexNum() - 1 do
                        self.entity:SetFlexWeight(i, ply:GetFlexWeight(i) )
                    end

                    -- Test if sequence changed
                    if self:HasChanged("sequence", self:GetSequence()) then
                        self:ResetSequence(self.sequence)
                        if self:HasChanged("pose", self:GetPose()) then
                            poseChanged = true
                        end
                    end

                    -- Test if weapon changed
                    if self:HasChanged("weapon", ply:GetActiveWeapon()) then
                        self.reloading = false
                        poseChanged = true
                    end

                    -- Test if reload is finished
                    if self.reloading then
                        if IsValid(self.weapon) then
                            local time = CurTime()
                            if self.weapon:GetNextPrimaryFire() < time and self.weapon:GetNextSecondaryFire() < time then
                                self.reloading = false
                                poseChanged = true
                            end
                        else
                            self.reloading = false
                        end
                    end

                    -- Handle weapon changes
                    if poseChanged then self:OnPoseChange() end

                    self:SetPlaybackRate( ply:GetPlaybackRate() )

                    self:FrameAdvance(CurTime() - self.lastTick)
                    self.lastTick = CurTime()

                    -- Pose remainder of model
                    self:SetPoseParameter("breathing", ply:GetPoseParameter("breathing"))
                    self:SetPoseParameter("move_x", (ply:GetPoseParameter("move_x") * 2) - 1)
                    self:SetPoseParameter("move_y", (ply:GetPoseParameter("move_y") * 2) - 1)
                    self:SetPoseParameter("move_yaw", (ply:GetPoseParameter("move_yaw") * 360) - 180)

                    -- Pose vehicle steering
                    if ply:InVehicle() then
                        self.entity:SetColor(color_transparent)
                        self:SetPoseParameter("vehicle_steer", (ply:GetVehicle():GetPoseParameter("vehicle_steer") * 2) - 1)
                    end

                    -- Update skeleton neck offset
                    self.neckOffset = self.skelEntity:GetBonePosition(self.skelEntity.neck)
                end
            end)
        end

    end)
end