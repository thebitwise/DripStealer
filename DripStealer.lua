--$$\        $$$$$$\  $$\   $$\  $$$$$$\  $$$$$$$$\ 
--$$ |      $$  __$$\ $$$\  $$ |$$  __$$\ $$  _____|
--$$ |      $$ /  $$ |$$$$\ $$ |$$ /  \__|$$ |      
--$$ |      $$$$$$$$ |$$ $$\$$ |$$ |      $$$$$\    
--$$ |      $$  __$$ |$$ \$$$$ |$$ |      $$  __|   
--$$ |      $$ |  $$ |$$ |\$$$ |$$ |  $$\ $$ |      
--$$$$$$$$\ $$ |  $$ |$$ | \$$ |\$$$$$$  |$$$$$$$$\ 
--\________|\__|  \__|\__|  \__| \______/ \________|
-- coded by Lance/stonerchrist on Discord
pluto_use "0.5.0"
util.require_natives("2944b", "g")

local outfits_dir = filesystem.stand_dir() .. '\\Outfits\\DripStealer Outfits\\'
if not filesystem.exists(outfits_dir) then 
    if not SCRIPT_SILENT_START then 
        util.toast('Welcome to DripStealer! We have created three folders in your Stand/Outfits directory that outfits will save to.')
    end
    filesystem.mkdir(outfits_dir)
end

if not filesystem.exists(outfits_dir .. '\\Male') then 
    filesystem.mkdir(outfits_dir .. '\\Male')
end

if not filesystem.exists(outfits_dir .. '\\Female') then 
    filesystem.mkdir(outfits_dir .. '\\Female')
end

if not filesystem.exists(outfits_dir .. '\\Other') then 
    filesystem.mkdir(outfits_dir .. '\\Other')
end



local props = {}
props[0] = 'Hat'
props[1] = 'Glasses'
props[2] = 'Earwear'
props[3] = 'Watch'
props[4] = 'Bracelet'

-- thanks to aaron for proper id's for components and props in stand context
function get_stand_component_tbl(mdl_str)
    local _tbl = {}
    if mdl_str == 'mp_f_freemode_01' or  mdl_str == 'mp_m_freemode_01' then 
        _tbl[0] = 'Head'
        _tbl[1] = 'Mask'
        _tbl[2] = 'Hair'
        _tbl[3] = 'Torso'
        _tbl[11] = 'Top'
        _tbl[8] = 'Top 2'
        _tbl[9] = 'Top 3'
        _tbl[5] = 'Bag'
        _tbl[4] = 'Pants'
        _tbl[6] = 'Shoes'
        _tbl[7] = 'Accessories'
        _tbl[10] = 'Decals'
    else
        _tbl[0] = 'Head'
        _tbl[1] = 'Facial Hair'
        _tbl[2] = 'Hair'
        _tbl[3] = 'Top'
        _tbl[11] = 'Top 2'
        _tbl[8] = 'Top 3'
        _tbl[9] = 'Bag'
        _tbl[5] = 'Gloves'
        _tbl[4] = 'Pants'
        _tbl[6] = 'Shoes'
        _tbl[7] = 'Accessories'
        _tbl[10] = 'Decals'
    end
    return _tbl
end


function restrict_to_alphanumeric(input_str)
    return input_str:gsub("[^%w]", "")
end

