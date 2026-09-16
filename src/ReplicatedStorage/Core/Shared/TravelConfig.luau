--!strict
local TravelConfig = {}

TravelConfig.HOLD_DURATION = 1
TravelConfig.ACCESS_DISTANCE = 18
TravelConfig.COOLDOWN_SECONDS = 5
TravelConfig.ARRIVAL_HEIGHT_OFFSET = 3
TravelConfig.ALREADY_THERE_DISTANCE = 10

return table.freeze(TravelConfig)
