Config = {}

Config.Language = 'ar'
Config.MinPoliceOnline = 0
Config.RobberyItem = 'advancedlockpick'
Config.RobberyItemRemove = true
Config.RobberyItemUses = 1
Config.RobberyTimeout = 1
Config.BlipDuration = 180

Config.MinReward = 500
Config.MaxReward = 2000
Config.RewardItems = {
    {item = 'goldbar', chance = 5, min = 1, max = 2},
    {item = 'rolex', chance = 15, min = 1, max = 3},
    {item = 'diamond', chance = 3, min = 1, max = 1},
}

Config.Zones = {
    {name = "247supermarket", type = "store"},
    {name = "robsliquor", type = "store"},
    {name = "ltdgasoline", type = "store"},
    {name = "davis", type = "store"},
    {name = "vinewood", type = "store"},
    {name = "mirror", type = "store"},
    {name = "sandy", type = "store"},
    {name = "paleto", type = "store"},
    {name = "grapeseed", type = "store"},
    {name = "harmony", type = "store"},
    {name = "chumash", type = "store"},
    {name = "route68", type = "store"},
    
    {name = "clothing", type = "clothing"},
    {name = "suburban", type = "clothing"},
    {name = "ponsonbys", type = "clothing"},
    {name = "binco", type = "clothing"},
    
    {name = "ammunation", type = "weapon"},
    
    {name = "store", type = "store"},
    {name = "shop", type = "store"},
    {name = "market", type = "store"},
    {name = "gas", type = "store"},
    {name = "clothes", type = "clothing"},
    {name = "ammu", type = "weapon"},
    {name = "bar", type = "bar"},
    {name = "restaurant", type = "restaurant"},
    {name = "cafe", type = "cafe"},
    {name = "club", type = "club"},
    {name = "bank", type = "bank"},
    {name = "office", type = "office"},
    {name = "hotel", type = "hotel"},
    {name = "motel", type = "motel"},
    
    {name = "any", type = "any"},
}

Config.Locales = {
    ['en'] = {
        ['no_police'] = 'Not enough police in the city',
        ['register_empty'] = 'This register was recently robbed',
        ['robbery_started'] = 'You started robbing the register',
        ['robbery_cancelled'] = 'Robbery cancelled',
        ['robbery_failed'] = 'Robbery failed',
        ['robbery_successful'] = 'Robbery successful! You got $%s',
        ['robbery_police_notify'] = 'Register robbery in progress at %s',
        ['need_item'] = 'You need a %s to rob this register',
        ['minigame_started'] = 'Crack the register to get the cash',
        ['collecting_cash'] = 'Collecting cash...',
        ['bomb_exploded'] = 'Bomb exploded! You lost everything',
    },
    ['ar'] = {
        ['no_police'] = 'لا يوجد ما يكفي من الشرطة في المدينة',
        ['register_empty'] = 'تم سرقة هذا السجل مؤخرًا',
        ['robbery_started'] = 'لقد بدأت سرقة السجل',
        ['robbery_cancelled'] = 'تم إلغاء السرقة',
        ['robbery_failed'] = 'فشلت السرقة',
        ['robbery_successful'] = 'نجحت السرقة! حصلت على $%s',
        ['robbery_police_notify'] = 'سرقة سجل جارية في %s',
        ['need_item'] = 'تحتاج إلى %s لسرقة هذا السجل',
        ['minigame_started'] = 'اكسر السجل للحصول على النقود',
        ['collecting_cash'] = 'جمع النقود...',
        ['bomb_exploded'] = 'انفجرت القنبلة! خسرت كل شيء',
    }
}