function get_stand_ped_model_name(mdl)
    local translated = mdl
    local translations = {
        player_zero = 'Michael',
        player_one = 'Franklin',
        player_two = 'Trevor',
        mp_f_freemode_01 = 'Online Female',
        mp_m_freemode_01 = 'Online Male',
        cs_orleans = 'Bigfoot',
        ig_orleans = 'Bigfoot 2',
        a_c_boar = 'Boar',
        a_c_boar_02 = 'Boar 2',
        a_c_cat_01 = 'Cat',
        a_c_chimp = 'Chimp',
        a_c_chimp_02 = 'Chimp 2',
        a_c_chop = 'Chop',
        a_c_chop_02 = 'Chop 2',
        a_c_cow = 'Cow',
        a_c_coyote = 'Coyote',
        a_c_coyote_02 = 'Coyote 2',
        a_c_deer = 'Deer',
        a_c_deer_02 = 'Deer 2',
        a_c_shepherd = 'German Shepherd',
        a_c_hen = 'Hen',
        a_c_husky = 'Husky',
        a_c_mtlion = 'Mountain Lion',
        a_c_mtlion_02 = 'Mountain Lion 2',
        a_c_panther = 'Panther',
        a_c_pig = 'Pig',
        a_c_poodle = 'Poodle',
        a_c_pug = 'Pug',
        a_c_pug_02 = 'Pug 2',
        a_c_rabbit = 'Rabbit',
        a_c_rabbit_02 = 'Rabbit 2',
        a_c_rat = 'Rat',
        a_c_retriever = 'Golden Retriever',
        a_c_rhesus = 'Rhesus',
        a_c_rottweiler = 'Rottweiler',
        a_c_westy = 'Westy',
        a_c_dolphin = 'Dolphin',
        a_c_fish = 'Fish',
        a_c_sharkhammer = 'Hammer Shark',
        a_c_humpback = 'Humpback',
        a_c_killerwhale = 'Killer Whale',
        a_c_stingray = 'Stingray',
        a_c_sharktiger = 'Tiger Shark',
        a_c_cormorant = 'Cormorant',
        a_c_chickenhawk = 'Chicken Hawk',
        a_c_crow = 'Crow', 
        a_c_pigeon = 'Pigeon',
        a_c_seagull = 'Seagull'
    } 
    return translations[mdl]
end


local stealer = false 
menu.my_root():toggle('Outfit Stealer', {'outfitstealer'}, 'Automatically steal outfits from all players in a session and saves them to Stand outfits', function(on)
    stealer = on
end)

menu.my_root():action('Manual save', {'savealloutfits'}, 'Initiates a manual save on all outfits', function()
    for _, pid in pairs(players.list(false, true, true)) do 
        save_outfit(pid)
    end
end)

menu.my_root():action('Wardrobe shortcut', {}, '', function()
    menu.trigger_commands('wardrobe')
end)


function save_outfit(pid)
    local ped = GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local name = players.get_name(pid)
    local final_components = {}
    local final_props = {}
    local mdl = GET_ENTITY_MODEL(ped)
    if mdl == 0 then 
        util.log('[DRIPSTEALER] Waiting for ' .. name .. '\'s ped model to become valid...')
    end
    while GET_ENTITY_MODEL(ped) == 0 do 
        util.yield()
    end
    mdl = util.reverse_joaat(mdl)
    local stand_outfit = get_stand_component_tbl(mdl)
    for index, stand_name in pairs(stand_outfit) do 
        final_components[stand_name] = GET_PED_DRAWABLE_VARIATION(ped, index)
        final_components[stand_name .. ' Variation'] = GET_PED_TEXTURE_VARIATION(ped, index)
        if table.contains(final_props, props[index]) then
            final_props[props[index]] = GET_PED_PROP_INDEX(ped, index)
            local variation = GET_PED_PROP_TEXTURE_INDEX(ped, index)
            if variation == -1 then 
                variation = 0 
            end
            final_props[props[index] .. ' Variation'] = variation
        end
    end
    name = restrict_to_alphanumeric(name)
    local file_name = ''
    local dt = tostring(os.date("%m-%d-%y", os.time()))
    if mdl == 'mp_f_freemode_01' then 
        file_name = outfits_dir .. '\\Female\\' .. name .. '_' .. dt .. ' ' .. os.time() .. '.txt'
    elseif mdl == 'mp_m_freemode_01' then 
        file_name = outfits_dir .. '\\Male\\' .. name .. '_' .. dt .. ' ' .. os.time() .. '.txt'
    else
        file_name = outfits_dir .. '\\Other\\' .. name .. '_' .. dt .. ' ' .. os.time() .. '.txt'
    end
    local new_file = io.open(file_name, 'w')
    new_file:write('Model: ' .. get_stand_ped_model_name(mdl) .. '\n')
    for thing, value in pairs(final_components) do 
        new_file:write(thing .. ': ' .. value .. '\n')
    end
    for thing, value in pairs(final_props) do 
        new_file:write(thing .. ': ' .. value .. '\n')
    end
    new_file:close()
    util.log('[DRIPSTEALER] Saved ' .. name .. '\'s outfit to file (' .. mdl .. ')')
end

players.on_join(function(pid)
    if stealer then
        save_outfit(pid)
    end
end)

players.dispatch_on_join()

menu.my_root():hyperlink('Join Discord', 'https://discord.gg/zZ2eEjj88v', '')
