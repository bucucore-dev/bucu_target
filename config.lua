-- ============================================================================
-- BUCU Core — Target Interaction Configuration
-- Next-Gen Eye Raycasting, Obsidian Glassmorphism UI, & Presets
-- ============================================================================

TargetConfig = {}

TargetConfig.Debug = false

-- Keybinds
TargetConfig.OpenKey = 19 -- Left Alt (INPUT_CHARACTER_WHEEL)
TargetConfig.ToggleMode = false -- Hold Alt to target, or true to click-toggle
TargetConfig.MaxDistance = 6.5 -- Maximum raycasting distance in meters

-- Visuals & Audio
TargetConfig.DrawSprite = true
TargetConfig.SoundFeedback = true
TargetConfig.EnableNumberShortcuts = true -- Press 1, 2, 3 to select options directly

-- Vehicle Models / Presets
TargetConfig.VehicleInteractions = {
    enabled = true,
    options = {
        {
            name = 'veh_trunk',
            icon = 'box',
            label = 'Buka / Tutup Bagasi',
            action = 'trunk',
            distance = 2.5
        },
        {
            name = 'veh_hood',
            icon = 'wrench',
            label = 'Buka / Tutup Kap Mesin',
            action = 'hood',
            distance = 2.5
        },
        {
            name = 'veh_fuel',
            icon = 'gas-pump',
            label = 'Cek Tangki Bahan Bakar',
            action = 'fuel',
            distance = 2.5
        }
    }
}

-- ATM Object Models
TargetConfig.AtmModels = {
    'prop_atm_01',
    'prop_atm_02',
    'prop_atm_03',
    'prop_fleeca_atm'
}

-- Built-in Target Zones (e.g. Police & City Hall Reception Desks)
TargetConfig.Zones = {}
