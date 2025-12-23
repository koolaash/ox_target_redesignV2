-- Wait for ox_target to be ready
local function WaitForOxTarget()
    local timeout = 0
    while not exports.ox_target and timeout < 100 do
        timeout = timeout + 1
        Wait(100)
    end
    return exports.ox_target ~= nil
end

local testPed = nil

-- Function to create the test ped
local function CreateTestPed()
    print('[ox_target] Starting test ped creation...')
    
    -- Delete existing ped if it exists
    if testPed and DoesEntityExist(testPed) then
        DeleteEntity(testPed)
        print('[ox_target] Deleted existing test ped')
    end

    -- Create the ped
    local pedModel = `a_m_m_business_01` -- Business man ped model
    print('[ox_target] Loading ped model...')
    
    RequestModel(pedModel)
    
    local timeoutCounter = 0
    while not HasModelLoaded(pedModel) and timeoutCounter < 100 do
        timeoutCounter = timeoutCounter + 1
        print('[ox_target] Waiting for model to load... Attempt: ' .. timeoutCounter)
        Wait(100)
    end

    if not HasModelLoaded(pedModel) then
        print('[ox_target] Failed to load ped model!')
        return
    end

    print('[ox_target] Model loaded, creating ped...')
    
    -- Ensure we're using the correct coordinate format
    testPed = CreatePed(4, pedModel, -951.8873, -347.5526, 36.9356, 115.6294, false, true)
    
    if not DoesEntityExist(testPed) then
        print('[ox_target] Failed to create ped!')
        return
    end

    print('[ox_target] Ped created with ID: ' .. testPed)

    -- Set ped properties
    SetEntityAsMissionEntity(testPed, true, true)
    SetBlockingOfNonTemporaryEvents(testPed, true)
    SetPedDiesWhenInjured(testPed, false)
    SetPedCanPlayAmbientAnims(testPed, true)
    SetPedCanRagdollFromPlayerImpact(testPed, false)
    SetEntityInvincible(testPed, true)
    FreezeEntityPosition(testPed, true)
    SetModelAsNoLongerNeeded(pedModel)

    print('[ox_target] Ped properties set, adding target options...')

    -- Add target options to the ped
    exports.ox_target:addLocalEntity(testPed, {
        {
            name = 'test_talk',
            label = 'Talk to NPC',
            icon = 'fas fa-comments',
            onSelect = function()
                print('[ox_target] Talking to test NPC')
            end
        },
        {
            name = 'test_trade',
            label = 'Trade with NPC',
            icon = 'fas fa-exchange-alt',
            onSelect = function()
                print('[ox_target] Trading with test NPC')
            end
        },
        {
            name = 'test_quest',
            label = 'Request Quest',
            icon = 'fas fa-exclamation',
            onSelect = function()
                print('[ox_target] Requesting quest from test NPC')
            end
        },
        {
            name = 'test_info',
            label = 'Ask for Information',
            icon = 'fas fa-info-circle',
            onSelect = function()
                print('[ox_target] Asking for information from test NPC')
            end
        }
    })

    print('[ox_target] Test ped setup complete!')
end

-- Create the test ped when resource starts
CreateThread(function()
    print('[ox_target] Test setup script started')
    Wait(2000) -- Wait for base game to be ready
    
    print('[ox_target] Waiting for ox_target to be ready...')
    if not WaitForOxTarget() then
        print('[ox_target] Failed to find ox_target export!')
        return
    end
    
    print('[ox_target] ox_target is ready, creating test ped...')
    CreateTestPed()
end)

-- Command to recreate the test ped
RegisterCommand('recreate_test_ped', function()
    print('[ox_target] Recreating test ped via command')
    if not exports.ox_target then
        print('[ox_target] Cannot recreate ped - ox_target export not found!')
        return
    end
    CreateTestPed()
end, false)

-- Cleanup when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() and testPed and DoesEntityExist(testPed) then
        DeleteEntity(testPed)
        print('[ox_target] Cleaned up test ped')
    end
end) 